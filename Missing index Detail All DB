SELECT 
migs.user_seeks as [Estimated Index Uses],
migs.avg_user_impact [Estimated Index Impact %],
migs.avg_total_user_cost[Estimated Avg Query Cost], 
db_name(mid.database_id) AS DatabaseID,
OBJECT_SCHEMA_NAME (mid.OBJECT_ID,mid.database_id) AS [SchemaName],
OBJECT_NAME(mid.OBJECT_ID,mid.database_id) AS [TableName],
'CREATE INDEX [IX_' + OBJECT_NAME(mid.OBJECT_ID,mid.database_id) + '_'
+ REPLACE(REPLACE(REPLACE(ISNULL(mid.equality_columns,''),', ','_'),'[',''),']','') 
+ CASE
WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL 
THEN '_'
ELSE ''
  END
+ REPLACE(REPLACE(REPLACE(ISNULL(mid.inequality_columns,''),', ','_'),'[',''),']','')
+ ']'
+ ' ON ' + mid.statement
+ ' (' + ISNULL (mid.equality_columns,'')
+ CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns 
IS NOT NULL THEN ',' ELSE
'' END
+ ISNULL (mid.inequality_columns, '')
+ ')'
+ ISNULL (' INCLUDE (' + mid.included_columns + ') WITH (MAXDOP =?, FILLFACTOR=?, ONLINE=?, SORT_IN_TEMPDB=?);', '') AS [Create TSQL],
mid.equality_columns, 
mid.inequality_columns, 
mid.included_columns,
migs.unique_compiles,
migs.last_user_seek
FROM sys.dm_db_missing_index_group_stats AS migs WITH (NOLOCK)
INNER JOIN sys.dm_db_missing_index_groups AS mig WITH (NOLOCK) ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details AS mid WITH (NOLOCK) ON mig.index_handle = mid.index_handle
ORDER BY [Estimated Index Uses] DESC OPTION (RECOMPILE);
