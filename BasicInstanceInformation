DECLARE @LastSOStart TABLE (DateT NVARCHAR(1000))
DECLARE @CmdShell SQL_VARIANT,
		@AdvancedOptions SQL_VARIANT
			   
SELECT @CmdShell = value_in_use FROM sys.configurations WHERE name = 'xp_cmdshell'
SELECT @AdvancedOptions = value_in_use FROM sys.configurations WHERE name = 'show advanced options'

IF @CmdShell=0
BEGIN
	IF @AdvancedOptions = 0
	BEGIN
		EXEC sp_configure 'show advanced options',1
		RECONFIGURE
		EXEC sp_configure 'xp_cmdshell',1
		RECONFIGURE
	END
	ELSE
	BEGIN
		EXEC sp_configure 'xp_cmdshell',1
		RECONFIGURE
	END
END

INSERT INTO @LastSOStart
EXEC xp_cmdshell 'systeminfo | find "System Boot Time"'

DELETE FROM @lastSOStart WHERE DateT is null

SELECT	@@servername AS ServerName, 
		CASE WHEN @@servicename = 'MSSQLSERVER' THEN 'Default' ELSE @@SERVICENAME END AS InstanceName,
		@@VERSION AS Version,
		( SELECT value_in_use 
      FROM sys.configurations 
      WHERE name = 'min server memory (MB)') AS MinMemory, 
		( SELECT value_in_use 
      FROM sys.configurations 
      WHERE name = 'max server memory (MB)') AS MaxMemory,
		CONVERT (varchar(256), SERVERPROPERTY('collation')) AS Collation,
		( SELECT service_account 
      FROM sys.dm_server_services 
       WHERE servicename = 'SQL Server (MSSQLSERVER)') AS SQLServerAccount,
		( SELECT service_account 
      FROM sys.dm_server_services 
      WHERE servicename = 'SQL Server Agent (MSSQLSERVER)') AS AgentAccount,
		( SELECT local_tcp_port 
      FROM sys.dm_exec_connections 
      WHERE session_id = @@SPID) AS PortNumber,
		( SELECT value_in_use 
      FROM sys.configurations 
      WHERE name = 'max degree of parallelism') AS MaxDegreeOfParallelism,
		( SELECT CASE WHEN value_in_use = 0 THEN 'FALSE' ELSE 'TRUE' END 
      FROM sys.configurations 
      WHERE name = 'Ad Hoc Distributed Queries') AS AdHocWorkloads,
		DATEDIFF(DAY,( SELECT CAST(REPLACE(REPLACE(DateT,'System Boot Time:          ',''),',','')AS DATETIME) 
	  FROM @lastSOStart),GETDATE()) AS DaysSinceLastReboot

IF @CmdShell=0
BEGIN
	IF @AdvancedOptions = 0
	BEGIN
		EXEC sp_configure 'xp_cmdshell',0
		RECONFIGURE
		EXEC sp_configure 'show advanced options',0
		RECONFIGURE
	END
	ELSE
	BEGIN
		EXEC sp_configure 'xp_cmdshell',0
		RECONFIGURE
	END
END
