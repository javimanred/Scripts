--SET NOCOUNT ON
/*
Legacy into	26
Evaluations into	27
Main into	28
Reports into	29
Scorecards	30
Security into	31
Staging	32
*/

DECLARE @table_name SYSNAME, 
		@object_name SYSNAME,
		@Database_id NVARCHAR(2),
		@object_id INT,
		@SQL NVARCHAR(MAX) = '',
		@Database_name NVARCHAR(50)

SET @Database_id = 32
SET @Database_name = CASE @Database_id 
						WHEN 26 THEN '[PSQL-DWH-DATA01].Compas_ApexSQL'
						WHEN 27 THEN '[PSQL-DWH-DATA01].Compas_ApexSQLEvaluations'
						WHEN 28 THEN '[PSQL-DWH-DATA01].Compas_ApexSQLMain'
						WHEN 29 THEN '[PSQL-DWH-DATA01].Compas_ApexSQLReports'
						WHEN 30 THEN '[PSQL-DWH-DATA01].Compas_ApexSQLScorecards'
						WHEN 31 THEN '[PSQL-DWH-DATA01].Compas_ApexSQLSecurity'
						WHEN 32 THEN '[PSQL-DWH-DATA01].Compas_ApexSQLStaging'
						END

--Create Temp Tables

DROP TABLE IF EXISTS #sysobjects
DROP TABLE IF EXISTS #sysindex
DROP TABLE IF EXISTS #sysfk
DROP TABLE IF EXISTS #createtable
DROP TABLE IF EXISTS #syspk
DROP TABLE IF EXISTS #CreateIndex
DROP TABLE IF EXISTS #sysfk2
DROP TABLE IF EXISTS #sysindex2

CREATE TABLE #sysobjects(objName [nvarchar](1029),object_id int)

SET @SQL =  'SELECT ''['' + s.name + ''].['' + o.name + '']'' as objName, o.[object_id]
FROM '+@Database_name+'.sys.objects o WITH (NOWAIT)
JOIN '+@Database_name+'.sys.schemas s WITH (NOWAIT) ON o.[schema_id] = s.[schema_id]
WHERE s.name + ''.'' + o.name  IN (SELECT CONCAT(SchemaName,''.'',ObjectName)
FROM [PSQL-DWH-DATA01].[ApexSQL].[ApexSQL_SourceControl].[Objects] AS Apex
WHERE Apex.ObjectType = ''TABLE'' AND  Apex.DatabaseID = '+@Database_id+' AND Apex.IsStaticData = 1 AND
Apex.ObjectName COLLATE DATABASE_DEFAULT 
 NOT IN (SELECT name from sys.tables) )
    AND o.[type] = ''U''
    AND o.is_ms_shipped = 0'

INSERT INTO #sysobjects
EXEC (@SQL)
SET @SQL = ''

SET @SQL = 'SELECT 
      ic.[object_id]
    , ic.index_id
    , ic.is_descending_key
    , ic.is_included_column
    , c.name
