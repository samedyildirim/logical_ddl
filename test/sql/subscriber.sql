CREATE EXTENSION logical_ddl;

CREATE TABLE public.replicated_table1 (id bigint primary key, c_text text);

INSERT INTO logical_ddl.settings
    VALUES (false, 'publisher1');
INSERT INTO logical_ddl.subscribe_tablelist (source, relid)
    VALUES ('publisher1', 'public.replicated_table1'::regclass);

SET session_replication_role TO 'replica';

--Table renaming test
INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"simple","command_tag":"alter table","sub_command_type":"rename table","table_name":"replicated_table1","column_name":"","new_name":"renamed_replicated_table1","column_type":""}'
    );
SELECT c.relname, c.relnamespace::regnamespace
    FROM pg_catalog.pg_class c
    WHERE
        c.relname = 'renamed_replicated_table1' AND
        c.relnamespace = 'public'::regnamespace;

--Column renaming test
INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"simple","command_tag":"alter table","sub_command_type":"rename column","table_name":"renamed_replicated_table1","column_name":"c_text","new_name":"c_text_renamed","column_type":""}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_text_renamed'
    ORDER BY a.attnum;

--Column adding tests
INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_char","new_name":"","column_type":"character(1)"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_char'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_char20","new_name":"","column_type":"character(20)"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_char20'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_varchar","new_name":"","column_type":"character varying"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_varchar'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_varchar20","new_name":"","column_type":"character varying(20)"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_varchar20'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_text","new_name":"","column_type":"text"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_text'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_smallint","new_name":"","column_type":"smallint"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_smallint'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_int","new_name":"","column_type":"integer"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_int'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_bigint","new_name":"","column_type":"bigint"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_bigint'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_bit","new_name":"","column_type":"bit(1)"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_bit'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_bit20","new_name":"","column_type":"bit(20)"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_bit20'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_bitvarying","new_name":"","column_type":"bit varying"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_bitvarying'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_bitvarying20","new_name":"","column_type":"bit varying(20)"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_bitvarying20'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_boolean","new_name":"","column_type":"boolean"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_boolean'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_bytea","new_name":"","column_type":"bytea"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_bytea'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_cidr","new_name":"","column_type":"cidr"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_cidr'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_date","new_name":"","column_type":"date"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_date'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_timestamp","new_name":"","column_type":"timestamp without time zone"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_timestamp'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_timestamp2","new_name":"","column_type":"timestamp(2) without time zone"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_timestamp2'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_timestamptz","new_name":"","column_type":"timestamp with time zone"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_timestamptz'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_timestamptz2","new_name":"","column_type":"timestamp(2) with time zone"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_timestamptz2'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_time","new_name":"","column_type":"time without time zone"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_time'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_time2","new_name":"","column_type":"time(2) without time zone"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_time2'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_timetz","new_name":"","column_type":"time with time zone"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_timetz'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_timetz2","new_name":"","column_type":"time(2) with time zone"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_timetz2'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_interval","new_name":"","column_type":"interval"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_interval'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_interval2","new_name":"","column_type":"interval(2)"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_interval2'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_interval_hour","new_name":"","column_type":"interval hour to second"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_interval_hour'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_interval_hour2","new_name":"","column_type":"interval hour to second(2)"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_interval_hour2'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_json","new_name":"","column_type":"json"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_json'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_jsonb","new_name":"","column_type":"jsonb"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_jsonb'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_numeric","new_name":"","column_type":"numeric"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_numeric'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_numeric10","new_name":"","column_type":"numeric(10,0)"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_numeric10'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_numeric10_2","new_name":"","column_type":"numeric(10,2)"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_numeric10_2'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_decimal","new_name":"","column_type":"numeric"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_decimal'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_decimal10","new_name":"","column_type":"numeric(10,0)"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_decimal10'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_decimal10_2","new_name":"","column_type":"numeric(10,2)"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_decimal10_2'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_real","new_name":"","column_type":"real"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_real'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_double_precision","new_name":"","column_type":"double precision"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_double_precision'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_money","new_name":"","column_type":"money"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_money'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_point","new_name":"","column_type":"point"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_point'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_line","new_name":"","column_type":"line"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_line'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_lseg","new_name":"","column_type":"lseg"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_lseg'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_box","new_name":"","column_type":"box"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_box'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_path","new_name":"","column_type":"path"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_path'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_polygon","new_name":"","column_type":"polygon"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_polygon'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_circle","new_name":"","column_type":"circle"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_circle'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_inet","new_name":"","column_type":"inet"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_inet'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_macaddr","new_name":"","column_type":"macaddr"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_macaddr'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_macaddr8","new_name":"","column_type":"macaddr8"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_macaddr8'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_tsvector","new_name":"","column_type":"tsvector"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_tsvector'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_tsquery","new_name":"","column_type":"tsquery"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_tsquery'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_uuid","new_name":"","column_type":"uuid"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_uuid'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_xml","new_name":"","column_type":"xml"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_xml'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_int4range","new_name":"","column_type":"int4range"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_int4range'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_int8range","new_name":"","column_type":"int8range"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_int8range'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_numrange","new_name":"","column_type":"numrange"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_numrange'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_tsrange","new_name":"","column_type":"tsrange"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_tsrange'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_tstzrange","new_name":"","column_type":"tstzrange"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_tstzrange'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_daterange","new_name":"","column_type":"daterange"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_daterange'
    ORDER BY a.attnum;

