--  SQL SERVER USERS AUDIT   
  
-- Process   
--    CREATETemp TABLE for Report   
--    CREATETemp TABLE for Users   
--    CREATETemp TABLE for Roles   
--    Populate Db's    
--    Populate Users   
--    Populate Roles   
--    Iterate though each user AND update their roles into a single column for each db   
--    Return the users, their logins (reports orphaned if so) and their roles   

SET NOCOUNT ON  
  
DECLARE @db    varchar (128)   
DECLARE @defdb    varchar(64)   
DECLARE @createdate   varchar (25)   
DECLARE @Lastmodifieddate  varchar(25)   
DECLARE @logintype   varchar(50)   
DECLARE @loginname   varchar(64)   
DECLARE @estado		 varchar(100)
DECLARE @ultimoacceso varchar (25)
  
CREATE TABLE #rpt   
(     
db    varchar(64),   
Name              varchar(128),   
Loginname   varchar(64),   
defdb   varchar (64),   
CreateDate         varchar(25),   
LAStModifiedDate    varchar(25),   
LoginType         varchar(50),   
Roles             varchar(300),
Estado			 varchar(100),
UltimoAcceso varchar (25)
)   
  
CREATE TABLE #Temp_Users   
(   
Name              varchar(128),   
Defdb   varchar(64),   
CreateDate         datetime,   
LAStModifiedDate    datetime,   
LoginType         varchar(50),   
Roles             varchar(1024),   
sid   varbinary(64),
Estado Varchar(100) 
)   
  
CREATE TABLE #Temp_Roles   
(   
Name              varchar(128),   
Role             varchar(128)   
)   
DECLARE databases CURSOR  
  
FOR SELECT name FROM master..sysdatabases  where version <> 0
OPEN databases    
FETCH NEXT FROM databases INTO @db   
  
