#include "postgres.h"
#include "funcapi.h"
#include "miscadmin.h"


#include "catalog/pg_type.h"
#include "tcop/deparse_utility.h"
#include "tcop/utility.h"
#include "utils/builtins.h"
#include "nodes/parsenodes.h"




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
 *      --query text              --generated query for ddl
 */


/*
 * issues
 *  -interval type with field or precision
 *  -I haven't tested geometric types, enumerated types yet
 *  -array types
 *  -composite types
 *  -range types
 * 
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
logical_ddl_altertable(CollectedCommand *, Tuplestorestate  *, AttInMetadata *);

static void
logical_ddl_at_addcolumn(ColumnDef *, char **);

static void
logical_ddl_at_dropcolumn(ColumnDef *, char **);

static void
logical_ddl_at_altercolumn_settype(ColumnDef *, char **);

static char*
logical_ddl_relation2name(RangeVar *);

static char*
logical_ddl_get_datatype(TypeName *);

static char*
logical_ddl_get_columnname(AlterTableCmd *);


PG_MODULE_MAGIC;
PG_FUNCTION_INFO_V1(logical_ddl_deparse);

Datum
logical_ddl_deparse(PG_FUNCTION_ARGS)
{
    CollectedCommand *cmd = (CollectedCommand *) PG_GETARG_POINTER(0);
    
    //taken from adminpack.c
    ReturnSetInfo   *rsinfo = (ReturnSetInfo *) fcinfo->resultinfo;
    bool            randomAccess;
    TupleDesc       tupdesc;
    MemoryContext   oldcontext;
    Tuplestorestate *tupstore;
    AttInMetadata   *attinmeta;
    
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
    
    tupdesc = CreateTemplateTupleDesc(7);
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
    //TupleDescInitEntry(tupdesc, (AttrNumber) 8, "query",
    //                   TEXTOID, -1, 0);
    
    randomAccess = (rsinfo->allowedModes & SFRM_Materialize_Random) != 0;
    tupstore = tuplestore_begin_heap(randomAccess, false, work_mem);
    rsinfo->returnMode = SFRM_Materialize;
    rsinfo->setResult  = tupstore;
    rsinfo->setDesc    = tupdesc;
    
    MemoryContextSwitchTo(oldcontext);
    
    attinmeta = TupleDescGetAttInMetadata(tupdesc);
    
    switch (cmd->type)
    {
        case SCT_Simple:
            logical_ddl_simple(cmd,tupstore,attinmeta);
            break;
        case SCT_AlterTable:
            logical_ddl_altertable(cmd,tupstore,attinmeta);
            break;
        default:
            break;
    }
    
    return (Datum) 0;
}


static void
logical_ddl_simple(CollectedCommand *cmd,
                   Tuplestorestate  *tupstore,
                   AttInMetadata    *attinmeta)
{
    RenameStmt  *subcmd;
    char        *values[7];
    HeapTuple   tuple;
    
    values[0] = NULL;
    
    if(IsA(cmd->parsetree,RenameStmt)){
        subcmd = castNode(RenameStmt, cmd->parsetree);
        logical_ddl_rename_stmt(subcmd,values);
        
        if(values[0] != NULL){ //_TODO_ //check return value
            tuple = BuildTupleFromCStrings(attinmeta, values);
            tuplestore_puttuple(tupstore, tuple);
        }
    }
}

static void
logical_ddl_rename_stmt(RenameStmt  *subcmd,
                        char        **values)
{
    switch (subcmd->renameType)
    {
        case OBJECT_COLUMN:
        case OBJECT_ATTRIBUTE:
            logical_ddl_renamecolumn(subcmd,values);
            break;
        case OBJECT_TABLE:
            logical_ddl_renametable(subcmd,values);
            break;
        default:
            break;
    }
    
    return;
}

static void
logical_ddl_renamecolumn(RenameStmt *subcmd,
                            char    **values)
{
    values[0] = "simple";
    values[1] = "alter table";
    values[2] = "rename column";
    
    values[3] = logical_ddl_relation2name(subcmd->relation);
        
    if(subcmd->subname != NULL)
    {
        values[4] = subcmd->subname;
    }
    else
    {
        //_TODO_ //assert error
    }
    
    if(subcmd->newname != NULL)
    {
        values[5] = subcmd->newname;
    }
    else
    {
        //_TODO_ //assert error
    }
    
    values[6] = "";
    
//    values[7] = psprintf("ALTER TABLE %s RENAME COLUMN %s TO %s;",
//                            values[3], values[4], values[5]
//                        ); // ALTER TABLE values[3] RENAME COLUMN values[4] TO values[5];
    
    return;
}

static void
logical_ddl_renametable(RenameStmt  *subcmd,
                            char    **values)
{
    values[0] = "simple";
    values[1] = "alter table";
    values[2] = "rename table";
    
    values[3] = logical_ddl_relation2name(subcmd->relation);

    values[4] = "";
    
    if(subcmd->newname != NULL)
    {
        values[5] = subcmd->newname;
    }
    else
    {
        //_TODO_ //assert error
    }
    
    values[6] = "";
    
//    values[7] = psprintf("ALTER TABLE %s RENAME TO %s;",
//                            values[3], values[5]
//                        ); // ALTER TABLE values[3] RENAME TO values[5];
    
    return;
}


static void
logical_ddl_altertable(CollectedCommand  *cmd,
                        Tuplestorestate  *tupstore,
                        AttInMetadata    *attinmeta)
{
    ListCell   *cell;
    AlterTableStmt *atstmt;
    char *table_name;
    
    if(IsA(cmd->parsetree,AlterTableStmt))
    {
        atstmt     = castNode(AlterTableStmt,cmd->parsetree);
        table_name = logical_ddl_relation2name(atstmt->relation);
    }
    else
        return;
    
    foreach(cell, cmd->d.alterTable.subcmds)
    {
        CollectedATSubcmd *sub = lfirst(cell);
        AlterTableCmd   *subcmd = castNode(AlterTableCmd, sub->parsetree);
        char            *values[7];
        HeapTuple       tuple;
        ColumnDef       *column;
        
        values[0] = NULL;
        values[3] = table_name;
        values[4] = logical_ddl_get_columnname(subcmd);
        
        column = castNode(ColumnDef,subcmd->def);
        
        switch (subcmd->subtype)
        {
            case AT_AddColumn:
                logical_ddl_at_addcolumn(column, values);
                break;
            case AT_DropColumn:
                logical_ddl_at_dropcolumn(column, values);
                break;
            case AT_AlterColumnType:
                logical_ddl_at_altercolumn_settype(column, values);
                break;
            default:
                break;
        }
        
        if(values[0] != NULL){ //_TODO_ //check return value
            tuple     = BuildTupleFromCStrings(attinmeta, values);
            tuplestore_puttuple(tupstore, tuple);
        }
    }
    
    return;
}



static void
logical_ddl_at_addcolumn(ColumnDef *column, char **values)
{
    values[0] = "alter table";
    values[1] = "alter table";
    values[2] = "add column";
    
    values[5] = "";
    values[6] = logical_ddl_get_datatype(column->typeName);
//    values[7] = psprintf("ALTER TABLE %s ADD COLUMN %s %s;",values[3],
//                            values[4],values[6]);
    
}


static void
logical_ddl_at_dropcolumn(ColumnDef *column, char **values)
{
    values[0] = "alter table";
    values[1] = "alter table";
    values[2] = "drop column";
    
    values[5] = "";
    values[6] = "";
//    values[7] = psprintf("ALTER TABLE %s DROP COLUMN %s;",values[3],
//                            values[4]);
}


static void
logical_ddl_at_altercolumn_settype(ColumnDef *column, char **values)
{
    
    values[0] = "alter table";
    values[1] = "alter table";
    values[2] = "alter column type";
    
    values[5] = "";
    values[6] = logical_ddl_get_datatype(column->typeName);
//    values[7] = psprintf("ALTER TABLE %s ALTER COLUMN %s TYPE %s;",
//                            values[3],values[4],values[6]);
}

static char*
logical_ddl_relation2name(RangeVar *relation)
{
    char *table_name = NULL;
    /*if(relation->schemaname != NULL 
        && relation->relname != NULL)
    {
        table_name = psprintf("%s.%s", relation->schemaname,
                                relation->relname
                            );
    }
    else*/ if (relation->relname != NULL)
    {
        table_name = relation->relname;
    }
    else
    {
        //_TODO_ //assert error
    }
    
    return table_name;
}