INTO #sysindex
FROM '+@Database_name+'.sys.index_columns ic WITH (NOWAIT)
JOIN '+@Database_name+'.sys.columns c WITH (NOWAIT) ON ic.[object_id] = c.[object_id] AND ic.column_id = c.column_id
WHERE  ic.[object_id] IN (SELECT [object_id] FROM #sysobjects)'
EXEC (@SQL)
SET @SQL = ''

SET @SQL = 'SELECT 
k.constraint_object_id, 
k.parent_object_id,
cname = c.name, 
rcname = rc.name
INTO #sysfk
FROM '+@Database_name+'.sys.foreign_key_columns k WITH (NOWAIT)
JOIN '+@Database_name+'.sys.columns rc WITH (NOWAIT) ON rc.[object_id] = k.referenced_object_id AND rc.column_id = k.referenced_column_id 
JOIN '+@Database_name+'.sys.columns c WITH (NOWAIT) ON c.[object_id] = k.parent_object_id AND c.column_id = k.parent_column_id
WHERE k.parent_object_id IN (SELECT [object_id] FROM #sysobjects)'
EXEC (@SQL)
SET @SQL = ''

SET @SQL = 'SELECT c.object_id,c.name columnname, c.is_computed, cc.[definition],tp.name,c.max_length, c.scale, c.[precision], c.collation_name, c.is_nullable, dc.[definition] as definitiondc,ic.is_identity,ic.seed_value,ic.increment_value,c.column_id
INTO #createtable
FROM '+@Database_name+'.sys.columns c WITH (NOWAIT)
JOIN '+@Database_name+'.sys.types tp WITH (NOWAIT) ON c.user_type_id = tp.user_type_id
LEFT JOIN '+@Database_name+'.sys.computed_columns cc WITH (NOWAIT) ON c.[object_id] = cc.[object_id] AND c.column_id = cc.column_id
LEFT JOIN '+@Database_name+'.sys.default_constraints dc WITH (NOWAIT) ON c.default_object_id != 0 AND c.[object_id] = dc.parent_object_id AND c.column_id = dc.parent_column_id
LEFT JOIN '+@Database_name+'.sys.identity_columns ic WITH (NOWAIT) ON c.is_identity = 1 AND c.[object_id] = ic.[object_id] AND c.column_id = ic.column_id
WHERE c.[object_id] IN (SELECT [object_id] FROM #sysobjects)'
EXEC (@SQL)
SET @SQL = ''

SET @SQL = 'SELECT k.unique_index_id,k.parent_object_id,k.name
INTO #syspk
FROM '+@Database_name+'.sys.key_constraints k WITH (NOWAIT)
WHERE k.parent_object_id IN (SELECT [object_id] FROM #sysobjects)
AND k.[type] = ''PK'''
EXEC (@SQL)
SET @SQL = ''

SET @SQL = 'SELECT c.name,ic.is_descending_key,ic.index_id,ic.[object_id] as objectid
INTO #CreateIndex
FROM '+@Database_name+'.sys.index_columns ic WITH (NOWAIT)
JOIN '+@Database_name+'.sys.columns c WITH (NOWAIT) ON c.[object_id] = ic.[object_id] AND c.column_id = ic.column_id
WHERE ic.is_included_column = 0
AND ic.[object_id] IN (SELECT [object_id] FROM #sysobjects)'
EXEC (@SQL)
SET @SQL = ''

SET @SQL = 'SELECT fk.update_referential_action,fk.name,fk.parent_object_id,fk.is_not_trusted,fk.[object_id],ro.[schema_id],ro.name as roname,fk.delete_referential_action
INTO #sysfk2
FROM '+@Database_name+'.sys.foreign_keys fk WITH (NOWAIT)
JOIN '+@Database_name+'.sys.objects ro WITH (NOWAIT) ON ro.[object_id] = fk.referenced_object_id
WHERE fk.parent_object_id IN (SELECT [object_id] FROM #sysobjects)'
EXEC (@SQL)
SET @SQL = ''

SET @SQL = 'SELECT i.index_id,i.is_unique,i.name,i.[object_id]
INTO #sysindex2
FROM '+@Database_name+'.sys.indexes i
WHERE  i.[object_id] IN (SELECT [object_id] FROM #sysobjects)
       AND i.is_primary_key = 0
       AND i.[type] = 2'
EXEC (@SQL)
SET @SQL = ''

DECLARE CreateStaticDataTable CURSOR 
FOR
SELECT CONCAT('[',SchemaName,'].[',ObjectName,']') objname
FROM [PSQL-DWH-DATA01].[ApexSQL].[ApexSQL_SourceControl].[Objects] AS Apex
WHERE Apex.ObjectType = 'TABLE' AND  Apex.DatabaseID = @Database_id AND Apex.IsStaticData = 1 AND
Apex.ObjectName COLLATE DATABASE_DEFAULT  NOT IN (SELECT name from sys.tables) 
FOR READ ONLY 
OPEN CreateStaticDataTable
FETCH NEXT FROM CreateStaticDataTable
INTO @table_name
WHILE @@FETCH_STATUS = 0  
BEGIN 

SELECT 
      @object_name = objName
    , @object_id = [object_id]
FROM #sysobjects
WHERE objName = @table_name

;WITH index_column AS 
(
    SELECT 
          [object_id]
        , index_id
        , is_descending_key
        , is_included_column
        , name
    FROM #sysindex
    WHERE [object_id] = @object_id
),
fk_columns AS 
(
     SELECT 
          constraint_object_id
        , cname 
        , rcname
    FROM #sysfk
    WHERE parent_object_id = @object_id
)

SELECT @SQL = 'CREATE TABLE ' + @object_name + CHAR(13) + '(' + CHAR(13) + STUFF((
    SELECT CHAR(9) + ', [' + columnname + '] ' + 
        CASE WHEN is_computed = 1
            THEN 'AS ' + [definition] 
            ELSE UPPER(name) + 
                CASE WHEN name IN ('varchar', 'char', 'varbinary', 'binary', 'text')
                       THEN '(' + CASE WHEN max_length = -1 THEN 'MAX' ELSE CAST(max_length AS VARCHAR(5)) END + ')'
                     WHEN name IN ('nvarchar', 'nchar', 'ntext')
                       THEN '(' + CASE WHEN max_length = -1 THEN 'MAX' ELSE CAST(max_length / 2 AS VARCHAR(5)) END + ')'
                     WHEN name IN ('datetime2', 'time2', 'datetimeoffset') 
                       THEN '(' + CAST(scale AS VARCHAR(5)) + ')'
                     WHEN name = 'decimal' 
                       THEN '(' + CAST([precision] AS VARCHAR(5)) + ',' + CAST(scale AS VARCHAR(5)) + ')'
                    ELSE ''
                END + 
                CASE WHEN collation_name IS NOT NULL THEN ' COLLATE ' + collation_name ELSE '' END +
                CASE WHEN is_nullable = 1 THEN ' NULL' ELSE ' NOT NULL' END +
                CASE WHEN [definitiondc] IS NOT NULL THEN ' DEFAULT' + [definitiondc] ELSE '' END + 
                CASE WHEN is_identity = 1 THEN ' IDENTITY(' + CAST(ISNULL(seed_value, '0') AS CHAR(1)) + ',' + CAST(ISNULL(increment_value, '1') AS CHAR(1)) + ')' ELSE '' END 
        END + CHAR(13)
    FROM #createtable
    WHERE [object_id] = @object_id
    ORDER BY column_id
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, CHAR(9) + ' ')
    + ISNULL((SELECT CHAR(9) + ', CONSTRAINT [' + k.name + '] PRIMARY KEY (' + 
                    (SELECT STUFF((
                         SELECT ', [' + name + '] ' + CASE WHEN is_descending_key = 1 THEN 'DESC' ELSE 'ASC' END
                         FROM #CreateIndex ic
                         WHERE ic.objectid = k.parent_object_id AND ic.index_id = k.unique_index_id     
                         FOR XML PATH(N''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, ''))
            + ')' + CHAR(13)
            FROM #syspk k WITH (NOWAIT)
            WHERE k.parent_object_id = @object_id ), '') + ')'  + CHAR(13)
    + ISNULL((SELECT (
        SELECT CHAR(13) +
             'ALTER TABLE ' + @object_name + ' WITH' 
            + CASE WHEN fk.is_not_trusted = 1 
                THEN ' NOCHECK' 
                ELSE ' CHECK' 
              END + 
              ' ADD CONSTRAINT [' + fk.name  + '] FOREIGN KEY(' 
              + STUFF((
                SELECT ', [' + k.cname + ']'
                FROM fk_columns k
                WHERE k.constraint_object_id = fk.[object_id]
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '')
               + ')' +
              ' REFERENCES [' + SCHEMA_NAME(fk.[schema_id]) + '].[' + fk.roname + '] ('
              + STUFF((
                SELECT ', [' + k.rcname + ']'
                FROM fk_columns k
                WHERE k.constraint_object_id = fk.[object_id]
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '')
               + ')'
            + CASE 
                WHEN fk.delete_referential_action = 1 THEN ' ON DELETE CASCADE' 
                WHEN fk.delete_referential_action = 2 THEN ' ON DELETE SET NULL'
                WHEN fk.delete_referential_action = 3 THEN ' ON DELETE SET DEFAULT' 
                ELSE '' 
              END
            + CASE 
                WHEN fk.update_referential_action = 1 THEN ' ON UPDATE CASCADE'
                WHEN fk.update_referential_action = 2 THEN ' ON UPDATE SET NULL'
                WHEN fk.update_referential_action = 3 THEN ' ON UPDATE SET DEFAULT'  
                ELSE '' 
              END 
            + CHAR(13) + 'ALTER TABLE ' + @object_name + ' CHECK CONSTRAINT [' + fk.name  + ']' + CHAR(13)
        FROM #sysfk2 fk
        WHERE fk.parent_object_id = @object_id
        FOR XML PATH(N''), TYPE).value('.', 'NVARCHAR(MAX)')), '')
    + ISNULL(((SELECT
         CHAR(13) + 'CREATE' + CASE WHEN i.is_unique = 1 THEN ' UNIQUE' ELSE '' END 
                + ' NONCLUSTERED INDEX [' + i.name + '] ON ' + @object_name + ' (' +
                STUFF((
                SELECT ', [' + c.name + ']' + CASE WHEN c.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END
                FROM index_column c
                WHERE c.is_included_column = 0
                    AND c.index_id = i.index_id
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') + ')'  
                + ISNULL(CHAR(13) + 'INCLUDE (' + 
                    STUFF((
                    SELECT ', [' + c.name + ']'
                    FROM index_column c
                    WHERE c.is_included_column = 1
                        AND c.index_id = i.index_id
                    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') + ')', '')  + CHAR(13)
        FROM #sysindex2 i WITH (NOWAIT)
        WHERE i.[object_id] = @object_id
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)')
    ), '')

PRINT @SQL
EXEC(@SQL)
FETCH NEXT FROM CreateStaticDataTable
INTO @table_name
END
CLOSE CreateStaticDataTable
DEALLOCATE CreateStaticDataTable

DECLARE InsertDataTable CURSOR
FOR
SELECT CONCAT('[',SchemaName,'].[',ObjectName,']') objname
FROM [PSQL-DWH-DATA01].[ApexSQL].[ApexSQL_SourceControl].[Objects] AS Apex
WHERE Apex.ObjectType = 'TABLE' AND  Apex.DatabaseID = @Database_id AND Apex.IsStaticData = 1 
FOR READ ONLY
OPEN InsertDataTable
FETCH NEXT FROM InsertDataTable
INTO @table_name
WHILE @@FETCH_STATUS = 0  
BEGIN 
	IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES tables WHERE OBJECTPROPERTY(OBJECT_ID(tables.TABLE_SCHEMA + '.' + tables.TABLE_NAME), 'TableHasIdentity') = 1 AND  CONCAT('[',table_schema,'].[',table_name,']') = @table_name)
	BEGIN
	DECLARE @ColumnsName nvarchar(1000)
	SELECT @ColumnsName = STRING_AGG(CONVERT(NVARCHAR(MAX),COLUMN_NAME), ',') FROM INFORMATION_SCHEMA.COLUMNS AS i WHERE  CONCAT('[',table_schema,'].[',table_name,']') = @table_name
	SET @SQL =  'SET IDENTITY_INSERT '+@table_name+' ON;'+' 
				INSERT INTO '+@table_name+'('+@ColumnsName+')'+'  
				SELECT '+@ColumnsName+' FROM '+@Database_name+'.'+@table_name+' 
				EXCEPT SELECT '+@ColumnsName+' FROM '+@table_name+' 
				SET IDENTITY_INSERT '+@table_name+' OFF;'
	PRINT (@SQL)
	EXEC (@SQL)


	END
	ELSE 
	BEGIN
	SET @SQL =  'INSERT INTO '+@table_name+' 
				SELECT * FROM '+@Database_name+'.'+@table_name+' 
				EXCEPT SELECT * FROM '+@table_name
	PRINT (@SQL)
	EXEC (@SQL)
	END

	FETCH NEXT FROM InsertDataTable
	INTO @table_name
END
CLOSE InsertDataTable
DEALLOCATE InsertDataTable
