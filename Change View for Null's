SELECT 
    '-------------------------------------'  + CHAR(13) + CHAR(10) +
    'DROP ' + IIF(o.type = 'P', 'PROCEDURE', 'VIEW') + ' [' + s.name + '].[' + o.name + ']'  + CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10) +
    'CREATE VIEW ['+s.name+'].['+o.name+'] AS' + CHAR(13) + CHAR(10) +
    'SELECT '+(SELECT STRING_AGG(CONVERT(NVARCHAR(MAX),CONCAT(COLUMN_NAME,' = CAST(NULL AS ',I.DATA_TYPE,')')), ',') FROM INFORMATION_SCHEMA.COLUMNS AS i WHERE o.name = i.TABLE_NAME AND s.name = i.TABLE_SCHEMA)+ CHAR(13) + CHAR(10) +
    'GO' + CHAR(13) + CHAR(10)
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE o.[type] = ('V')
AND concat('[',s.name ,'].','[',o.name,']') in (select ViewName COLLATE DATABASE_DEFAULT  from Maintenance.Lookup_ViewScripts ) or o.name like 'rv_%'
