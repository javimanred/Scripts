--Schema objects have to be moved to temporary schema location as schema names are not case sensitive. See below:
--(cant be moved from [PiConfig] to [PIConfig] directly)
--Step1: Transfer from [PiConfig] to [PIConfig2]
--Step2: Transfer from [PIConfig2] to [PIConfig]
DECLARE @OldSchema AS varchar(255)
DECLARE @NewSchema AS varchar(255)
DECLARE @newLine AS varchar(2) = CHAR(13) + CHAR(10)

SET @OldSchema = 'PiConfig'
SET @NewSchema = 'PIConfig2'

DECLARE @sql AS varchar(MAX), @SQLCreateSchema AS VARCHAR(MAX), @SQLDeleteSchema AS VARCHAR(MAX)

SET @SQLCreateSchema = 'CREATE SCHEMA [' + @NewSchema + ']' + @newLine
SET @SQLDeleteSchema = 'DROP SCHEMA [' + @OldSchema + ']' + @newLine
SET @sql = ''
SELECT @sql = @sql + 'ALTER SCHEMA [' + @NewSchema + '] TRANSFER [' + OBJECT_SCHEMA_NAME(object_id) + '].[' + name + ']'
     + @newLine 
--select * 
FROM SYS.objects
WHERE OBJECT_SCHEMA_NAME(object_id) = @OldSchema and  type in ('P','U')


PRINT @SQLCreateSchema
PRINT @sql -- NOTE PRINT HAS AN 8000 byte limit - 8000 varchar/4000 nvarchar - see comments
PRINT @SQLDeleteSchema

--Step1: create new schema
  EXEC (@SQLCreateSchema)
--Step2: transfer tables from old to new schema
	EXEC (@sql)
--Step3: delete old schema
	EXEC (@SQLDeleteSchema)

SET @OldSchema = 'PIConfig2'
SET @NewSchema = 'PIConfig'

DECLARE @sql AS varchar(MAX), @SQLCreateSchema AS VARCHAR(MAX), @SQLDeleteSchema AS VARCHAR(MAX)

SET @SQLCreateSchema = 'CREATE SCHEMA [' + @NewSchema + ']' + @newLine
SET @SQLDeleteSchema = 'DROP SCHEMA [' + @OldSchema + ']' + @newLine
SET @sql = ''
SELECT @sql = @sql + 'ALTER SCHEMA [' + @NewSchema + '] TRANSFER [' + OBJECT_SCHEMA_NAME(object_id) + '].[' + name + ']'
     + @newLine 
--select * 
FROM SYS.objects
WHERE OBJECT_SCHEMA_NAME(object_id) = @OldSchema and  type in ('P','U')


PRINT @SQLCreateSchema
PRINT @sql -- NOTE PRINT HAS AN 8000 byte limit - 8000 varchar/4000 nvarchar - see comments
PRINT @SQLDeleteSchema

--Step1: create new schema
  EXEC (@SQLCreateSchema)
--Step2: transfer tables from old to new schema
	EXEC (@sql)
--Step3: delete old schema
	EXEC (@SQLDeleteSchema)
