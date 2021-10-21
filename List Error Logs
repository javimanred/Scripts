DECLARE @ArchiveID INT
   ,@Filter1Text NVARCHAR(4000)
   ,@Filter2Text NVARCHAR(4000)
   ,@FirstEntry SMALLDATETIME
   ,@LastEntry SMALLDATETIME

SELECT @ArchiveID = 0
   ,@Filter1Text = ''
   ,@Filter2Text = ''
   -- this will only take the logs from the current day,
   --you can change the date ranges to suit your needs
   ,@FirstEntry = DATEADD(DAY, - 1, getdate())
   ,@LastEntry = getdate()

CREATE TABLE #ErrorLog (
   [date] [datetime] NULL
   ,[processinfo] [varchar](2000) NOT NULL
   ,[text] [varchar](2000) NULL
   ) ON [PRIMARY]

INSERT INTO #ErrorLog
EXEC master.dbo.xp_readerrorlog @ArchiveID
   ,1
   ,@Filter1Text
   ,@Filter2Text

   ,@FirstEntry
   ,@LastEntry
   ,N'asc'

SELECT DISTINCT *
FROM (
   SELECT --[date]
      [processinfo]
      ,[text] AS [MessageText]
      ,LAG([text], 1, '') OVER (
         ORDER BY [date]
         ) AS [error]
   FROM #ErrorLog
   ) AS ErrTable
WHERE [error] LIKE 'Error%' 
-- you can change the text to filter above.

DROP TABLE #ErrorLog
