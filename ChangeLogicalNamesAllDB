SELECT CASE WHEN file_id = 1 AND type = 0 and name <> db_name(database_id) 
			THEN'ALTER DATABASE ['+DB_NAME(database_id)+'] MODIFY FILE ( NAME ='+name+', NEWNAME='+db_name(database_id)+');' 
			WHEN  type = 1 and name <> concat(db_name(database_id),'_log')
			THEN 'ALTER DATABASE ['+DB_NAME(database_id)+'] MODIFY FILE ( NAME ='+name+', NEWNAME='+db_name(database_id)+'_log);'
			WHEN type = 0 and file_id <> 1 and name <> concat(db_name(database_id),SUBSTRING(name,(LEN(name)-CHARINDEX('_',REVERSE(name)))+1,CHARINDEX('_',REVERSE(name))+1)) 
			THEN 'ALTER DATABASE ['+DB_NAME(database_id)+'] MODIFY FILE ( NAME ='+name+', NEWNAME='+db_name(database_id)+SUBSTRING(name,(LEN(name)-CHARINDEX('_',REVERSE(name)))+1,CHARINDEX('_',REVERSE(name))+1)+');'
			END AS Script
INTO #Temp
FROM sys.master_files 
WHERE  database_id > 4 and db_name(database_id) not in ('SSISDB','ReportServer','ReportServerTempDB') 

DELETE FROM #Temp WHERE Script is null

DECLARE @ScriptToExecute VARCHAR(MAX);
SET @ScriptToExecute = '';
SELECT
@ScriptToExecute = @ScriptToExecute +
Script
FROM #Temp
-- AND d.name = 'NameofDB'
SELECT @ScriptToExecute ScriptToExecute
EXEC (@ScriptToExecute)

DROP TABLE #temp

select 'ALTER DATABASE ['+DB_NAME(database_id)+'] MODIFY FILE ( NAME ='+name+', NEWNAME='+db_name(database_id)+');' 
from sys.master_files where file_id = 1 and name <> db_name(database_id) and database_id > 4 and db_name(database_id) not in ('SSISDB','ReportServer','ReportServerTempDB') and type = 0
UNION ALL
select 'ALTER DATABASE ['+DB_NAME(database_id)+'] MODIFY FILE ( NAME ='+name+', NEWNAME='+db_name(database_id)+'_log);'
from sys.master_files where type = 1 and name <> concat(db_name(database_id),'_log') and database_id > 4 and db_name(database_id) not in ('SSISDB','ReportServer','ReportServerTempDB')
UNION ALL
select 'ALTER DATABASE ['+DB_NAME(database_id)+'] MODIFY FILE ( NAME ='+name+', NEWNAME='+db_name(database_id)+SUBSTRING(name,(LEN(name)-CHARINDEX('_',REVERSE(name)))+1,CHARINDEX('_',REVERSE(name))+1)+');'
from sys.master_files where  type = 0 and file_id <> 1 and name <> concat(db_name(database_id),SUBSTRING(name,(LEN(name)-CHARINDEX('_',REVERSE(name)))+1,CHARINDEX('_',REVERSE(name))+1)) 
and database_id > 4 and db_name(database_id) not in ('SSISDB','ReportServer','ReportServerTempDB')
