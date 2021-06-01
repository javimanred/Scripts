USE [OGP_Compas_Support]
GO
/****** Object:  StoredProcedure [dbo].[USP_SPID_Monitoring]    Script Date: 2021-06-01 5:49:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_SPID_Monitoring]
AS
IF EXISTS(
		SELECT	1
		FROM		sys.sysprocesses	 AS SP with(nolock)                 
		INNER JOIN	sys.dm_exec_requests AS A  with(nolock) ON SP.SPID = A.session_id               
		INNER JOIN OGP_Compas_Support.dbo.LastSPIDExecuted AS LS ON  LS.SPID=SP.spid
		CROSS APPLY sys.dm_exec_query_plan(A.plan_handle) as B                
		CROSS APPLY sys.dm_exec_sql_text(A.sql_handle) as C              
		WHERE	SP.spid <> @@spid   
		AND		(LS.physical_io+LS.cpu+LS.writes+LS.reads)=(SP.physical_io+SP.cpu+A.writes+A.reads) 
		AND		SP.cmd <> 'WAITFOR'
		AND		DATEDIFF(SECOND,last_batch,GETDATE()) > 60
		)
		OR
   EXISTS(
		SELECT	1
		FROM		msdb.dbo.sysjobactivity ja 
		LEFT JOIN	msdb.dbo.sysjobhistory jh ON ja.job_history_id = jh.instance_id 
		JOIN		msdb.dbo.sysjobs j ON ja.job_id = j.job_id 
		JOIN 		msdb.dbo.sysjobsteps js   ON ja.job_id = js.job_id  AND ISNULL(ja.last_executed_step_id,0)+1 = js.step_id  
		JOIN		OGP_Compas_Support.dbo.JobsAvgTime jav ON jav.JobName = j.name
		WHERE	ja.session_id = (SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC) 
		AND 	start_execution_date is not null 
		AND 	stop_execution_date is null 
		AND		DATEDIFF (SECOND,ja.start_execution_date,getdate()) > jav.RunDurationSeconds
		)
BEGIN
		DECLARE @xml NVARCHAR(MAX),
		@body NVARCHAR(MAX),
		@xml2 NVARCHAR(MAX), 
		@body2 NVARCHAR(MAX)
		
		SELECT   DB_NAME(SP.dbid) AS DatabaseName,               
				 A.total_elapsed_time/1000 TimeSec,               
				 SP.loginame as username,     
				 A.percent_complete PctComplete,             
				 SP.hostname hostname,               
				 SP.SPID SPID,                
				 SP.Blocked Blocked,                
				 SP.status status,                
				 SP.lastwaittype LastWaitType,      
				 SP.cmd Command,               
				 object_name(C.objectid) as processes,                
				 (SELECT SUBSTRING(C.text,A.statement_start_offset/2,(CASE WHEN A.statement_end_offset = -1                
				 THEN LEN(CONVERT(nvarchar(max), C.text)) * 2 ELSE A.statement_end_offset END -A.statement_start_offset)/2)) SQLBatchText,               
				 SP.physical_io physical_io,                
				 SP.cpu cpu,             
				 a.writes writes,               
				 a.reads reads,               
				 a.logical_reads logical_reads,               
				 a.scheduler_id scheduler_id,                      
				 SP.login_time LoginTime,                
				 C.text SQLStatementText
		INTO	 #tmpProcesses
		FROM	 sys.sysprocesses AS SP with(nolock)                 
				 INNER JOIN sys.dm_exec_requests as A with(nolock)              
				 ON SP.SPID = A.session_id               
				 CROSS APPLY sys.dm_exec_query_plan(A.plan_handle) as B                
				 CROSS APPLY sys.dm_exec_sql_text(A.sql_handle) as C              
				 WHERE SP.spid <> @@spid  
				 
		SET @xml = CAST(( SELECT [DatabaseName] AS 'td','',[TimeSec] AS 'td','', [Username] AS 'td','', [PctComplete] AS 'td'
						,'', Hostname AS 'td','', SPID AS 'td','', Blocked AS 'td','', [status] AS 'td','', [LastWaitType] AS 'td'
						,'', Command AS 'td','', ISNULL(Processes,0) AS 'td','', SQLBatchText AS 'td','', Physical_IO AS 'td'
						,'', cpu AS 'td','', writes AS 'td','', reads AS 'td','', logical_reads AS 'td'
						,'', scheduler_id AS 'td','', LoginTime AS 'td','', SQLStatementText AS 'td'
		FROM #tmpProcesses 
		ORDER BY 1 
		FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))
		
		SET @body ='<html><body><H3>Processes Info</H3>
		<table border = 1> 
		<tr>
		<th> Database </th> <th> Time Sec </th> <th> User </th> <th> % Complete </th>
		<th> HostName </th> <th> SPID </th> <th> Blocked </th> <th> Status </th> <th> Last Wait Type </th> 
		<th> Command </th> <th> Processes </th> <th> SQL Batch </th><th> Physical IO </th> 
		<th> CPU </th> <th> Writes </th> <th> Reads </th> <th> Logical Reads </th>
		<th> Schedule ID </th> <th> login Time </th> <th> SQL Statement </th>
		</tr>'  
		
		SET @xml2 =  CAST((SELECT DATEDIFF(SECOND, aj.start_execution_date, GETDATE())  AS 'td','',sj.name AS 'td',''
				FROM msdb..sysjobactivity aj
				INNER JOIN msdb..sysjobs sj ON sj.job_id = aj.job_id
				WHERE aj.stop_execution_date IS NULL 
					AND aj.start_execution_date IS NOT NULL -- condition: job is currently running 
					AND NOT EXISTS (SELECT 1
									FROM msdb..sysjobactivity new
									WHERE new.job_id = aj.job_id AND 
										  new.start_execution_date > aj.start_execution_date
								   ) -- End: Not Exists 
					ORDER BY 1 
		FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))

		SET @body2 ='<html><body><H3>Jobs </H3>
		<table border = 1> 
		<tr>
		<th> Time Exec in Sec </th> 
		<th> Job Name </th> 
		</tr>' 
	
		SET @body = @body2 + @xml2 +'</table></body></html>' +@body + @xml +'</table></body></html>'

		EXEC msdb.dbo.sp_send_dbmail @profile_name = N'DBMon'
				,-- ALL  
				@recipients  = N'sqlsupport@orbitgroup.ca;Axosoft.Incidents@orbitgroup.ca;support@orbitgroup.ca'
				,-- ALL 
				@subject = N'Warning: Job Hanging'
				,-- ALL 
				@body = @body
				,
				@body_format = 'HTML'

DROP TABLE #tmpProcesses				
END
ELSE
	PRINT 'Job not running or not (yet) exceeding treshold';
