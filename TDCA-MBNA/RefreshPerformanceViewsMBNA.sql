--Legacy
USE [Compas_TDBFG_MBNA]
GO
EXEC [Maintenance].[RefreshPerformanceDataViews] 
        @CacheSystemTableName = '[Cache].[SystemTable_TableConfig]' 
       ,@CacheSystemTableDB = '[Compas_TDBFG_MBNA_Staging]' 
       ,@CacheSystemTableServer = '[PSQL-TD-CACH01]'
GO
--Main
USE [Compas_TDBFG_MBNA_Main]
GO
EXEC [Maintenance].[RefreshPerformanceDataViews] 
        @CacheSystemTableName = '[DataCache].[SystemTable_TableConfig_PerformanceData]' 
       ,@CacheSystemTableDB = '[Compas_TDBFG_MBNA_Main]' 
       ,@CacheSystemTableServer = '[PSQL-TD-MAIN01]'
