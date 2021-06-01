IF EXISTS (SELECT 1 FROM OGP_Compas_Support.sys.objects where name = 'JobsAvgTime' and type = 'U')
BEGIN
	PRINT 'The Table Exists'
END
ELSE 
BEGIN
CREATE TABLE [OGP_Compas_Support].[dbo].[JobsAvgTime](
	[JobName] [sysname] NOT NULL,
	[RunDurationSeconds] [numeric](13, 1) NULL
) ON [PRIMARY]

INSERT INTO  [OGP_Compas_Support].[dbo].[JobsAvgTime]
SELECT	j.name,
		MAX((jh.run_duration/10000 * 60 * 60) +(jh.run_duration/100%100 * 60)+(jh.run_duration%100)) AS run_duration_total_seconds		
FROM	msdb.dbo.sysjobhistory	AS jh 
JOIN	msdb.dbo.sysjobs		AS j ON jh.job_id= j.job_id
WHERE name not in ('SSIS Server Maintenance Job','syspolicy_purge_history') and name not like '%Loop%'
GROUP BY j.name
END
