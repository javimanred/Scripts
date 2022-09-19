USE SSISDB;
SET NOCOUNT ON;
IF object_id('tempdb..#DELETE_CANDIDATES') IS NOT NULL
BEGIN
    DROP TABLE #DELETE_CANDIDATES;
END;

CREATE TABLE #DELETE_CANDIDATES
(
    operation_id bigint NOT NULL PRIMARY KEY
);

DECLARE @DaysRetention int = 30;
INSERT INTO
    #DELETE_CANDIDATES
(
    operation_id
)
SELECT
    IO.operation_id
FROM
    internal.operations AS IO
WHERE
    IO.start_time < DATEADD(day, -@DaysRetention, CURRENT_TIMESTAMP);
SET ROWCOUNT 1000 delete_more:
DELETE T
FROM
    internal.event_message_context AS T
    INNER JOIN
        #DELETE_CANDIDATES AS DC
        ON DC.operation_id = T.operation_id;
IF @@ROWCOUNT > 0
GOTO delete_more
SET ROWCOUNT 0
SET ROWCOUNT 1000 delete_more:
DELETE T
FROM
    internal.event_messages AS T
    INNER JOIN
        #DELETE_CANDIDATES AS DC
        ON DC.operation_id = T.operation_id;
IF @@ROWCOUNT > 0
GOTO delete_more
SET ROWCOUNT 0

SET ROWCOUNT 1000 delete_more:
DELETE T
FROM
    internal.operation_messages AS T
    INNER JOIN
        #DELETE_CANDIDATES AS DC
        ON DC.operation_id = T.operation_id;
IF @@ROWCOUNT > 0
GOTO delete_more
SET ROWCOUNT 0
-- etc
-- Finally, remove the entry from operations

SET ROWCOUNT 1000 delete_more:
DELETE T
FROM
    internal.operations AS T
    INNER JOIN
        #DELETE_CANDIDATES AS DC
        ON DC.operation_id = T.operation_id;
IF @@ROWCOUNT > 0
GOTO delete_more
SET ROWCOUNT 0
