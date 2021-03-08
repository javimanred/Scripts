USE [master]
GO
CREATE LOGIN [OG\steffani.tobon] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
EXEC sp_MSforeachdb N'
IF N''?'' NOT IN(''master'', ''model'', ''msdb'',''tempdb'',''OGP_Compas_Support'')
BEGIN
	USE [?];
	CREATE USER [OG\steffani.tobon];
	ALTER ROLE db_datareader ADD MEMBER [OG\steffani.tobon];
END;
';