WHILE @@fetch_status = 0    
BEGIN  
TRUNCATE TABLE  #Temp_Users  
INSERT INTO #Temp_Users   
EXEC('SELECT m.[Name],null AS Defdb,  m.CreateDate, m.UpdateDate,   
LoginType = CASE  
WHEN m.IsNTName = 1 THEN ''Windows Account''  
WHEN m.IsNTGroup = 1 THEN ''Windows Group''  
WHEN m.isSqlUser = 1 THEN ''SQL Server User''  
WHEN m.isAliased =1 THEN ''Aliased''     
WHEN m.isSQLRole = 1 THEN ''SQL Role''  
WHEN m.isAppRole = 1 THEN ''Application Role''  
ELSE ''Unknown''  
END,   
Roles = '''', sid, CASE WHEN m.hasdbaccess = 1 THEN ''Activo'' ELSE ''Inactivo''  END
FROM ['+@db+']..sysusers m   
WHERE m.SID IS NOT NULL AND name <> ''guest''  
ORDER BY m.Name')  

UPDATE #Temp_Users  
set Estado = 'Inactivo'
WHERE Name in (SELECT name 
FROM sys.server_principals 
WHERE is_disabled = 1) 
 
DELETE  #Temp_Roles   
INSERT INTO #Temp_Roles   
EXEC('SELECT MemberName = u.name, DbRole = g.name  
FROM ['+@db+']..sysusers u,['+@db+']..sysusers g,['+@db+']..sysmembers m   
WHERE   g.uid = m.groupuid   
AND g.issqlrole = 1   
AND u.uid = m.memberuid   
ORDER BY 1, 2')   
  
  
  
DECLARE @name    varchar(128)   
DECLARE @Roles   varchar(1024)   
DECLARE @Role    varchar(128)   
  
DECLARE UserCursor CURSOR FOR  
SELECT Name FROM #Temp_Users   
  
OPEN UserCursor   
FETCH NEXT FROM UserCursor INTO @name  
  
WHILE @@FETCH_STATUS = 0   
  
BEGIN  
SET @Roles = ''  
DECLARE RoleCursor CURSOR FOR  
SELECT Role FROM #Temp_Roles WHERE Name = @name  
  
OPEN RoleCursor   
FETCH NEXT FROM RoleCursor INTO @Role   
  
WHILE @@FETCH_STATUS = 0   
  
BEGIN  
IF (@Roles > '')   
SET @Roles = @Roles + ', '+@Role   
ELSE  
SET @Roles = @Role   
  
FETCH NEXT FROM RoleCursor INTO @Role   
  
END  
  
CLOSE RoleCursor   
DEALLOCATE RoleCursor   
  
SET    @loginname = 'ALERT ORPHANED!!!'  
SELECT @createdate = convert(varchar(25),CreateDate) FROM #Temp_Users WHERE Name = @name  
SELECT @Lastmodifieddate = convert(varchar(25),LAStModifiedDate) FROM #Temp_Users WHERE Name = @name  
SELECT @logintype = LoginType FROM #Temp_Users WHERE Name = @name  
SELECT @defdb = dbname FROM  master..syslogins a, #Temp_Users b WHERE b.Name = @name AND a.sid = b.sid   
SELECT @loginname= loginname FROM master..syslogins a, #Temp_Users b WHERE b.Name = @name AND a.sid = b.sid   
SELECT @estado  = Estado FROM #Temp_Users WHERE Name = @name 
--SELECT @ultimoacceso = max(login_time) FROM sys.dm_exec_sessions WHERE  login_name = @Name

INSERT INTO #rpt VALUES(rtrim(@db),rtrim(@name),isnull(rtrim(@loginname), 'orphaned'),rtrim(@defdb),@createdate,@Lastmodifieddate,rtrim(@logintype),'public, '+rtrim(@Roles),@estado,'NO REGISTRA')   
  
FETCH NEXT FROM UserCursor INTO @name  
  
END  
CLOSE UserCursor   
DEALLOCATE UserCursor   
  
FETCH NEXT FROM databases INTO @db   
END  
  
CLOSE databases   
DEALLOCATE databases   

SELECT login_name, max(login_time) UltAcc
INTO #UltimoAcceso
FROM sys.dm_exec_sessions
GROUP BY login_name

UPDATE a
SET UltimoAcceso =  b.UltAcc
FROM #rpt AS a inner join
#UltimoAcceso as b on a.Loginname=b.login_name

--PRINT '<b>'  
--PRINT '<p ALIGN = "left"> Server Name: ' +convert(char(24), @@SERVERNAME)+'</P>'  
--PRINT '<p ALIGN = "left"> Created by: ' + convert(char(30),SESSION_USER)+'</P>'  
--PRINT '<p ALIGN = "left"> Created from: ' + convert(char(30),host_name())+'</P>'  
--PRINT '<p ALIGN = "left"> Date: '+CONVERT(VARCHAR(32), getdate())+'</P>'  
--PRINT '</b>'  
--print '<p ALIGN = "left"><A HREF="http://url de referencia donde se reflejan las políticas en cuanto a usuarios</p></A> '

select '<DIV ALIGN="center"><TABLE BORDER="1" CELLPADDING="8" CELLSPACING="0" BORDERCOLOUR="003366" WIDTH="100%">   
<TR BGCOLOR="EEEEEE"><TD CLASS="Title" COLSPAN="10" ALIGN="center"><B><h4>USERS LOGINS AND ROLES</B></h4></TD></TR>'   
union  all  
select     '<TR BGCOLOR="EEEEEE">   
<TD ALIGN="left" WIDTH="5%"><B>DATABASE</B> </TD>   
<TD ALIGN="left" WIDTH="5%"><B>USER NAME</B> </TD>   
<TD ALIGN="left" WIDTH="5%"><B>LOGIN NAME</B> </TD>   
<TD ALIGN="left" WIDTH="5%"><B>DEFAULT DB</B> </TD>  
<TD ALIGN="left" WIDTH="5%"><B>CREATION DATE</B> </TD>   
<TD ALIGN="left" WIDTH="5%"><B>MODIFIED</B> </TD>   
<TD ALIGN="left" WIDTH="5%"><B>LOGIN TYPE</B> </TD>   
<TD ALIGN="left" WIDTH="40%"><B>ROLES</B> </TD>
<TD ALIGN="left" WIDTH="40%"><B>ESTADO</B> </TD>
<TD ALIGN="left" WIDTH="40%"><B>ULTIMO ACCESO</B> </TD>
</TR>'   
union all  
SELECT '<TR>   
<TD>'+rtrim(db)+'</TD>   
<TD>'+rtrim(Name)+'</TD>   
<TD>'+rtrim(Loginname)+'</TD>   
<TD>'+rtrim(defdb)+'</TD>   
<TD>'+CreateDate+'</TD>   
<TD>'+LAStModifiedDate+'</TD>   
<TD>'+rtrim(LoginType)+' </TD>   
<TD>'+rtrim(Roles)+'</TD>
<TD>'+rtrim(Estado)+'</TD>   
<TD>'+UltimoAcceso+'</TD>  
</TR>'   
FROM #rpt   
UNION ALL  
SELECT '</table>'  
  
DROP TABLE #Temp_Users   
DROP TABLE #Temp_Roles   
DROP TABLE #rpt 
DROP TABLE #UltimoAcceso  
  
SET NOCOUNT OFF  