--Column data type changing tests
INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"alter column type","table_name":"renamed_replicated_table1","column_name":"c_char","new_name":"","column_type":"character varying(20)"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_char'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"alter column type","table_name":"renamed_replicated_table1","column_name":"c_varchar","new_name":"","column_type":"text"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_varchar'
    ORDER BY a.attnum;

--Column dropping tests
INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"drop column","table_name":"renamed_replicated_table1","column_name":"c_int8range","new_name":"","column_type":""}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = true AND
        a.attname = 'c_int8range'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"drop column","table_name":"renamed_replicated_table1","column_name":"id","new_name":"","column_type":""}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = true AND
        a.attname = 'id'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"drop column","table_name":"renamed_replicated_table1","column_name":"c_text_renamed","new_name":"","column_type":""}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = true AND
        a.attname = 'c_text_renamed'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"drop column","table_name":"renamed_replicated_table1","column_name":"c_macaddr","new_name":"","column_type":""}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = true AND
        a.attname = 'c_macaddr'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"drop column","table_name":"renamed_replicated_table1","column_name":"c_text","new_name":"","column_type":""}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = true AND
        a.attname = 'c_text'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"drop column","table_name":"renamed_replicated_table1","column_name":"c_bigint","new_name":"","column_type":""}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = true AND
        a.attname = 'c_bigint'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"drop column","table_name":"renamed_replicated_table1","column_name":"c_jsonb","new_name":"","column_type":""}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = true AND
        a.attname = 'c_jsonb'
    ORDER BY a.attnum;

--Multiple subcommand in one alter table command
INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_msc_text","new_name":"","column_type":"text"}'
    ),
    (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_msc_int","new_name":"","column_type":"integer"}'
    ),
    (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_msc_bigint","new_name":"","column_type":"bigint"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname LIKE 'c_msc%'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"drop column","table_name":"renamed_replicated_table1","column_name":"c_msc_int","new_name":"","column_type":""}'
    ),
    (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_msc_timestamp","new_name":"","column_type":"timestamp without time zone"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        (a.attisdropped, a.attname) IN (
            (true, 'c_msc_int'),
            (false, 'c_msc_timestamp')
        )
    ORDER BY a.attnum;

--Column adding tests with array data type
INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_bitvarying_arr","new_name":"","column_type":"bit varying[]"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_bitvarying_arr'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_bigint_arr","new_name":"","column_type":"bigint[]"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_bigint_arr'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_varchar_arr","new_name":"","column_type":"character varying[]"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_varchar_arr'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_varchar80_arr","new_name":"","column_type":"character varying(80)[]"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_varchar80_arr'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_numrange_arr","new_name":"","column_type":"numrange[]"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_numrange_arr'
    ORDER BY a.attnum;

INSERT INTO logical_ddl.shadow_table (source, schema_name, command)
    VALUES (
        'publisher1',
        'public',
        '{"command_type":"alter table","command_tag":"alter table","sub_command_type":"add column","table_name":"renamed_replicated_table1","column_name":"c_numeric10_2_arr","new_name":"","column_type":"numeric(10,2)[]"}'
    );
SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
    FROM pg_catalog.pg_attribute a
    WHERE
        a.attrelid = 'public.renamed_replicated_table1'::regclass AND
        a.attisdropped = false AND
        a.attname = 'c_numeric10_2_arr'
    ORDER BY a.attnum;

--List of applied commands
SELECT source, command_string, is_failed
    FROM logical_ddl.applied_commands
    ORDER BY id;

DROP EXTENSION logical_ddl CASCADE;
DROP TABLE IF EXISTS public.renamed_replicated_table1;
DROP TABLE IF EXISTS public.replicated_table1;
