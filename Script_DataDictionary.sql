Create Procedure SetDescricaoCampo
(
	@Table			Varchar(128) = NULL
	,@Column		Varchar(128) = NULL
	,@Descrption	Varchar(1024) = NULL
)
As Begin
Exec sys.sp_addextendedproperty
		@name		= 'Caption',
		@value		= @Descrption ,
		@level0type	= 'SCHEMA',
		@level0name	= 'dbo',
		@level1type	= 'TABLE',
		@level1name	= @Table,
		@level2type	= 'COLUMN',
		@level2name	= @Column
End 
Go
Create Procedure GetCampoDescricao
(
	@TableName		Varchar(128) = NULL
)
As Begin 
Set Nocount ON;
	Select 
			TableName		= Ob.Name
			,ColumnName		= Co.Name
			,[Description]	= Cast(Po.Value As varchar)
			,DataType		= Cast(Ty.Name As varchar)
			,[Precision]	= Co.Precision
			,[Scale]		= Co.Scale
			,[Nullable]		= Case Co.Is_Nullable When 0 then 'No' else 'Yes' End
			,[Computed]     = Case Co.Is_Computed When 0 then 'No' else 'Yes' End
			,[Identity]		= Case Co.Is_Identity When 0 then 'No' else 'Yes' End
			,[Collate]		= Cast(Co.Collation_name As varchar)
			,[Replicated]   = Case Co.Is_Replicated When 0 then 'No' else 'Yes' End
	From Sys.All_Columns					Co(Nolock)
	Join Sys.Types							Ty(Nolock) On Ty.System_Type_Id = Co.System_Type_id
	Left Outer Join Sys.SysComments			Cc(Nolock) On Cc.Id = Co.Default_Object_Id
	Left Outer Join Sys.Extended_Properties Po(Nolock) On Po.Major_id = Co.Object_Id And Minor_id= Co.Column_Id
	Join Sys.All_Objects					Ob(Nolock) On Ob.Object_Id = Co.Object_Id
	Where Co.Object_Id = Object_Id(@TableName)


End
Go
Create Procedure GetDataBaseDictionary
As Begin
Set Nocount On;

Declare @Tables Table
(
	TableId			Int Identity(1,1) Primary Key
	,TableName		Varchar(512)
)

Insert Into @Tables
(
	TableName
)
Select Distinct 
	TableName		= So.name	
From Sys.Objects			So(Nolock)
Where So.Type = 'U' 

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
	Exec GetCampoDescricao @TableName = @TableName

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
Go
/*O select abaixo vai gerar um resultset com todas as colunas de todas as suas tabelas já no
padrão de criação do dicionário de dados.
Basca voce copiar o resultado, adicionar a info de cada coluna, executar e depois conultar (ultimo passo)*/
SELECT
 ' exec SetDescricaoCampo ''' + t.NAME + ''','''+ c.NAME + ''',''[DESCRIÇÃO CAMPO]'''
FROM sys.objects t INNER JOIN sys.columns c
ON t.OBJECT_ID = c.OBJECT_ID WHERE t.TYPE = 'U' ORDER BY t.NAME, c.NAME