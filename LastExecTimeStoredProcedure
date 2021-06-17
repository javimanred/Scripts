SELECT o.name,
ps.last_execution_time
FROM sys.dm_exec_procedure_stats ps
INNER JOIN
sys.objects o
ON ps.object_id = o.object_id
INNER JOIN 
sys.procedures as p 
on p.object_id = ps.object_id
WHERE  Object_definition(p.object_id) LIKE '%CacheSystemTable_MetricListAndFormulas%'
ORDER BY
ps.last_execution_time DESC
