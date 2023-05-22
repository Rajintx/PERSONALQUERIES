 
set quoted_identifier on
DECLARE @DatabaseName NVARCHAR(128)
SET @DatabaseName = 'NMCCOOPSHOP'

DECLARE @TableName NVARCHAR(128)
DECLARE @IndexName NVARCHAR(128)
DECLARE @SchemaName NVARCHAR(128)
DECLARE @SQL NVARCHAR(MAX)

DECLARE c CURSOR FOR
SELECT s.name, t.name, i.name
FROM sys.schemas s
INNER JOIN sys.tables t ON s.schema_id = t.schema_id
INNER JOIN sys.indexes i ON t.object_id = i.object_id
WHERE i.index_id > 0 AND i.type_desc <> 'HEAP'
AND t.is_ms_shipped = 0
AND i.is_disabled = 0
AND i.is_hypothetical = 0


OPEN c
FETCH NEXT FROM c INTO @SchemaName, @TableName, @IndexName

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'ALTER INDEX '+ quotename(@IndexName) + '  ON  ' + quotename(@SchemaName) + '.' + quotename(@TableName) + ' REORGANIZE;'
    PRINT @SQL+'completed'
    EXEC sp_executesql @SQL

    FETCH NEXT FROM c INTO @SchemaName, @TableName, @IndexName
END

CLOSE c
DEALLOCATE c