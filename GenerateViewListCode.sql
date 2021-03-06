Create Procedure GenerateViewListCode
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
   
   
print '	public partial class ' + @TableName + 'Lista : BaseUserControl'
Print '	{'

Print '		protected ' + DB_Name() + 'Manager manager = new ' + DB_Name() + 'Manager();'

Print '
		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				BindGrid();'
   
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
		public void BindGrid()
        {
            Model.'+DB_Name()+'.'+@TableName+' '+LOWER(@TableName)+' = new '+@TableName+'()
            {'
			Select @ColumnId = 1			
			While(@ColumnId <= @ColumnMax)  
			Begin  
				Select @ColumnName = ColumnName, @TypeName = TypeName,@Length = Length From #Columns Where ColumnId = @ColumnId  
				SELECT @TypeName = CSHARPTYPE FROM #MappedTypes WHERE SQLTYPE = @TypeName
				if @ColumnName <> 'Ativo'
				Begin
					if RIGHT(@ColumnName,2) <> 'Id' Or columnproperty(object_id(@TableName),@ColumnName,'IsIdentity') = 1
					Begin
						print  '				'+@ColumnName + ' = txt' + @ColumnName + '.Text.To' + UPPER(LEFT(@TypeName,1))+SUBSTRING(@TypeName,2,LEN(@TypeName))  + '(),' 
					End
					Else
					Begin
						print  '				'+@ColumnName + ' = ddl' + @ColumnName + '.SelectedValue.ToInt(),' 
					End
				End
				Select @ColumnId = @ColumnId + 1  
			End
			Print '			};
            grvLista.DataSource = this.CacheDataSource = manager.Get'+@TableName+'('+LOWER(@TableName)+');
            grvLista.DataBind();
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
	Select @ColumnId = 1, @ColumnMax = Max(ColumnId) From #ColumnsSet

	   While(@ColumnId <= @ColumnMax)  
		Begin  
		 Select @ColumnName = ColumnName, @TypeName = TypeName,@Length = Length From #ColumnsSet Where ColumnId = @ColumnId
			if CHARINDEX('id',@ColumnName) > 0 And @ColumnName <> @TableName + 'Id'
			Begin
				Select @BindCombos = 1
			End		                      
			Select @ColumnId = @ColumnId + 1  
		End


		Print'
		protected void btnPesquisar_Click(object sender, ImageClickEventArgs e)
        {
            BindGrid();
        }

        protected void btnAdicionar_Click(object sender, ImageClickEventArgs e)
        {
            ctrl'+@TableName+'Add.Carregar<'+@TableName+'>(new '+@TableName+'());
        }'

		
		Print'
        protected void grvLista_ItemCommand(object source, Telerik.Web.UI.GridCommandEventArgs e)
        {
            switch (e.CommandName)
            {
                case ("Editar"):

                    Model.'+DB_Name()+'.'+@TableName+' '+LOWER(@TableName)+' = manager.Get'+@TableName+'(new '+@TableName+'()
                    {
                        '+@TableName+'Id = e.CommandArgument.ToInt(),
                        Ativo = true,
                    })[0];

                    ctrl'+@TableName+'Add.LoadFields('+LOWER(@TableName)+');
                    ctrl'+@TableName+'Add.Exibir(750);
                    break;
                case ("Excluir"):
                    int '+LOWER(@TableName)+'ID = manager.Set(new '+@TableName+'()
                    {
                        Ativo = false,
                        '+@TableName+'Id = e.CommandArgument.ToInt(),
                    });
                    ShowMessage("Excluído com Sucesso");
                    BindGrid();
                    break;
            }
        }'

		Print '
        protected void ChildUserControl_Hide()
        {
            BindGrid();
            uplLista.Update();
        }

        protected void grvLista_PageIndexChanged(object source, Telerik.Web.UI.GridPageChangedEventArgs e)
        {
            BindGrid();
        }

        protected void grvLista_NeedDataSource(object source, Telerik.Web.UI.GridNeedDataSourceEventArgs e)
        {
            grvLista.DataSource = this.CacheDataSource;
        }

        protected void grvLista_PageSizeChanged(object source, Telerik.Web.UI.GridPageSizeChangedEventArgs e)
        {
            BindGrid();
        }

        protected void grvLista_SortCommand(object source, Telerik.Web.UI.GridSortCommandEventArgs e)
        {
            BindGrid();
        }

        protected void grvLista_GroupsChanging(object source, Telerik.Web.UI.GridGroupsChangingEventArgs e)
        {
            BindGrid();
        }'

	Print'	}'
		
	Select @TableId = @TableId + 1  
  End  
  Print '}'
End

