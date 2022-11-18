DECLARE @Table table (RID INT IDENTITY(1,1) PRIMARY KEY CLUSTERED, 
                        SQLText NVARCHAR(MAX) )

DECLARE  @StatementMax INT 
        ,@statementMin INT
        ,@SQLStatement NVARCHAR(MAX)
-- Insert SQL Into Temp Table
INSERT INTO @Table
SELECT *
FROM OGP_Compas_Support.dba.DBPermissions

-- Get your Iterator Values
SELECT @statementMAX = MAX(RID), @statementMIN = MIN(RID)  FROM @table
-- Start the Loop
WHILE @StatementMax >= @statementMin
BEGIN
    SELECT @SQLStatement = SQLText FROM @table WHERE RID = @statementMin        -- Get the SQL from the table 
    BEGIN 
        EXECUTE sp_ExecuteSQL @SQLStatement                 -- Execute the SQL 
    END
        DELETE FROM @table WHERE RID = @statementMin        -- Delete the statement just run from the table
        SELECT @statementMIN = MIN(RID)  FROM @Table        -- Update to the next RID
END
