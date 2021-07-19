CREATE TABLE #2TON(Num INT)

INSERT INTO #2TON VALUES (1),(2),(4),(8),(16),(32),(64),(128),(256),(512),(1024)

select 'ALTER DATABASE ['+db_name(database_id)+'] MODIFY FILE ( NAME = N'''+name+''', FILEGROWTH = '+ CAST
((select top 1 Num from #2TON where num <=ceiling((cast(size as float)*8)/1024) order by Num desc) AS nvarchar(100))+'MB )'
from sys.master_files where is_percent_growth = 1

DECLARE @sql nvarchar(max)

DECLARE  MODIFYALLGROWTSRATE CURSOR
READ_ONLY
FOR 
select 'ALTER DATABASE ['+db_name(database_id)+'] MODIFY FILE ( NAME = N'''+name+''', FILEGROWTH = '+ CAST
((select top 1 Num from #2TON where num <=ceiling((cast(size as float)*8)/1024) order by Num desc) AS nvarchar(100))+'MB )'
from sys.master_files where is_percent_growth = 1
OPEN MODIFYALLGROWTSRATE
FETCH NEXT FROM MODIFYALLGROWTSRATE   
INTO @sql
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
EXEC (@SQL)
FETCH NEXT FROM MODIFYALLGROWTSRATE   
INTO @sql
END
CLOSE MODIFYALLGROWTSRATE
DEALLOCATE MODIFYALLGROWTSRATE

DROP TABLE  #2TON
