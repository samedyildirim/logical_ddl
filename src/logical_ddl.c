#include "postgres.h"
#include "funcapi.h"
#include "miscadmin.h"
#include "catalog/pg_type.h"
#include "tcop/deparse_utility.h"
#include "tcop/utility.h"
#include "utils/builtins.h"
#include "nodes/parsenodes.h"
#include "parser/parse_type.h"
#include "utils/syscache.h"

/*
 * Returning
 *      command_type text,      --'simple' or 'alter table'
 *      command_tag text,       --'alter table'
 *      sub_command_type text,  --'add column', 'drop column', 'rename table', 'rename column',
 *                                'alter column type'
 *      table_name text,        --name of target table
 *      column_name text,       --name of target column, empty string if table is renamed
 *      new_name text,          --new column or table name,
 *                                  empty string if it is not a column rename or a table rename
 *      column_type text        --data type of new column or new type of existing column
 */

static void
logical_ddl_simple(CollectedCommand *, Tuplestorestate *, AttInMetadata *);

static void
logical_ddl_rename_stmt(RenameStmt *, char **);

static void
logical_ddl_renamecolumn(RenameStmt *, char **);

static void
logical_ddl_renametable(RenameStmt *, char **);

static void
logical_ddl_altertable(CollectedCommand *, Tuplestorestate *, AttInMetadata *);

static void
logical_ddl_at_addcolumn(ColumnDef *, char **);

static void
logical_ddl_at_dropcolumn(ColumnDef *, char **);

static void
logical_ddl_at_altercolumn_settype(ColumnDef *, char **);

static char *logical_ddl_get_datatype(TypeName *);

static char *logical_ddl_get_columnname(AlterTableCmd *);


PG_MODULE_MAGIC;
PG_FUNCTION_INFO_V1(logical_ddl_deparse);

Datum
logical_ddl_deparse(PG_FUNCTION_ARGS)
{
    CollectedCommand *cmd = (CollectedCommand *) PG_GETARG_POINTER(0);

    /* taken from adminpack.c */
    ReturnSetInfo *rsinfo = (ReturnSetInfo *) fcinfo->resultinfo;
    bool        randomAccess;
    TupleDesc   tupdesc;
    MemoryContext oldcontext;
    Tuplestorestate *tupstore;
    AttInMetadata *attinmeta;

    /* check to see if caller supports us returning a tuplestore */
    if (rsinfo == NULL || !IsA(rsinfo, ReturnSetInfo))
        ereport(ERROR,
                (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
                errmsg("set-valued function called in context that cannot accept a set")));
    if (!(rsinfo->allowedModes & SFRM_Materialize))
        ereport(ERROR,
                (errcode(ERRCODE_SYNTAX_ERROR),
                errmsg("materialize mode required, but it is not allowed in this context")));

    /* The tupdesc and tuplestore must be created in ecxt_per_query_memory */
    oldcontext = MemoryContextSwitchTo(rsinfo->econtext->ecxt_per_query_memory);

#if PG_VERSION_NUM >= 120000
    tupdesc = CreateTemplateTupleDesc(7);
#else
    tupdesc = CreateTemplateTupleDesc(7, false);
#endif
    TupleDescInitEntry(tupdesc, (AttrNumber) 1, "command_type",
                       TEXTOID, -1, 0);
    TupleDescInitEntry(tupdesc, (AttrNumber) 2, "command_tag",
                       TEXTOID, -1, 0);
    TupleDescInitEntry(tupdesc, (AttrNumber) 3, "sub_command_type",
                       TEXTOID, -1, 0);
    TupleDescInitEntry(tupdesc, (AttrNumber) 4, "table_name",
                       TEXTOID, -1, 0);
    TupleDescInitEntry(tupdesc, (AttrNumber) 5, "column_name",
                       TEXTOID, -1, 0);
    TupleDescInitEntry(tupdesc, (AttrNumber) 6, "new_name",
                       TEXTOID, -1, 0);
    TupleDescInitEntry(tupdesc, (AttrNumber) 7, "column_type",
                       TEXTOID, -1, 0);

    randomAccess = (rsinfo->allowedModes & SFRM_Materialize_Random) != 0;
    tupstore = tuplestore_begin_heap(randomAccess, false, work_mem);
    rsinfo->returnMode = SFRM_Materialize;
    rsinfo->setResult = tupstore;
    rsinfo->setDesc = tupdesc;

    MemoryContextSwitchTo(oldcontext);

    attinmeta = TupleDescGetAttInMetadata(tupdesc);

    switch (cmd->type)
    {
        case SCT_Simple:
            logical_ddl_simple(cmd, tupstore, attinmeta);
            break;
        case SCT_AlterTable:
            logical_ddl_altertable(cmd, tupstore, attinmeta);
            break;
        default:
            break;
    }

    return (Datum) 0;
}

