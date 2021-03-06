Create Procedure GenerateViewValidateCode
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
  
  
 Declare @TableId Int   
  ,@TableName Varchar(60)  
  ,@TableMax Int  
  ,@PrimaryKey Varchar(60)  
  ,@ForignKey Varchar(60)  
  ,@ColumnId Int  
  ,@ColumnName Varchar(60)  
  ,@TypeName Varchar(60)  
  ,@ColumnMax Int  
  ,@Length Int
  ,@BindCombos Bit = 0
  
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
	,CSHARPTYPE = 'double'
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
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Sistel.Business.' + DB_Name() + ';
using Sistel.Model.' + DB_Name() + ';

namespace ' + DB_Name() + '.Modulos
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
   
   
print '	public partial class ' + @TableName + 'Add : BaseUserControl'
Print '	{'

Print '		protected ' + DB_Name() + 'Manager manager = new ' + DB_Name() + 'Manager();'

Print '
		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				ClearFields();'
   
   If Object_Id('tempdb..#ColumnsSet') Is Not Null Drop Table #ColumnsSet  
   Select Identity(Int,1,1) ColumnId   
    , Name ColumnName  
    ,Length  
    ,TYPE_NAME(Xtype) TypeName Into #ColumnsSet   
   From SysColumns Where Id = Object_Id(@TableName) --AND Name <> 'DataCadastro'
   
   Select @ColumnId = 1, @ColumnMax = Max(ColumnId) From #ColumnsSet

   While(@ColumnId <= @ColumnMax)  
    Begin  
     Select @ColumnName = ColumnName, @TypeName = TypeName,@Length = Length From #ColumnsSet Where ColumnId = @ColumnId
		if RIGHT(@ColumnName,2) = 'Id' And columnproperty(object_id(@TableName),@ColumnName,'IsIdentity') = 0
		Begin
			Select @BindCombos = 1
		End		                      
		Select @ColumnId = @ColumnId + 1  
	End
	if @BindCombos = 1
	Begin
         print '				BindCombos();'
	End
	Print '            }
        }'


		Print '
		public void ClearFields()
        {
            this.Limpar();
        }'

		Print'
		public void LoadFields(Sistel.Model.'+DB_Name()+'.' + @TableName + ' '+LOWER(@TableName)+')
        {
            this.Carregar<' + @TableName + '>('+LOWER(@TableName)+');
        }'

		Print'
		protected void btnSalvar_Click(object sender, EventArgs e)
        {
            Model.Seguranca.Usuario user = ((Model.Seguranca.Usuario)Session["User"]);
            ' + @TableName + ' '+LOWER(@TableName)+' = this.Salvar<' + @TableName + '>();
            ' + @TableName + 'Collection '+LOWER(@TableName)+'s = new ' + @TableName + 'Collection();
            if ('+LOWER(@TableName)+' != null)
            {
                '+LOWER(@TableName)+'.UsuarioId = user.UsuarioId;
                '+LOWER(@TableName)+'.Ativo = true;
                try
                {
                    int '+LOWER(@TableName)+'ID = manager.Set('+LOWER(@TableName)+');
                    ShowMessage(string.Format("' + @TableName + ' {0} salvo com sucesso!", '+LOWER(@TableName)+'ID));
                }
                catch (Exception ex)
                {
                    ShowError("Houve um erro ao salvar!", ex.Message);
                }

            }
            else
            {
                ShowError("Houve um erro ao salvar!");
            }
        }'


		if @BindCombos = 1
		Begin
			 print '
		private void BindCombos()
        {'	
			Select @ColumnId = 1
			While(@ColumnId <= @ColumnMax)  
			Begin  
			 Select @ColumnName = ColumnName, @TypeName = TypeName,@Length = Length From #ColumnsSet Where ColumnId = @ColumnId
				if RIGHT(@ColumnName,2) = 'Id' And @ColumnName <> @TableName + 'Id'
				Begin
					Print '			ddl'+LEFT(@ColumnName,LEN(@ColumnName)-2)+'.DataSource = manager.Get'+LEFT(@ColumnName,LEN(@ColumnName)-2)+'(new '+LEFT(@ColumnName,LEN(@ColumnName)-2)+'()
			{
				Ativo = true,
			});
			ddl'+LEFT(@ColumnName,LEN(@ColumnName)-2)+'.DataBind();
			'
				End		                      
				Select @ColumnId = @ColumnId + 1  
			End
			print '		}'
		End
	Print'	}'
		
	Select @TableId = @TableId + 1  
  End  
  Print '}'
End

