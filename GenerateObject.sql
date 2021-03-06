Create Procedure GenerateObject 
(  
	@ObjectName varchar(120) = null  
)  
As  
Begin  
 Set nocount on  
 If Object_Id('tempdb..#Tables') Is Not Null Drop Table #Tables  
 If Object_Id('tempdb..#PrimaryKeys') Is Not Null Drop Table #PrimaryKeys  
 If Object_Id('tempdb..#ForeignKeys') Is Not Null Drop Table #ForeignKeys  
 If Object_Id('tempdb..#MappedTypes') Is Not Null Drop Table #MappedTypes 
  
  
 Declare @TableId	Int   
  ,@TableName		Varchar(60)  
  ,@TableMax		Int  
  ,@PrimaryKey		Varchar(60)  
  ,@ForignKey		Varchar(60)  
  ,@ColumnId		Int  
  ,@ColumnName		Varchar(60)  
  ,@TypeName		Varchar(60)  
  ,@ColumnMax		Int  
  ,@Length			Int  
  
 SELECT 
	 SQLTYPE = 'varchar'
	,CSHARPTYPE = 'string'
INTO #MappedTypes
UNION ALL SELECT  
	 SQLTYPE = 'datetime'
	,CSHARPTYPE = 'DateTime?'
UNION ALL SELECT  
	 SQLTYPE = 'smalldatetime'
	,CSHARPTYPE = 'DateTime?'
UNION ALL SELECT  
	 SQLTYPE = 'bigint'
	,CSHARPTYPE = 'long'
UNION ALL SELECT  
	 SQLTYPE = 'bit'
	,CSHARPTYPE = 'bool'
UNION ALL SELECT  
	 SQLTYPE = 'decimal'
	,CSHARPTYPE = 'decimal'
UNION ALL SELECT  
	 SQLTYPE = 'date'
	,CSHARPTYPE = 'DateTime'
UNION ALL SELECT  
	 SQLTYPE = 'time'
	,CSHARPTYPE = 'TimeSpan'	


 Select  
  object_name(constid) IndexName  
 ,object_name(fkeyid) TableName  
 ,object_name(rkeyid) SourceTable Into #ForeignKeys  
 From SysForeignkeys  
  
 SELECT   
  i.name AS IndexName,  
  object_name(ic.OBJECT_ID) AS TableName,  
  col_name(ic.OBJECT_ID,ic.column_id) AS ColumnName Into #PrimaryKeys  
 FROM sys.indexes AS i  
 INNER JOIN sys.index_columns AS ic  
 ON i.OBJECT_ID = ic.OBJECT_ID  
 AND i.index_id = ic.index_id  
 WHERE i.is_primary_key = 1  
  
 Select Identity(Int,1,1) TableId, Name TableName Into #Tables From SysObjects Where Xtype = 'U'And Name Not Like '%sys%' And(Name = @ObjectName Or @ObjectName Is Null)  
 Select @TableId = 1 , @TableMax = Max(TableId) From #Tables  
  
   print   'using System;
using System.Collections.Generic;
using System.Text;
using ' + DB_Name() + '.DataAcess;

namespace ' + DB_Name() + '.Model
{'

 While (@TableId <= @TableMax)  
  Begin  
   Select @TableName = TableName From #Tables Where TableId = @TableId  
   Select @PrimaryKey = ColumnName From #PrimaryKeys Where  TableName = @TableName  
  
  
   If Object_Id('tempdb..#Columns') Is Not Null Drop Table #Columns  
   Select Identity(Int,1,1) ColumnId   
    , Name ColumnName  
    ,Length  
    ,TYPE_NAME(Xtype) TypeName Into #Columns   
   From SysColumns Where Id = Object_Id(@TableName)  
   Select @ColumnId = 1, @ColumnMax = Max(ColumnId) From #Columns   
   
   
print '	public class ' + @TableName 
Print '	{'

	While(@ColumnId <= @ColumnMax)  
		Begin  
			Select @ColumnName = ColumnName, @TypeName = TypeName,@Length = Length From #Columns Where ColumnId = @ColumnId  
			SELECT @TypeName = CSHARPTYPE FROM #MappedTypes WHERE SQLTYPE = @TypeName
			print 
'		public ' + @TypeName + ' ' + @ColumnName + ' { get; set; }'
			Select @ColumnId = @ColumnId + 1  
		End
        
print '	}
    public class ' + @TableName + 'Collection : List<' + @TableName + '> { }'
 Select @TableId = @TableId + 1  
  End  
  Print '}'
End