static void
logical_ddl_simple(CollectedCommand *cmd,
                   Tuplestorestate *tupstore,
                   AttInMetadata *attinmeta)
{
    RenameStmt *subcmd;
    char       *values[7];
    HeapTuple  tuple;

    values[0] = NULL;

    if (IsA(cmd->parsetree, RenameStmt))
    {
        subcmd = castNode(RenameStmt, cmd->parsetree);
        logical_ddl_rename_stmt(subcmd, values);

        if (values[0] != NULL)
        {
            /* _TODO_ check return value */
            tuple = BuildTupleFromCStrings(attinmeta, values);
            tuplestore_puttuple(tupstore, tuple);
        }
    }
}

static void
logical_ddl_rename_stmt(RenameStmt *subcmd,
                        char **values)
{
    switch (subcmd->renameType)
    {
        case OBJECT_COLUMN:
        case OBJECT_ATTRIBUTE:
            logical_ddl_renamecolumn(subcmd, values);
            break;
        case OBJECT_TABLE:
            logical_ddl_renametable(subcmd, values);
            break;
        default:
            break;
    }
}

static void
logical_ddl_renamecolumn(RenameStmt *subcmd,
                         char **values)
{
    values[0] = "simple";
    values[1] = "alter table";
    values[2] = "rename column";
    values[3] = subcmd->relation->relname;
    values[4] = subcmd->subname;
    values[5] = subcmd->newname;
    values[6] = "";
}

static void
logical_ddl_renametable(RenameStmt *subcmd,
                        char **values)
{
    values[0] = "simple";
    values[1] = "alter table";
    values[2] = "rename table";
    values[3] = subcmd->relation->relname;
    values[4] = "";
    values[5] = subcmd->newname;
    values[6] = "";
}

static void
logical_ddl_altertable(CollectedCommand *cmd,
                       Tuplestorestate *tupstore,
                       AttInMetadata *attinmeta)
{
    ListCell   *cell;
    AlterTableStmt *atstmt;
    char       *table_name;

    if (IsA(cmd->parsetree, AlterTableStmt))
    {
        atstmt = castNode(AlterTableStmt, cmd->parsetree);
        table_name = atstmt->relation->relname;
    }
    else
        return;

    foreach(cell, cmd->d.alterTable.subcmds)
    {
        CollectedATSubcmd *sub = lfirst(cell);
        AlterTableCmd *subcmd = castNode(AlterTableCmd, sub->parsetree);
        char       *values[7];
        HeapTuple   tuple;
        ColumnDef  *column;

        values[0] = NULL;
        values[3] = table_name;
        values[4] = logical_ddl_get_columnname(subcmd);

        column = castNode(ColumnDef, subcmd->def);

        switch (subcmd->subtype)
        {
            case AT_AddColumn:
#if PG_VERSION_NUM < 160000
            case AT_AddColumnRecurse:
#endif
                logical_ddl_at_addcolumn(column, values);
                break;
            case AT_DropColumn:
#if PG_VERSION_NUM < 160000
            case AT_DropColumnRecurse:
#endif
                logical_ddl_at_dropcolumn(column, values);
                break;
            case AT_AlterColumnType:
                logical_ddl_at_altercolumn_settype(column, values);
                break;
            default:
                break;
        }

        if (values[0] != NULL)
        { 
            /* _TODO_ check return value */
            tuple = BuildTupleFromCStrings(attinmeta, values);
            tuplestore_puttuple(tupstore, tuple);
        }
    }
}

static void
logical_ddl_at_addcolumn(ColumnDef *column, char **values)
{
    values[0] = "alter table";
    values[1] = "alter table";
    values[2] = "add column";

    values[5] = "";
    values[6] = logical_ddl_get_datatype(column->typeName);
}

static void
logical_ddl_at_dropcolumn(ColumnDef *column, char **values)
{
    values[0] = "alter table";
    values[1] = "alter table";
    values[2] = "drop column";

    values[5] = "";
    values[6] = "";
}

static void
logical_ddl_at_altercolumn_settype(ColumnDef *column, char **values)
{
    values[0] = "alter table";
    values[1] = "alter table";
    values[2] = "alter column type";

    values[5] = "";
    values[6] = logical_ddl_get_datatype(column->typeName);
}

static char *
logical_ddl_get_columnname(AlterTableCmd *subcmd)
{
    ColumnDef  *column;

    if (subcmd->name != NULL)
    {
        return subcmd->name;
    }
    else
    {
        column = castNode(ColumnDef, subcmd->def);
        return column->colname;
    }
}

static char *
logical_ddl_get_datatype(TypeName *typeName)
{
    int32       typemod;
	Oid	        typeOid;
	HeapTuple   tup;
    bits16      flags = FORMAT_TYPE_TYPEMOD_GIVEN | FORMAT_TYPE_ALLOW_INVALID;

    if (typeName->typeOid != InvalidOid)
    {
        typeOid = typeName->typeOid;
        typemod = typeName->typemod;
    }
    else
    {
        tup = LookupTypeName(NULL, typeName, &typemod, false);
        if (tup == NULL)
            ereport(ERROR,
                    (errcode(ERRCODE_UNDEFINED_OBJECT),
                     errmsg("type \"%s\" does not exist",
                            TypeNameToString(typeName))));
        typeOid = typeTypeId(tup);
        ReleaseSysCache(tup);
    }

    return format_type_extended(typeOid, typemod, flags);
}
