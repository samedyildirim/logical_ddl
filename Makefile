PGFILEDESC = "logical_ddl - ddl replication over logical replication"
EXTENSION = logical_ddl

MODULES = src/logical_ddl

DATA = $(wildcard sql/*.sql)
TESTS = $(wildcard test/sql/*.sql)
DOCS = $(wildcard doc/*.md)

REGRESS = publisher subscriber
REGRESS_OPTS = --inputdir=test

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
