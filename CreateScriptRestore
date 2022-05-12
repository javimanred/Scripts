SET NOCOUNT ON
GO

DECLARE @FileListCmd            nvarchar(max),	@RestoreCmd             nvarchar(max),
		@cmd                    nvarchar(max),  @BackupFile             nvarchar(max),
		@DBName                 sysname,		@DataPath               nvarchar(260),
		@LogPath                nvarchar(260),	@Version                decimal(10,2),
		@MaxLogicalNameLength   int,			@MoveFiles              nvarchar(max)

select *
into #BackupFileLocation
from openquery([DEMO-SQL-MAIN],'Select * from ogp_compas_support.dbo.LastBackupDetails')


delete 
from #BackupFileLocation
where [Database] not like 'Orbit_Demo%'-- or [database] IN ('Compas_Rogers_Care_Archive','Compas_Rogers_Care_Logging','Compas_Rogers_Care_Dim','Compas_Rogers_Care_ETL')



--SET @BackupFile     = N'\\10.209.12.240\Backups\PRDMA-SQL503\COMPAS_TheShoppingChannel_Staging\FULL\PRDMA-SQL503_COMPAS_TheShoppingChannel_Staging_FULL_20210105_231716.bak'
--SET @DBName         = N'COMPAS_TheShoppingChannel_Staging' --target database name
SET @DataPath       = CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS nvarchar(260)) --target data path
SET @LogPath        = CAST(SERVERPROPERTY('InstanceDefaultLogPath') AS nvarchar(260)) --target log path

DECLARE GenerateRestoreScript CURSOR
FOR
select  [Database],[Backup File Location]
from #BackupFileLocation

OPEN GenerateRestoreScript

FETCH NEXT FROM GenerateRestoreScript   
INTO @DBName, @BackupFile  
WHILE @@FETCH_STATUS = 0  
BEGIN  

IF RIGHT(@DataPath, 1) <> '\' SET @DataPath = @DataPath + N'\';
IF RIGHT(@LogPath, 1) <> '\' SET @LogPath = @LogPath + N'\';
SET @cmd = N'';
SET @Version = CONVERT(decimal(10,2), 
    CONVERT(varchar(10), SERVERPROPERTY('ProductMajorVersion')) 
    + '.' + 
    CONVERT(varchar(10), SERVERPROPERTY('ProductMinorVersion'))
    );
IF @Version IS NULL --use ProductVersion instead
BEGIN
    DECLARE @sv varchar(10);
    SET @sv = CONVERT(varchar(10), SERVERPROPERTY('ProductVersion'));
    SET @Version = CONVERT(decimal(10,2), LEFT(@sv, CHARINDEX(N'.', @sv) + 1));
END
 
IF OBJECT_ID(N'tempdb..#FileList', N'U') IS NOT NULL
BEGIN
    DROP TABLE #FileList;
END
CREATE TABLE #FileList 
(
      LogicalName               sysname             NOT NULL
    , PhysicalName              varchar(255)        NOT NULL
    , [Type]                    char(1)             NOT NULL
    , FileGroupName             sysname             NULL
    , Size                      numeric(20,0)       NOT NULL
    , MaxSize                   numeric(20,0)       NOT NULL
    , FileId                    bigint              NOT NULL
    , CreateLSN                 numeric(25,0)       NOT NULL
    , DropLSN                   numeric(25,0)       NULL
    , UniqueId                  uniqueidentifier    NOT NULL
    , ReadOnlyLSN               numeric(25,0)       NULL
    , ReadWriteLSN              numeric(25,0)       NULL
    , BackupSizeInBytes         bigint              NOT NULL
    , SourceBlockSize           int                 NOT NULL
    , FileGroupId               int                 NULL
    , LogGroupGUID              uniqueidentifier    NULL
    , DifferentialBaseLSN       numeric(25,0)       NULL
    , DifferentialBaseGUID      uniqueidentifier    NOT NULL
    , IsReadOnly                bit                 NOT NULL
    , IsPresent                 bit                 NOT NULL 
);
 
IF @Version >= 10.5 ALTER TABLE #FileList ADD TDEThumbprint varbinary(32) NULL;
IF @Version >= 12   ALTER TABLE #FileList ADD SnapshotURL nvarchar(360) NULL;
 
SET @FileListCmd = N'RESTORE FILELISTONLY FROM DISK = N''' + @BackupFile + N''';';
 
INSERT INTO #FileList
EXEC (@FileListCmd);
SET @MaxLogicalNameLength = COALESCE((SELECT MAX(LEN(fl.LogicalName)) FROM #FileList fl), 0);
SELECT @MoveFiles = (SELECT N', MOVE N''' + fl.LogicalName + N''' ' 
    + REPLICATE(N' ', @MaxLogicalNameLength - LEN(fl.LogicalName)) 
    + N'TO N''' + CASE WHEN fl.Type = 'L' THEN @LogPath ELSE @DataPath END 
    + fl.LogicalName + CASE WHEN fl.Type = 'L' THEN N'.ldf' 
                                ELSE 
                                    CASE WHEN fl.FileGroupName = N'PRIMARY' THEN N'.mdf'
                                     ELSE N'.ndf' 
                                     END 
                                END + N'''
    '
FROM #FileList fl
FOR XML PATH(''));
 
SET @MoveFiles = REPLACE(@MoveFiles, N'&#x0D;', N'');
SET @MoveFiles = REPLACE(@MoveFiles, char(10), char(13) + char(10));
SET @MoveFiles = LEFT(@MoveFiles, LEN(@MoveFiles) - 2);
 
SET @RestoreCmd = N'RESTORE DATABASE ' + @DBName + N'
FROM DISK = N''' + @BackupFile + N''' 
WITH REPLACE 
    , RECOVERY
    , STATS = 5
    ' + @MoveFiles + N'
GO';
 
IF LEN(@RestoreCmd) > 4000 
BEGIN
    DECLARE @CurrentLen int;
    SET @CurrentLen = 1;
    WHILE @CurrentLen <= LEN(@RestoreCmd)
    BEGIN
        PRINT SUBSTRING(@RestoreCmd, @CurrentLen, 4000);
        SET @CurrentLen = @CurrentLen + 4000;
    END
    RAISERROR (N'Output is chunked into 4,000 char pieces - look for errant line endings!', 14, 1);
END
ELSE
BEGIN
    PRINT @RestoreCmd;
END
FETCH NEXT FROM GenerateRestoreScript   
INTO @DBName, @BackupFile 
END
CLOSE GenerateRestoreScript
DEALLOCATE GenerateRestoreScript

drop table #BackupFileLocation
