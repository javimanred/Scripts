DROP TABLE IF EXISTS  ##logininfo
GO
CREATE TABLE ##logininfo (account_name sysname,
						 type nvarchar(100),
						 privilege nvarchar(100),
						 mapped_login_name nvarchar(100),
						 permission_path nvarchar(100))

INSERT INTO ##logininfo
EXEC xp_logininfo [OG\fernando.valencia]


SELECT ISNULL(permission_path,mapped_login_name) as login_n FROM ##logininfo

sp_msforeachdb 'USE [?]
IF EXISTS (SELECT 1 FROM sys.objects where name = ''csfn_DaysInMonth'')
BEGIN
	DECLARE @LOGINN NVARCHAR(100),
			@SQLS NVARCHAR(MAX)
	SELECT @LOGINN= ISNULL(permission_path,mapped_login_name) FROM ##logininfo
	SELECT @SQLS = ''GRANT EXECUTE ON [csfn_DaysInMonth] TO [''+@LOGINN+'']''
	EXEC(@SQLS)
END'


DROP TABLE IF EXISTS  ##logininfo
