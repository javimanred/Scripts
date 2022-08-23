DECLARE @ActionFlag BIT
DECLARE @ScriptToExecute VARCHAR(MAX);
DECLARE @Action VARCHAR(7)

SET @ActionFlag = 0 --0 To ENABLE, 1 To Disable
SET @Action = IIF(@ActionFlag=0,'ENABLE','DISABLE')
SET @ScriptToExecute = '';
SELECT
@ScriptToExecute = @ScriptToExecute +
'USE [master]; ALTER LOGIN ['+sp.name+'] '+@Action+'; '
FROM sys.server_principals sp
WHERE sp.name like 'OG\svc.%'
SELECT @ScriptToExecute ScriptToExecute
EXEC (@ScriptToExecute)
