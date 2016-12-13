Create Function GetTableSize
(
	@TableName		Varchar(256) = 'LogRequest'	
)
Returns @TableSize Table
(
	TableId					Int Identity(1,1) Primary Key
	,TableName				Varchar(256)
	,SchemaName				Varchar(256)
	,RowCounts				Int
	,TotalSpaceMB			Int
	,UsedSpaceMB			Int
	,UnusedSpaceMB			Int
)	
As Begin 

	Insert Into @TableSize
	(
		TableName			
		,SchemaName			
		,RowCounts			
		,TotalSpaceMB		
		,UsedSpaceMB		
		,UnusedSpaceMB		
	)
	Select
		TableName		= t.NAME
		,SchemaName		= s.Name
		,RowCounts		= p.Rows
		,TotalSpaceMB	= (SUM(a.total_pages) * 8)/1024
		,UsedSpaceMB	= (SUM(a.used_pages) * 8)/1024
		,UnusedSpaceMB  = ((SUM(a.total_pages) - SUM(a.used_pages)) * 8)/1024
	From sys.tables					t (Nolock)
	Inner Join sys.indexes			i (Nolock)On t.OBJECT_ID = i.object_id
	Inner Join sys.partitions		p (Nolock)On i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	Inner Join sys.allocation_units a (Nolock)ON p.partition_id = a.container_id
	Left Outer Join sys.schemas		s (Nolock)ON t.schema_id = s.schema_id
	Where t.NAME LIKE @TableName + '%' 
		AND t.is_ms_shipped = 0
		AND i.OBJECT_ID > 255 
	Group By t.Name, s.Name, p.Rows

End