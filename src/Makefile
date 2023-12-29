MODULE_big = logical_ddl
OBJS = logical_ddl.o

EXTENSION = logical_ddl
DATA = logical_ddl--0.1.sql
PGFILEDESC = "logical_ddl - ddl replication over logical replication"

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
