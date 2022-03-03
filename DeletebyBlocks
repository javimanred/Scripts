SET ROWCOUNT 50000
delete_more:
     DELETE FROM dbo.Logs WHERE TimeStamp < '1/1/2022'
IF @@ROWCOUNT > 0 GOTO delete_more
SET ROWCOUNT 0
