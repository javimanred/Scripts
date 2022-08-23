IF EXISTS(SELECT * FROM msdb.dbo.sysschedules where name = N'CollectorSchedule_Every_15Min_2')
	EXEC msdb.dbo.sp_delete_schedule @schedule_name = N'CollectorSchedule_Every_15Min_2'
GO

EXEC msdb.dbo.sp_add_schedule  
    @schedule_name = N'CollectorSchedule_Every_15Min_2',  
    @enabled=1, 
	@freq_type=4, 
	@freq_interval=1, 
	@freq_subday_type=4, 
	@freq_subday_interval=15, 
	@freq_relative_interval=0, 
	@freq_recurrence_factor=0, 
	@active_start_date=20170822, 
	@active_end_date=99991231, 
	@active_start_time=200, 
	@active_end_time=235959;  
GO  

Begin Transaction
Begin Try
EXEC [msdb].[dbo].[sp_syscollector_update_collection_set] @collection_set_id=2, @proxy_name=N'', @schedule_name=N'CollectorSchedule_Every_15Min_2', @collection_mode=0
Commit Transaction;
End Try
Begin Catch
Rollback Transaction;
DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @ErrorNumber INT;
DECLARE @ErrorLine INT;
DECLARE @ErrorProcedure NVARCHAR(200);
SELECT @ErrorLine = ERROR_LINE(),
       @ErrorSeverity = ERROR_SEVERITY(),
       @ErrorState = ERROR_STATE(),
       @ErrorNumber = ERROR_NUMBER(),
       @ErrorMessage = ERROR_MESSAGE(),
       @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');
RAISERROR (14684, @ErrorSeverity, 1 , @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage);

End Catch;

GO
