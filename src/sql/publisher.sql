CREATE EXTENSION logical_ddl;

CREATE TABLE public.replicated_table1 (id bigint primary key, c_text text);

INSERT INTO logical_ddl.settings
    VALUES (true, 'publisher1');
INSERT INTO logical_ddl.publish_tablelist (relid)
    VALUES ('public.replicated_table1'::regclass);

--Table renaming test
ALTER TABLE public.replicated_table1
    RENAME TO renamed_replicated_table1;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'rename table';

--Column renaming test
ALTER TABLE public.renamed_replicated_table1
    RENAME COLUMN c_text TO c_text_renamed;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'rename column';

--Column adding tests
ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_char char;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_char';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_char20 char(20);
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_char20';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_varchar varchar;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_varchar';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_varchar20 varchar(20);
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_varchar20';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_text text;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_text';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_smallint smallint;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_smallint';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_int int;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_int';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_bigint bigint;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_bigint';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_bit bit;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_bit';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_bit20 bit(20);
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_bit20';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_bitvarying bit varying;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_bitvarying';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_bitvarying20 bit varying(20);
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_bitvarying20';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_boolean boolean;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_boolean';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_bytea bytea;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_bytea';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_cidr cidr;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_cidr';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_date date;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_date';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_timestamp timestamp without time zone;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_timestamp';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_timestamp2 timestamp(2) without time zone;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_timestamp2';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_timestamptz timestamp with time zone;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_timestamptz';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_timestamptz2 timestamp(2) with time zone;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_timestamptz2';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_time time without time zone;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_time';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_time2 time(2) without time zone;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_time2';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_timetz time with time zone;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_timetz';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_timetz2 time(2) with time zone;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_timetz2';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_interval interval;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_interval';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_interval2 interval(2);
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_interval2';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_interval_hour interval hour to second;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_interval_hour';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_interval_hour2 interval hour to second(2);
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_interval_hour2';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_json json;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_json';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_jsonb jsonb;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_jsonb';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_numeric numeric;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_numeric';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_numeric10 numeric(10);
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_numeric10';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_numeric10_2 numeric(10,2);
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_numeric10_2';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_decimal decimal;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_decimal';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_decimal10 decimal(10);
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_decimal10';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_decimal10_2 decimal(10,2);
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_decimal10_2';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_real real;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_real';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_double_precision double precision;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_double_precision';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_money money;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_money';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_point point;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_point';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_line line;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_line';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_lseg lseg;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_lseg';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_box box;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_box';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_path path;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_path';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_polygon polygon;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_polygon';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_circle circle;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_circle';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_inet inet;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_inet';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_macaddr macaddr;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_macaddr';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_macaddr8 macaddr8;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_macaddr8';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_tsvector tsvector;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_tsvector';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_tsquery tsquery;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_tsquery';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_uuid uuid;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_uuid';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_xml xml;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_xml';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_int4range int4range;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_int4range';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_int8range int8range;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_int8range';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_numrange numrange;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_numrange';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_tsrange tsrange;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_tsrange';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_tstzrange tstzrange;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_tstzrange';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_daterange daterange;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' = 'c_daterange';

--Column data type changing tests
ALTER TABLE public.renamed_replicated_table1
    ALTER COLUMN c_char TYPE varchar(20);
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'alter column type' AND
        command->>'column_name' = 'c_char';

ALTER TABLE public.renamed_replicated_table1
    ALTER COLUMN c_varchar TYPE text;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'alter column type' AND
        command->>'column_name' = 'c_varchar';

--Column dropping tests
ALTER TABLE public.renamed_replicated_table1
    DROP COLUMN c_int8range;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'drop column' AND
        command->>'column_name' = 'c_int8range';

ALTER TABLE public.renamed_replicated_table1
    DROP COLUMN id;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'drop column' AND
        command->>'column_name' = 'id';

ALTER TABLE public.renamed_replicated_table1
    DROP COLUMN c_text_renamed;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'drop column' AND
        command->>'column_name' = 'c_text_renamed';

ALTER TABLE public.renamed_replicated_table1
    DROP COLUMN c_macaddr;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'drop column' AND
        command->>'column_name' = 'c_macaddr';

ALTER TABLE public.renamed_replicated_table1
    DROP COLUMN c_text;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'drop column' AND
        command->>'column_name' = 'c_text';

ALTER TABLE public.renamed_replicated_table1
    DROP COLUMN c_bigint;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'drop column' AND
        command->>'column_name' = 'c_bigint';

ALTER TABLE public.renamed_replicated_table1
    DROP COLUMN c_jsonb;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'drop column' AND
        command->>'column_name' = 'c_jsonb';

--Multiple subcommand in one alter table command
ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_msc_text text,
    ADD COLUMN c_msc_int int,
    ADD COLUMN c_msc_bigint bigint;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        command->>'sub_command_type' = 'add column' AND
        command->>'column_name' LIKE 'c_msc%';

ALTER TABLE public.renamed_replicated_table1
    ADD COLUMN c_msc_timestamp timestamp,
    DROP COLUMN c_msc_int;
SELECT source, schema_name, command
    FROM logical_ddl.shadow_table
    WHERE
        command->>'command_tag' = 'alter table' AND
        (command->>'sub_command_type', command->>'column_name') IN 
            (
                ('add column', 'c_msc_timestamp'),
                ('drop column', 'c_msc_int')
            );
