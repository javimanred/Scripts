IF EXISTS (	SELECT *
			FROM sys.views
			WHERE name = N'SystemParameters')
	DROP VIEW dbo.SystemParameters
GO
