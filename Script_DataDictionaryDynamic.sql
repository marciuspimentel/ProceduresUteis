Use SISTEL
Go
Create Procedure SetDataDictionaryColumn
(
	@DataBase		Varchar(256) = 'EPBX2'
	,@Table			Varchar(128) = 'Cliente'
	,@Column		Varchar(128) = 'NomeFantasia'
	,@Description	Varchar(1024) = 'Nome Fantasia do Cliente'
)
As Begin
Declare @SQLData Varchar(8000)

	Set @SQLData = 
		'Exec '+@DataBase+'.sys.sp_addextendedproperty
			@name		= ''Caption'',
			@value		= ''' +@Description +''',
			@level0type	= ''SCHEMA'',
			@level0name	= ''dbo'',
			@level1type	= ''TABLE'',
			@level1name	= ''' +@Table+ ''',
			@level2type	= ''COLUMN'',
			@level2name	= ''' +@Column+ ''''

	Exec(@SQLData)
End 
Go
Create Procedure GetDataDictionaryTable
(
	@DataBase		Varchar(256) = 'EPBX2'
	,@TableName		Varchar(128) = 'Cliente'
)
As Begin 
Set Nocount ON;
	Declare @SQLData Varchar(8000)

	Set @SQLData = 
	'Select 
			TableName		= Ob.Name
			,ColumnName		= Co.Name
			,[Description]	= Cast(Po.Value As varchar)
			,DataType		= Cast(Ty.Name As varchar)
			,[Precision]	= Co.Precision
			,[Scale]		= Co.Scale
			,[Nullable]		= Case Co.Is_Nullable When 0 then ''No'' else ''Yes'' End
			,[Computed]     = Case Co.Is_Computed When 0 then ''No'' else ''Yes'' End
			,[Identity]		= Case Co.Is_Identity When 0 then ''No'' else ''Yes'' End
			,[Collate]		= Cast(Co.Collation_name As varchar)
			,[Replicated]   = Case Co.Is_Replicated When 0 then ''No'' else ''Yes'' End
	From '+@DataBase+'.Sys.All_Columns						Co(Nolock)
	Join '+@DataBase+'.Sys.Types							Ty(Nolock) On Ty.System_Type_Id = Co.System_Type_id
	Left Outer Join '+@DataBase+'.Sys.SysComments			Cc(Nolock) On Cc.Id = Co.Default_Object_Id
	Left Outer Join '+@DataBase+'.Sys.Extended_Properties	Po(Nolock) On Po.Major_id = Co.Object_Id And Minor_id= Co.Column_Id
	Join '+@DataBase+'.Sys.All_Objects						Ob(Nolock) On Ob.Object_Id = Co.Object_Id
	Where Co.Object_Id = Object_Id('''+ @DataBase +'.dbo.'+ @TableName +''')'


	Exec(@SQLData)

End
Go
Create Procedure GetDataDictionaryDataBase
(
	@DataBase		Varchar(256) = 'EPBX2'
)
As Begin
Set Nocount On;

Declare @Tables Table
(
	TableId			Int Identity(1,1) Primary Key
	,TableName		Varchar(512)
)

Declare @SQLData Varchar(8000) = Null

Set @SQLData = 
	'Select Distinct TableName		= So.name	
	From '+@DataBase+'.Sys.Objects	So(Nolock)
	Where So.Type = ''U'''


Insert Into @Tables
(
	TableName
)
Exec(@SQLData)

Declare @TableDictionary Table
(
	DictionaryId	Int Identity(1,1) Primary Key
	,TableName		Varchar(512)
	,ColumnName		Varchar(512)
	,[Description]	Varchar(512)
	,DataType		Varchar(512)
	,Percision		Int
	,[Scale]		Int
	,[Nullable]		Varchar(12)
	,[Computed]		Varchar(12)
	,[Identity]		Varchar(12)
	,[Collate]		Varchar(512)
	,[Replicated]   Varchar(12)
)

Declare @Min	Int = 1
		,@Max	Int = Null
		,@TableName Varchar(512) = Null

Select @Max = COUNT(1) From @Tables

While @Min <= @Max
Begin
	Select @TableName = TableName From @Tables Where TableId = @Min

	Insert Into @TableDictionary
	(
		TableName		
		,ColumnName		
		,[Description]
		,DataType		
		,Percision		
		,[Scale]		
		,[Nullable]		
		,[Computed]		
		,[Identity]		
		,[Collate]		
		,[Replicated] 
	)
	Exec GetDataDictionaryTable @DataBase = @DataBase,@TableName = @TableName

	Insert Into @TableDictionary
	(
		TableName		
		,ColumnName		
		,[Description]
		,DataType		
		,Percision		
		,[Scale]		
		,[Nullable]		
		,[Computed]		
		,[Identity]		
		,[Collate]		
		,[Replicated] 
	)
	Values
	(
		Null
		,Null
		,Null
		,Null
		,Null
		,Null
		,Null
		,Null
		,Null
		,Null
		,Null
	)

	Set @Min += 1;

End

Select 
	TableName		
	,ColumnName		
	,[Description]	
	,DataType		
	,Percision		
	,[Scale]		
	,[Nullable]		
	,[Computed]		
	,[Identity]		
	,[Collate]		
	,[Replicated]  
From @TableDictionary
	

End