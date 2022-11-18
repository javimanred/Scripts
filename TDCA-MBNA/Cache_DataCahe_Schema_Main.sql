IF NOT EXISTS ( SELECT  *
                FROM    sys.schemas
                WHERE   name = N'Cache' )
    EXEC('CREATE SCHEMA [Cache]');
GO
