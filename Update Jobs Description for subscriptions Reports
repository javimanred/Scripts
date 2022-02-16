DECLARE @ScriptToExecute VARCHAR(MAX);
SET @ScriptToExecute = '';
SELECT
@ScriptToExecute = @ScriptToExecute +
'EXEC msdb.dbo.sp_update_job @job_id=N'''+cast(sj.job_id AS nvarchar(128))+''''+', @description=N''Report Server: http://'+@@SERVERNAME+'/REPORTS/browse/  ***************** Path: '
+c.Path+' ************** Report Name: '+c.Name+''';' 
FROM msdb..sysjobs AS sj 
INNER JOIN ReportServer..ReportSchedule AS rs
ON sj.[name] = CAST(rs.ScheduleID AS NVARCHAR(128)) 
INNER JOIN ReportServer..Subscriptions AS su
ON rs.SubscriptionID = su.SubscriptionID
INNER JOIN ReportServer..[Catalog] c
ON su.Report_OID = c.ItemID
SELECT @ScriptToExecute ScriptToExecute
EXEC (@ScriptToExecute)
