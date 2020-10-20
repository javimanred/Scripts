SELECT	@@servername AS ServerName,
		name as DBName,
		compatibility_level,
		collation_name, 
		recovery_model_desc,
		page_verify_option_desc,
		CASE WHEN is_auto_update_stats_on = 1 THEN 'TRUE' ELSE 'FALSE' END AS is_auto_update_stats_on,
		suser_sname( owner_sid ) AS DBOwner,
		state_desc AS Status
FROM sys.databases
