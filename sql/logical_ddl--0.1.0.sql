-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION logical_ddl;" to load this file. \quit

CREATE TABLE publish_tablelist (
    id SERIAL PRIMARY KEY,
    relid OID NOT NULL,
    cmd_list TEXT[] DEFAULT '{}'::TEXT[] NOT NULL
);

CREATE TABLE subscribe_tablelist (
    id SERIAL PRIMARY KEY,
    source VARCHAR(64) NOT NULL,
    relid OID NOT NULL,
    cmd_list TEXT[] DEFAULT '{}'::TEXT[] NOT NULL
);

CREATE TABLE shadow_table (
    id SERIAL NOT NULL,
    source VARCHAR(64) NOT NULL,
    schema_name VARCHAR(64) NOT NULL,
    command JSON NOT NULL,
    date TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    PRIMARY KEY (id, source)
);

CREATE TABLE applied_commands (
    id SERIAL PRIMARY KEY,
    source VARCHAR(64) NOT NULL,
    command_string TEXT NOT NULL,
    command_id INT NOT NULL,
    applied_date TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
    is_failed BOOLEAN NOT NULL
);

CREATE TABLE settings (
    publish BOOLEAN NOT NULL,
    source VARCHAR(64) NOT NULL,
    CHECK (length(source) >= 3)
);

CREATE UNIQUE INDEX ON applied_commands (source, command_id);
CREATE UNIQUE INDEX ON publish_tablelist (relid);
CREATE UNIQUE INDEX ON settings (source);
CREATE UNIQUE INDEX ON settings (publish) WHERE publish;

CREATE OR REPLACE FUNCTION logical_ddl_deparse(pg_ddl_command)
RETURNS TABLE
    (
        command_type text,
        command_tag text,
        sub_command_type text,
        table_name text,
        column_name text,
        new_name text,
        column_type text
    )
IMMUTABLE STRICT
AS 'MODULE_PATHNAME' LANGUAGE c;

CREATE OR REPLACE FUNCTION create_query
    (
        schema_name VARCHAR(64),
        line JSONB
    )
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_query TEXT;
BEGIN
    CASE line->>'command_type'
        WHEN 'simple' THEN
            CASE line->>'sub_command_type'
                WHEN 'rename table' THEN
                    v_query = format(
                        'ALTER TABLE %I.%I RENAME TO %I;',
                        schema_name,
                        line->>'table_name',
                        line->>'new_name'
                    );
                WHEN 'rename column' THEN
                    v_query = format(
                        'ALTER TABLE %I.%I RENAME COLUMN %I TO %I;',
                        schema_name,
                        line->>'table_name',
                        line->>'column_name',
                        line->>'new_name'
                    );
            END CASE;
        WHEN 'alter table' THEN
            CASE line->>'sub_command_type'
                WHEN 'add column' THEN
                    v_query = format(
                        'ALTER TABLE %I.%I ADD COLUMN %I %s;',
                        schema_name,
                        line->>'table_name',
                        line->>'column_name',
                        line->>'column_type'
                    );
                WHEN 'drop column' THEN
                    v_query = format(
                        'ALTER TABLE %I.%I DROP COLUMN %I;',
                        schema_name,
                        line->>'table_name',
                        line->>'column_name'
                    );
                WHEN 'alter column type' THEN
                    v_query = format(
                        'ALTER TABLE %I.%I ALTER COLUMN %I TYPE %s;',
                        schema_name,
                        line->>'table_name',
                        line->>'column_name',
                        line->>'column_type'
                    );
            END CASE;
    END CASE;
    RETURN v_query;
END
$$;

CREATE OR REPLACE FUNCTION f_event_trg ()
RETURNS event_trigger
LANGUAGE plpgsql
AS $$
DECLARE
    obj RECORD;
    line RECORD;
    v_source VARCHAR(64);
BEGIN
    SELECT source
        INTO v_source
        FROM logical_ddl.settings
        WHERE publish;
    IF NOT FOUND THEN
        RETURN;
    END IF;

    FOR obj IN
        SELECT *
        FROM pg_event_trigger_ddl_commands()
    LOOP
        IF EXISTS (
            SELECT 1
            FROM logical_ddl.publish_tablelist
            WHERE relid = obj.objid
        ) THEN
            FOR line IN
                SELECT *
                FROM logical_ddl.logical_ddl_deparse(obj.command)
            LOOP
                IF EXISTS (
                    SELECT 1
                    FROM logical_ddl.publish_tablelist
                    WHERE
                        relid = obj.objid AND
                        (
                            cmd_list = '{}'::text[] OR
                            line.command_tag || '.' || line.sub_command_type = ANY (cmd_list)
                        )
                ) THEN
                    INSERT INTO logical_ddl.shadow_table
                        (source, schema_name, command)
                        VALUES (
                            v_source,
                            obj.schema_name,
                            row_to_json(line)
                        );
                END IF;
            END LOOP;
        END IF;
    END LOOP;
END
$$;

CREATE EVENT TRIGGER trg_1
    ON ddl_command_end 
    EXECUTE FUNCTION f_event_trg();

CREATE OR REPLACE FUNCTION f_shadow_trigger()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    v_command_string TEXT := NULL;
    v_command JSONB := NEW.command;
BEGIN
    IF
        v_command->>'table_name' IS NULL OR
        v_command->>'command_tag' IS NULL OR
        v_command->>'sub_command_type' IS NULL
    THEN
        RAUSE WARNING 'Invalid command received, skipping: %', NEW;
        RETURN NULL;
    END IF;

    IF NOT EXISTS(
        SELECT 1
        FROM logical_ddl.settings
        WHERE
            publish = false AND
            source = NEW.source
    ) THEN
        RETURN NULL;
    END IF;

    IF EXISTS(
        SELECT 1
        FROM logical_ddl.subscribe_tablelist
        WHERE
            source = new.source AND
            relid = ((new.schema_name) || '.' || (v_command->>'table_name'))::regclass AND
            (
                cmd_list = '{}'::TEXT[] OR
                (v_command->>'command_tag') || '.' || (v_command->>'sub_command_type') = ANY (cmd_list)
            )
    ) THEN
        BEGIN
            v_command_string := logical_ddl.create_query(
                NEW.schema_name,
                v_command
            );
            EXECUTE v_command_string;
            INSERT INTO logical_ddl.applied_commands
                (source, command_string, command_id, is_failed)
                VALUES (
                    NEW.source,
                    v_command_string,
                    NEW.id,
                    false
                );
        EXCEPTION WHEN OTHERS THEN
            INSERT INTO logical_ddl.applied_commands
                (source, command_string, command_id, is_failed)
                VALUES (
                    NEW.source,
                    v_command_string,
                    NEW.id,
                    true
                );
        END;
    END IF;
    RETURN NULL;
END
$$;

CREATE TRIGGER trg_shadow 
    AFTER INSERT ON shadow_table
    FOR EACH ROW EXECUTE FUNCTION f_shadow_trigger();

ALTER TABLE shadow_table ENABLE REPLICA TRIGGER trg_shadow;

GRANT USAGE ON SCHEMA logical_ddl TO public;
