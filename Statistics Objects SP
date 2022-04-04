SELECT DB_NAME(database_id) dbname ,OBJECT_SCHEMA_NAME(object_id,database_id) schemaname,OBJECT_NAME(object_id,database_id) objectname, *
FROM sys.dm_exec_procedure_stats AS d  
where DB_NAME(database_id) like 'Compas_Rogers_Care%' 
ORDER BY [total_worker_time] DESC; 
