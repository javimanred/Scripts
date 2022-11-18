SELECT session_id ,status ,command, blocking_session_id
    ,wait_type ,wait_time ,wait_resource 
    ,transaction_id, estimated_completion_time
FROM sys.dm_exec_requests 
WHERE (status = N'suspended' OR status = N'running')
AND session_id <> @@SPID;
GO

----------------------------------------------------Blocking Processes----------------------------------------------------

--Parte 1
SELECT
             WaitingTime = s.waittime, s.spid, BlockingSPID = s.blocked, DatabaseName = DB_NAME(s.dbid),
             s.program_name, s.loginame, s.hostname, s.cmd, ObjectName = OBJECT_NAME(objectid,s.dbid), Definition = CAST(text AS VARCHAR(MAX))
 INTO        #Processes
 FROM      sys.sysprocesses s
 CROSS APPLY sys.dm_exec_sql_text (sql_handle)
 WHERE
            s.spid > 50
go            

--select * from #Processes
--Parte2

WITH Blocking(SPID, BlockingSPID, "WaitingTime (secs)", BlockingStatement, LoginName, HostName, Command, RowNo, LevelRow)
 AS
 (
      SELECT
       s.spid, s.BlockingSPID, s.WaitingTime/1000, s.Definition, s.loginame, s.hostname, s.cmd,
       ROW_NUMBER() OVER(ORDER BY s.spid),
       0 AS LevelRow
     FROM
       #Processes s
       JOIN #Processes s1 ON s.spid = s1.BlockingSPID
     WHERE
       s.BlockingSPID = 0
     UNION ALL
     SELECT
       r.spid,  r.BlockingSPID, r.WaitingTime/1000, r.Definition, r.loginame, r.hostname, r.cmd,
       d.RowNo,
       d.LevelRow + 1
     FROM
       #Processes r
      JOIN Blocking d ON r.BlockingSPID = d.SPID
     WHERE
       r.BlockingSPID > 0
 )
 SELECT * FROM Blocking
 ORDER BY RowNo, LevelRow
 go

--Parte 3
 drop table #Processes
 go

--------------------------------------------------------Waits Info--------------------------------------------------