static char*
logical_ddl_get_columnname(AlterTableCmd *subcmd)
{
    ColumnDef *column;
    if(subcmd->name != NULL)
    {
        return subcmd->name;
    }
    else
    {
        column = castNode(ColumnDef, subcmd->def);
        return column->colname;
    }
}

static char*
logical_ddl_get_datatype(TypeName *typeName)
{
    char *type_name = "";
    char *type_mode = NULL;
    char *result;
    ListCell *l;
    
    if(typeName->typeOid != InvalidOid){
        bits16 flags = FORMAT_TYPE_TYPEMOD_GIVEN | FORMAT_TYPE_ALLOW_INVALID;
        result = format_type_extended(typeName->typeOid, typeName->typemod, flags);
        return result;
    }
    
    switch (list_length(typeName->names))
    {
        case 1:
            type_name = strVal(linitial(typeName->names));
            break;
        case 2:
            type_name = strVal(lsecond(typeName->names));
            break;
        case 3:
            type_name = strVal(lthird(typeName->names));
            break;
        case 4:
            type_name = strVal(lfourth(typeName->names));
            break;
    }
    
    
    if (typeName->typmods == NIL)
    {
        type_mode = psprintf("%ld", (long) typeName->typemod);
    }
    else
    {
        foreach(l,typeName->typmods)
        {
            Node *tm = (Node *) lfirst(l);
            char *typmod = NULL;
            
            if(IsA(tm, A_Const))
            {
                A_Const *val = (A_Const *) tm;
                
                if (IsA(&val->val, Integer))
                {
                    typmod = psprintf("%d", intVal(&val->val));
                }
                else if (IsA(&val->val, String) || IsA(&val->val, Float))
                {
                    typmod = strVal(&val->val);
                }
            }
            
            if(typmod != NULL)
            {
                if(type_mode == NULL)
                    type_mode = typmod;
                else
                    type_mode = psprintf("%s,%s",type_mode,typmod);
            }
        }
    }

    if(strcmp(type_mode,"-1") == 0)
        result = type_name;
    else
        result = psprintf("%s(%s)",type_name,type_mode);
    
    return result;
}
