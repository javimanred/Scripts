DECLARE @name NVARCHAR(100) -- table name
DECLARE @newname NVARCHAR(100)
DECLARE @schema NVARCHAR(100)
DECLARE @TableDefinition NVARCHAR(MAX), @SQL NVARCHAR(MAX)

DECLARE db_cursor CURSOR FOR 
SELECT schemaName = s.name, tableName = t.name
FROM sys.tables t
	INNER JOIN sys.schemas s
		ON t.schema_id = s.schema_id
WHERE t.name LIKE 'TargetOverrideBy%LOB%'
	OR t.name LIKE 'TargetOverrideBy%REGION%'
	OR t.name LIKE 'TargetOverrideBy%SITE%'
	OR t.name LIKE 'TargetOverrideBy%MARKET%'
	OR t.name LIKE 'TargetOverrideBy%Peergroup%'
	OR t.name LIKE 'TargetPeriodOverrideBy%MARKET%'
	OR t.name LIKE 'TargetPeriodOverrideBy%REGION%'
	OR t.name LIKE 'TargetPeriodOverrideBy%SITE%'
	OR t.name LIKE 'PerformanceData%LOB%'
	OR t.name LIKE 'PerformanceData%Peergroup%'
	OR t.name LIKE 'Cache_AreaPeergroup%'
	OR t.name LIKE 'Cache_Peergroup%'
	OR t.name LIKE 'Cache%_RegionPeergroup%'
	OR t.name LIKE 'Cache_SitePeergroup%'
	OR t.name LIKE 'CacheSupport_AreaPeergroup%'
	OR t.name LIKE 'CacheSupport_Peergroup%'
	OR t.name LIKE 'CacheSupport_SitePeergroup%'
	OR t.name like 'CacheTarget_AreaPeergroup%'
	OR t.name like 'CacheTarget_Peergroup%'
	OR t.name like 'CacheTarget_SitePeergroup%'

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @schema, @name  

WHILE @@FETCH_STATUS = 0  
BEGIN  
      SET @newname = REPLACE(@name,'Lob','LOB')
	  SET @newname = REPLACE(@newname,'REGION','Region')
	  SET @newname = REPLACE(@newname,'SITE','Site')
	  SET @newname = REPLACE(@newname,'MARKET','Market')
	  SET @newname = REPLACE(@newname,'Peergroup','PeerGroup')
	  SET @newname = REPLACE(@newname,'SitePeergroup','SitePeerGroup')
	  SET @newname = REPLACE(@newname,'AreaPeergroup','AreaPeerGroup')
	  SET @newname = REPLACE(@newname,'RegionPeergroup','RegionPeerGroup')

	  SET @SQL = 'EXEC sp_rename ''' + @schema + '.' + @name + ''',''' + @newname + ''''
	  --PRINT @SQL

	  EXEC sp_executesql @SQL
      FETCH NEXT FROM db_cursor INTO @schema, @name 
END 

CLOSE db_cursor  
DEALLOCATE db_cursor

EXEC sp_rename 'dbo.csfnDates_QTDEND','csfnDates_QTDEnd' --Main DB
