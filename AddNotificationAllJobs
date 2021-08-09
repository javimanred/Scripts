USE [msdb]
GO

declare @categoryid int

select @categoryid = category_id from syscategories where name = 'Report Server'

select 'Exec msdb.dbo.sp_update_job @job_id=N'''+cast(job_id as nvarchar(max))+''',
		@notify_level_email=2,
		@notify_level_page=2,
		@notify_email_operator_name=N''SupportOperator''',name from sysjobs where notify_level_email = 0 and category_id <> @categoryid and name not like '_Orbit%' and name not in('syspolicy_purge_history','SSIS Server Maintenance Job')
		union all
select 'Exec msdb.dbo.sp_update_job @job_id=N'''+cast(job_id as nvarchar(max))+''',
		@notify_level_email=2,
		@notify_level_page=2,
		@notify_email_operator_name=N''SqlSupport''',name from sysjobs where notify_level_email = 0 and (name like '_Orbit%' or name in('syspolicy_purge_history','SSIS Server Maintenance Job') or name like 'collection%')
		order by name asc