WITH [Waits] AS
    (SELECT
        [wait_type],
        [wait_time_ms] / 1000.0 AS [WaitS],
        ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
        [signal_wait_time_ms] / 1000.0 AS [SignalS],
        [waiting_tasks_count] AS [WaitCount],
        100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
        ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
    FROM sys.dm_os_wait_stats
    WHERE [wait_type] NOT IN (
        N'BROKER_EVENTHANDLER',             N'BROKER_RECEIVE_WAITFOR',
        N'BROKER_TASK_STOP',                N'BROKER_TO_FLUSH',
        N'BROKER_TRANSMITTER',              N'CHECKPOINT_QUEUE',
        N'CHKPT',                           N'CLR_AUTO_EVENT',
        N'CLR_MANUAL_EVENT',                N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT',              N'DBMIRROR_EVENTS_QUEUE',
        N'DBMIRROR_WORKER_QUEUE',           N'DBMIRRORING_CMD',
        N'DIRTY_PAGE_POLL',                 N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC',                        N'FSAGENT',
        N'FT_IFTS_SCHEDULER_IDLE_WAIT',     N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL',               N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'HADR_LOGCAPTURE_WAIT',            N'HADR_NOTIFICATION_DEQUEUE',
        N'HADR_TIMER_TASK',                 N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP',                  N'LAZYWRITER_SLEEP',
        N'LOGMGR_QUEUE',                    N'ONDEMAND_TASK_QUEUE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
        N'REQUEST_FOR_DEADLOCK_SEARCH',     N'RESOURCE_QUEUE',
        N'SERVER_IDLE_CHECK',               N'SLEEP_BPOOL_FLUSH',
        N'SLEEP_DBSTARTUP',                 N'SLEEP_DCOMSTARTUP',
        N'SLEEP_MASTERDBREADY',             N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED',            N'SLEEP_MSDBSTARTUP',
        N'SLEEP_SYSTEMTASK',                N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP',             N'SNI_HTTP_ACCEPT',
        N'SP_SERVER_DIAGNOSTICS_SLEEP',     N'SQLTRACE_BUFFER_FLUSH',
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'SQLTRACE_WAIT_ENTRIES',           N'WAIT_FOR_RESULTS',
        N'WAITFOR',                         N'WAITFOR_TASKSHUTDOWN',
        N'WAIT_XTP_HOST_WAIT',              N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
        N'WAIT_XTP_CKPT_CLOSE',             N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT',              N'XE_TIMER_EVENT')
    AND [waiting_tasks_count] > 0
 )
SELECT
	TOP 5
    MAX ([W1].[wait_type]) AS [WaitType],
    CAST (MAX ([W1].[WaitS]) AS DECIMAL (16,2)) AS [Wait_S],
    CAST (MAX ([W1].[ResourceS]) AS DECIMAL (16,2)) AS [Resource_S],
    CAST (MAX ([W1].[SignalS]) AS DECIMAL (16,2)) AS [Signal_S],
    MAX ([W1].[WaitCount]) AS [WaitCount],
    CAST (MAX ([W1].[Percentage]) AS DECIMAL (5,2)) AS [Percentage],
    CAST ((MAX ([W1].[WaitS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgWait_S],
    CAST ((MAX ([W1].[ResourceS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgRes_S],
    CAST ((MAX ([W1].[SignalS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgSig_S]
FROM [Waits] AS [W1]
INNER JOIN [Waits] AS [W2]
    ON [W2].[RowNum] <= [W1].[RowNum]
GROUP BY [W1].[RowNum]
HAVING SUM ([W2].[Percentage]) - MAX ([W1].[Percentage]) < 95; -- percentage threshold
GO

-------------------------------------------------------------Waiting Tasks-------------------------------------------------

SELECT 'Waiting_tasks' AS [Information], owt.session_id,
     owt.wait_duration_ms,
     owt.wait_type,
     owt.blocking_session_id,
     owt.resource_description,
     es.program_name,
     est.text,
     est.dbid,
     eqp.query_plan,
     er.database_id,
     es.cpu_time,
     es.memory_usage
 FROM sys.dm_os_waiting_tasks owt
 INNER JOIN sys.dm_exec_sessions es ON owt.session_id = es.session_id
 INNER JOIN sys.dm_exec_requests er ON es.session_id = er.session_id
 OUTER APPLY sys.dm_exec_sql_text (er.sql_handle) est
 OUTER APPLY sys.dm_exec_query_plan (er.plan_handle) eqp
 WHERE es.is_user_process = 1
 AND owt.wait_duration_ms > 0;
 GO 

 ------------------------------------------------------I/O Database File Utilization-----------------------------------=

SELECT TOP 5 DB_NAME(a.database_id) AS [Database Name] , b.type_desc, b.physical_name, CAST(( io_stall_read_ms + io_stall_write_ms ) / ( 1.0 + num_of_reads + num_of_writes) AS NUMERIC(10,1)) AS [avg_io_stall_ms]
FROM sys.dm_io_virtual_file_stats(NULL, NULL) a
INNER JOIN sys.master_files b 
ON a.database_id = b.database_id and a.file_id = b.file_id
ORDER BY avg_io_stall_ms DESC ;

-------------------------------------------------Top 10 most expensive queries-----------------------------------------------

SELECT TOP 10 
		(SELECT db_name(dbid) FROM sys.dm_exec_sql_text(qs.plan_handle)) DBName, 
		(SELECT object_name(objectid, dbid) FROM sys.dm_exec_sql_text(qs.plan_handle)) 		AS SPName, 
		(SELECT SUBSTRING(text, statement_start_offset/2 + 1, (CASE WHEN 			statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(max), text)) * 2 ELSE 		statement_end_offset END - statement_start_offset)/2) FROM 			sys.dm_exec_sql_text(sql_handle)) AS query_text,
		creation_time,
		last_execution_time,
		execution_count,
		total_worker_time / 1000 AS CPU_ms,
		total_worker_time / execution_count / 1000 AS Avg_CPU_ms,
		total_logical_reads AS page_reads,
		total_logical_reads / execution_count AS Avg_page_reads,
		total_elapsed_time / 1000 AS CPU_ms,
		total_worker_time / execution_count / 1000 AS Avg_CPU_ms,
		(SELECT query_plan FROM sys.dm_exec_query_plan(qs.plan_handle)) QueryPlan
FROM sys.dm_exec_query_stats qs
ORDER BY total_worker_time DESC
go

-------------------------------------------------------Missing Indexes--------------------------------------------------------

SELECT TOP 5 priority = avg_total_user_cost * avg_user_impact * (user_seeks + user_scans) , 
d.statement , d.equality_columns , d.inequality_columns , d.included_columns , 
s.avg_total_user_cost , s.avg_user_impact , s.user_seeks, s.user_scans 
FROM sys.dm_db_missing_index_group_stats s 
JOIN sys.dm_db_missing_index_groups g 
ON s.group_handle = g.index_group_handle 
JOIN sys.dm_db_missing_index_details d 
ON g.index_handle = d.index_handle 
ORDER BY priority DESC
go

-------------------------------------------------------------Missing Indexes Creation Statement----------------------------------------------


;WITH I AS ( 
SELECT --user_seeks * avg_total_user_cost * (avg_user_impact * 0.01) AS [index_advantage], 
		avg_total_user_cost * avg_user_impact * (user_seeks + user_scans) AS [Priority],
migs.last_user_seek, 
mid.[statement] AS [Database.Schema.Table], 
mid.equality_columns, mid.inequality_columns, 
mid.included_columns,migs.unique_compiles, migs.user_seeks, 
migs.avg_total_user_cost, migs.avg_user_impact 
FROM sys.dm_db_missing_index_group_stats AS migs WITH (NOLOCK) 
INNER JOIN sys.dm_db_missing_index_groups AS mig WITH (NOLOCK) 
ON migs.group_handle = mig.index_group_handle 
INNER JOIN sys.dm_db_missing_index_details AS mid WITH (NOLOCK) 
ON mig.index_handle = mid.index_handle 
--WHERE mid.database_id = db_id('driveatv') --DB_ID() 
      --AND user_seeks * avg_total_user_cost * (avg_user_impact * 0.01) > 90 -- Set this to Whatever 
    
) 


SELECT top 5 'CREATE INDEX IX_' 
            + SUBSTRING([Database.Schema.Table], 
                              CHARINDEX('].[',[Database.Schema.Table], 
                              CHARINDEX('].[',[Database.Schema.Table])+4)+3, 
                              LEN([Database.Schema.Table]) -   
                              (CHARINDEX('].[',[Database.Schema.Table], 
                              CHARINDEX('].[',[Database.Schema.Table])+4)+3)) 
            + '_' + LEFT(REPLACE(REPLACE(REPLACE(REPLACE( 
            ISNULL(equality_columns,inequality_columns), 
            '[',''),']',''),' ',''),',',''),20) 
            + ' ON ' 
            + [Database.Schema.Table] 
            + '(' 
            + ISNULL(equality_columns,'') 
            + CASE WHEN equality_columns IS NOT NULL AND 
                              inequality_columns IS NOT NULL 
                  THEN ',' 
                  ELSE '' 
              END 
	  + ISNULL(inequality_columns,'') 
	  	         + ')' 
			     + CASE WHEN included_columns IS NOT NULL 
                  THEN ' INCLUDE(' + included_columns + ')' 
                  ELSE '' 
              END CreateStatement--, 
            --'IX_' 
            --+ SUBSTRING([Database.Schema.Table], 
            --                  CHARINDEX('].[',[Database.Schema.Table], 
            --                  CHARINDEX('].[',[Database.Schema.Table])+4)+3, 
            --                  LEN([Database.Schema.Table]) -   
            --                  (CHARINDEX('].[',[Database.Schema.Table], 
            --                  CHARINDEX('].[',[Database.Schema.Table])+4)+3)) 
            --+ '_' + LEFT(REPLACE(REPLACE(REPLACE(REPLACE( 
            --ISNULL(Equality_Columns,inequality_columns), 
            --'[',''),']',''),' ',''),',',''),20) 
            --      IndexName 
FROM I
order by Priority DESC
go
