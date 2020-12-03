CREATE procedure [dbo].[sp_who5]               
(@spid int = null) 
as         
	          
if @spid is null 
		begin 
				SELECT               
				 DB_NAME(SP.dbid) AS DatabaseName,               
				 A.total_elapsed_time/1000 TimeSec,               
				 SP.loginame as usuario,     
				 A.percent_complete,             
				 SP.hostname Hostname,               
				 SP.SPID,                
				 SP.Blocked Bloqueando,                
				 SP.status Status,                
				 SP.lastwaittype LastWaitType,      
				 SP.cmd Command,               
				 object_name(C.objectid) as proceso,                
				 (SELECT SUBSTRING(C.text,A.statement_start_offset/2,(CASE WHEN A.statement_end_offset = -1                
				 THEN LEN(CONVERT(nvarchar(max), C.text)) * 2 ELSE A.statement_end_offset END -A.statement_start_offset)/2)) SQLBatchText,               
				 SP.Blocked Bloqueando,                 
				 SP.physical_io Physical_IO,                
				 SP.cpu CPU,             
				 a.writes,               
				 a.reads,               
				  a.logical_reads,               
				 a.scheduler_id,                      
				 SP.login_time LoginTime,                
				 C.text SQLStatementText,               
				 B.query_plan as QueryPlan               
				 FROM sys.sysprocesses AS SP with(nolock)                 
				 INNER JOIN sys.dm_exec_requests as A with(nolock)              
				 ON SP.SPID = A.session_id               
				 CROSS APPLY sys.dm_exec_query_plan(A.plan_handle) as B                
				 CROSS APPLY sys.dm_exec_sql_text(A.sql_handle) as C              
				 WHERE SP.spid <> @@spid  
				 order by TimeSec desc    
		end 
else 
		begin 
					 SELECT                
					 DB_NAME(SP.dbid) AS DatabaseName,               
					 A.total_elapsed_time/1000 TimeSec,               
					 SP.loginame as usuario,     
					 A.percent_complete,             
					 SP.hostname Hostname,               
					 SP.SPID,                
					 SP.Blocked Bloqueando,                
					 SP.status Status,                
					 SP.lastwaittype LastWaitType,      
					 SP.cmd Command,               
					 object_name(C.objectid) as proceso,                
					 (SELECT SUBSTRING(C.text,A.statement_start_offset/2,(CASE WHEN A.statement_end_offset = -1                
					 THEN LEN(CONVERT(nvarchar(max), C.text)) * 2 ELSE A.statement_end_offset END -A.statement_start_offset)/2)) SQLBatchText,               
					 SP.Blocked Bloqueando,                 
					 SP.physical_io Physical_IO,                
					 SP.cpu CPU,             
					 a.writes,               
					 a.reads,               
					  a.logical_reads,               
					 a.scheduler_id,                      
					 SP.login_time LoginTime,                
					 C.text SQLStatementText,                
					 B.query_plan as QueryPlan               
					 FROM sys.sysprocesses AS SP with(nolock)              
					 INNER JOIN sys.dm_exec_requests as A with(nolock)              
					 ON SP.SPID = A.session_id               
					 CROSS APPLY sys.dm_exec_query_plan(A.plan_handle) as B               
					 CROSS APPLY sys.dm_exec_sql_text(A.sql_handle) as C               
					 WHERE SP.spid <> @@spid  
					 and  SP.spid= @spid             
					 order by TimeSec desc    
			end
