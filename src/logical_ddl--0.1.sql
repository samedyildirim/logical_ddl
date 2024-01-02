-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION logical_ddl;" to load this file. \quit

create table publish_tablelist (
    id serial primary key,
    relid oid not null,
    cmd_list text[] default '{}'::text[] not null
);

create table subscribe_tablelist (
    id serial primary key,
    source varchar(64) not null,
    relid oid not null,
    cmd_list text[] default '{}'::text[] not null
);

create table shadow_table (
    id serial not null,
    source varchar(64) not null,
    schema_name varchar(64) not null,
    command json not null,
    date timestamp without time zone default now() not null,
    primary key (id,source)
);

create table applied_commands (
    id serial primary key,
    source varchar(64) not null,
    command_string text not null,
    command_id int not null,
    applied_date timestamp without time zone default now() not null,
    is_failed boolean not null
);

create table settings (
    publish boolean not null,
    source varchar(64) not null,
    check (length(source) >= 3)
);

create unique index on applied_commands (source,command_id);
create unique index on publish_tablelist (relid);
create unique index on settings (source);
create unique index on settings (publish) where publish;

create or replace function logical_ddl_deparse(pg_ddl_command)
  returns table(command_type text, command_tag text, sub_command_type text,
                table_name text, column_name text, new_name text, column_type text
                /*,query text*/)
  immutable strict
  as 'MODULE_PATHNAME' language c;

create or replace function create_query(schema_name varchar(64), line jsonb)
  returns text
  language plpgsql
as $$
declare
    v_query text;
begin
    case line->>'command_type' 
        when 'simple' then
            case line->>'sub_command_type'
                when 'rename table' then
                    v_query = format('ALTER TABLE %I.%I RENAME TO %I;', 
                                        schema_name, 
                                        line->>'table_name',
                                        line->>'new_name');
                when 'rename column' then
                    v_query = format('ALTER TABLE %I.%I RENAME COLUMN %I TO %I;', 
                                        schema_name, 
                                        line->>'table_name',
                                        line->>'column_name',
                                        line->>'new_name');
            end case;
        when 'alter table' then
            case line->>'sub_command_type'
                when 'add column' then
                    v_query = format('ALTER TABLE %I.%I ADD COLUMN %I %s;', 
                                        schema_name, 
                                        line->>'table_name',
                                        line->>'column_name',
                                        line->>'column_type');
                when 'drop column' then
                    v_query = format('ALTER TABLE %I.%I DROP COLUMN %I;', 
                                        schema_name, 
                                        line->>'table_name',
                                        line->>'column_name');
                when 'alter column type' then
                    v_query = format('ALTER TABLE %I.%I ALTER COLUMN %I TYPE %s;', 
                                        schema_name, 
                                        line->>'table_name',
                                        line->>'column_name',
                                        line->>'column_type');
            end case;
    end case;
    return v_query;
end;
$$;
  
create function f_event_trg () returns event_trigger language plpgsql as $$
declare
    obj record;
    line record;
    v_source varchar(64);
begin
    select source into v_source from logical_ddl.settings where publish;
    if not found then
        return;
    end if;

    for obj in select * from pg_event_trigger_ddl_commands()
    loop
        if exists (select 1 from logical_ddl.publish_tablelist where relid = obj.objid)
        then
            for line in select * from logical_ddl.logical_ddl_deparse(obj.command)
            loop
                if exists(select 1 from logical_ddl.publish_tablelist 
                            where relid = obj.objid
                                and (cmd_list = '{}'::text[] or
                                    line.command_tag || '.' || line.sub_command_type = ANY (cmd_list)))
                then
                    insert into logical_ddl.shadow_table (source,schema_name,command) 
                                values (v_source,obj.schema_name,row_to_json(line));
                end if;
            end loop;
        end if;
    end loop;
end;
$$;

create event trigger trg_1 on ddl_command_end execute function f_event_trg();

create or replace function f_shadow_trigger() returns trigger language plpgsql as $$
declare
    v_command_string text := null;
    v_command jsonb := new.command;
begin
    if v_command->>'table_name' is null
        or v_command->>'command_tag' is null
        or v_command->>'sub_command_type' is null
    then
        raise warning 'Invalid command received, skipping: %',new;
        return null;
    end if;

    if not exists(select 1 from logical_ddl.settings 
                    where publish = false
                        and source = new.source)
    then
        return null;
    end if;
    
    if exists(select 1 from logical_ddl.subscribe_tablelist
                where source = new.source
                    and relid = ((new.schema_name) || '.' || (v_command->>'table_name'))::regclass
                    and (cmd_list = '{}'::text[] or
                        (v_command->>'command_tag') || '.' || (v_command->>'sub_command_type') = ANY (cmd_list)))
                    
    then
        begin
            v_command_string := logical_ddl.create_query(new.schema_name,v_command);
            execute v_command_string;
            insert into logical_ddl.applied_commands 
                        (source,    command_string,   command_id,   is_failed)
                 values (new.source,v_command_string, new.id,       false);
        exception when others then
            insert into logical_ddl.applied_commands 
                        (source,    command_string,   command_id,   is_failed)
                 values (new.source,v_command_string, new.id,       true);
        end;
    end if;
    return null;
end
$$;

create trigger trg_shadow after insert on shadow_table
    for each row execute function f_shadow_trigger();
    
alter table shadow_table enable replica trigger trg_shadow;

grant usage on schema logical_ddl to public;
