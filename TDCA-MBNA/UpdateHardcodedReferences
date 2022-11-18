DECLARE @LegacyDB_Name nvarchar(250) 
DECLARE @MainDB_Name nvarchar(250)
DECLARE @SQL nvarchar(MAX) 

SET @LegacyDB_Name = dbo.GenerateDBName('MainDB_Name','MainDB_Server') 
SET @MainDB_Name = dbo.GenerateDBName('MainDB_Name_Current','MainDB_Server')
SET @SQL = '' 
SELECT @SQL= @SQL+ '-------------------------------------' + CHAR(13) + CHAR(10) + 
			'DROP PROCEDURE [' + s.name + '].[' + o.name + ']' + CHAR(13) + CHAR(10) + 
			'GO' + CHAR(13) + CHAR(10) + 
			REPLACE(REPLACE([definition],'@LegacyDB_Name',@LegacyDB_Name),'@@MainDB_Name',@MainDB_Name) + CHAR(13) + CHAR(10) + 
			'GO' + CHAR(13) + CHAR(10) 
FROM sys.sql_modules m INNER JOIN 
	 sys.objects o ON m.object_id = o.object_id INNER JOIN 
	 sys.schemas s ON o.schema_id = s.schema_id 
WHERE o.[type] ='P' AND ([definition] LIKE '%@LegacyDB_Name%' OR [definition] LIKE '%@@MainDB_Name%') and s.name <> 'Maintenance' 

EXEC (@SQL)
