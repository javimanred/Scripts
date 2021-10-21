--DECLARE @MainO nvarchar(100),
--		@AggrO nvarchar(100),
--		@CachO nvarchar(100),
--		@MainD nvarchar(100),
--		@AggrD nvarchar(100),
--		@CachD nvarchar(100)

--SET @MainD = ''
--SET @AggrD = ''
--SET @CachD = ''
IF @@SERVERNAME = 'TSQL-UAT-MAIN01'
BEGIN
SELECT 
    '-------------------------------------'  + CHAR(13) + CHAR(10) +
    'DROP ' + IIF(o.type = 'P', 'PROCEDURE', 'VIEW') + ' [' + s.name + '].[' + o.name + ']'  + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10) +
    REPLACE([definition],'[PSQL-ROG-MAIN01].','') + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10)
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.[type] IN ('P','V')
AND [definition] LIKE '%PSQL-ROG-MAIN01%' 
UNION ALL
SELECT 
    '-------------------------------------'  + CHAR(13) + CHAR(10) +
    'DROP ' + IIF(o.type = 'P', 'PROCEDURE', 'VIEW') + ' [' + s.name + '].[' + o.name + ']'  + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10) +
    REPLACE([definition],'[PSQL-ROG-AGGR01]','[TSQL-UAT-AGGR01]') + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10)
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.[type] IN ('P','V')
AND [definition] LIKE '%PSQL-ROG-AGGR01%' 
UNION ALL
SELECT 
    '-------------------------------------'  + CHAR(13) + CHAR(10) +
    'DROP ' + IIF(o.type = 'P', 'PROCEDURE', 'VIEW') + ' [' + s.name + '].[' + o.name + ']'  + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10) +
    REPLACE([definition],'[PSQL-ROG-CACH01]','[TSQL-UAT-CACH01]') + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10)
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.[type] IN ('P','V')
AND [definition] LIKE '%PSQL-ROG-CACH01%' 
END
IF @@SERVERNAME = 'TSQL-UAT-AGGR01'
BEGIN
SELECT 
    '-------------------------------------'  + CHAR(13) + CHAR(10) +
    'DROP ' + IIF(o.type = 'P', 'PROCEDURE', 'VIEW') + ' [' + s.name + '].[' + o.name + ']'  + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10) +
    REPLACE([definition],'[PSQL-ROG-MAIN01]','[TSQL-UAT-MAIN01]') + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10)
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.[type] IN ('P','V')
AND [definition] LIKE '%PSQL-ROG-MAIN01%' 
UNION ALL
SELECT 
    '-------------------------------------'  + CHAR(13) + CHAR(10) +
    'DROP ' + IIF(o.type = 'P', 'PROCEDURE', 'VIEW') + ' [' + s.name + '].[' + o.name + ']'  + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10) +
    REPLACE([definition],'[PSQL-ROG-AGGR01].','') + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10)
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.[type] IN ('P','V')
AND [definition] LIKE '%PSQL-ROG-AGGR01%' 
UNION ALL
SELECT 
    '-------------------------------------'  + CHAR(13) + CHAR(10) +
    'DROP ' + IIF(o.type = 'P', 'PROCEDURE', 'VIEW') + ' [' + s.name + '].[' + o.name + ']'  + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10) +
    REPLACE([definition],'[PSQL-ROG-CACH01]','[TSQL-UAT-CACH01]') + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10)
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.[type] IN ('P','V')
AND [definition] LIKE '%PSQL-ROG-CACH01%' 
END

IF @@SERVERNAME = 'USQL-UAT-CACH01'
BEGIN
SELECT 
    '-------------------------------------'  + CHAR(13) + CHAR(10) +
    'DROP ' + IIF(o.type = 'P', 'PROCEDURE', 'VIEW') + ' [' + s.name + '].[' + o.name + ']'  + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10) +
    REPLACE([definition],'[PSQL-ROG-MAIN01]','[TSQL-UAT-MAIN01]') + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10)
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.[type] IN ('P','V')
AND [definition] LIKE '%PSQL-ROG-MAIN01%' 
UNION ALL
SELECT 
    '-------------------------------------'  + CHAR(13) + CHAR(10) +
    'DROP ' + IIF(o.type = 'P', 'PROCEDURE', 'VIEW') + ' [' + s.name + '].[' + o.name + ']'  + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10) +
    REPLACE([definition],'[PSQL-ROG-AGGR01]','[TSQL-UAT-AGGR01]') + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10)
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.[type] IN ('P','V')
AND [definition] LIKE '%PSQL-ROG-AGGR01%' 
UNION ALL
SELECT 
    '-------------------------------------'  + CHAR(13) + CHAR(10) +
    'DROP ' + IIF(o.type = 'P', 'PROCEDURE', 'VIEW') + ' [' + s.name + '].[' + o.name + ']'  + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10) +
    REPLACE([definition],'[PSQL-ROG-CACH01].','') + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10)
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.[type] IN ('P','V')
AND [definition] LIKE '%PSQL-ROG-CACH01%' 
END
