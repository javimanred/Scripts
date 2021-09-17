SELECT 
      database_name = DB_NAME(database_id)
    , log_size_gb = CAST(SUM(CASE WHEN type_desc = 'LOG' THEN size END) * 8. / 1024 AS DECIMAL(8,2))/1024
    , row_size_gb = CAST(SUM(CASE WHEN type_desc = 'ROWS' THEN size END) * 8. / 1024 AS DECIMAL(8,2))/1024
    , total_size_gb = CAST(SUM(size) * 8. / 1024 AS DECIMAL(8,2))/1024
FROM sys.master_files WITH(NOWAIT)
--WHERE database_id> 4
GROUP BY database_id
