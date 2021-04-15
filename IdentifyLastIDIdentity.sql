DECLARE @SQLQ NVARCHAR(MAX)

SET @SQLQ = 'USE [?]
;WITH  CTE_1
        AS (
			SELECT OBJECT_NAME(a.Object_id) AS table_name,
			OBJECT_SCHEMA_NAME(a.Object_id) AS Schema_name ,
                a.Name AS columnname,
                CONVERT(BIGINT, ISNULL(a.last_value, 0)) AS last_value,
                CASE WHEN b.name = ''tinyint'' THEN 255
                     WHEN b.name = ''smallint'' THEN 32767
                     WHEN b.name = ''int'' THEN 2147483647
                     WHEN b.name = ''bigint'' THEN 9223372036854775807
                END AS dt_value
              FROM sys.identity_columns a 
              INNER JOIN sys.types AS b
              ON
                a.system_type_id = b.system_type_id
           ),
      CTE_2
        AS (SELECT *,
                CONVERT(NUMERIC(18, 2), ((CONVERT(FLOAT, last_value)
                / CONVERT(FLOAT, dt_value)) * 100)) AS "Percent"
              FROM CTE_1
           )
  SELECT DB_NAME(),*
    FROM CTE_2
    WHERE last_value > 0
	order by [Percent] desc;'
	
CREATE TABLE ##idlimit
(
  dbname sysname,
  tablename sysname,
  schemaname sysname,
  columnname sysname,
  last_value bigint,
  dt_value bigint,
  [percent] numeric(5,2)
)

INSERT  INTO ##idlimit
EXEC sp_MSforeachdb @SQLQ

select * from ##idlimit