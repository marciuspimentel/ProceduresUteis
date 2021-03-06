Create Procedure GenerateViewList 
(  
	@ObjectName varchar(120) = 'ClienteEndereco'  
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
  
 Select Identity(Int,1,1) TableId, Name TableName Into #Tables 
 From SysObjects 
Where Xtype = 'U'
	And Name Not Like '%sys%' 
	And(Name = @ObjectName)  
	
Select 
      @TableId = 1 
	, @TableMax   = T.TableId
	, @TableName  = T.TableName
	, @PrimaryKey = P.ColumnName  
From #Tables T
Inner Join #PrimaryKeys P On P.TableName = T.TableName

--Select 
--     @TableId 
--	, @TableMax  
--	, @TableName 
--	, @PrimaryKey

Print '
<%@ Register src="'+@TableName+'Add.ascx" tagname="'+@TableName+'Add" tagprefix="uc1" %>
<asp:UpdateProgress ID="upLista" runat="server" AssociatedUpdatePanelID="uplLista">
    <ProgressTemplate>
        <div class="progessBar">
            Aguarde. Carregando Informações...<br />
            <asp:Image ID="imgpesquisa" runat="server" ImageUrl="~/Images/Icones/progressbar_green.gif" />
        </div>
        <div class="modalBackground">
        </div>
    </ProgressTemplate>
</asp:UpdateProgress>
<asp:UpdatePanel ID="uplLista" runat="server">
    <ContentTemplate>
        <table cellpadding="2" cellspacing="0" style="width: 100%" ID="tbFiltro" runat="server">
            <tr class="HeaderTable">
                <td colspan="3">
                    &nbsp; Consulta de '+@TableName+'s
                </td>
            </tr>
            <tr>
                <td class="form-label" style="width: 120px">
                </td>
                <td class="form-control" style="width: 250px">
                </td>
                <td>
                </td>
            </tr>
            <tr>
                <td class="form-label">
                    Codigo:
                </td>
                <td class="form-control">
                    <telerik:RadTextBox ID="txtCodigo" runat="server" Width="100px">
                    </telerik:RadTextBox>
                </td>
                <td rowspan="3" style="margin-right: 10px; vertical-align: bottom;">
                    <table cellpadding="2">
                        <tr>
                            <td class="box-item" onmouseout="oncolor(this);" onmouseover="overcolor(this);">
                                <div style="text-align: center">
                                    <asp:ImageButton ID="btnPesquisar" runat="server" ImageUrl="~/Images/Icones/hp_bo.png"
                                        OnClick="btnPesquisar_Click" />
                                </div>
                                <div style="text-align: center">
                                    Pesquisar
                                </div>
                            </td>
                            <td class="box-item" onmouseout="oncolor(this);" onmouseover="overcolor(this);">
                                <div style="text-align: center">
                                    <asp:ImageButton ID="btnAdicionar" runat="server" 
                                        ImageUrl="~/Images/Icones/Include.png" onclick="btnAdicionar_Click"/>
                                </div>
                                <div style="text-align: center">
                                    Adicionar
                                </div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td class="form-label">
                    Descrição:
                </td>
                <td class="form-control">
                    <telerik:RadTextBox ID="txtDescricao" runat="server" Width="200px">
                    </telerik:RadTextBox>
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    &nbsp;
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    &nbsp;
                </td>
            </tr>
        </table>
		<table style=''width:100%;''>
			<tr>
				<td>
                    <telerik:RadGrid ID="grvLista" runat="server" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False" OnItemCommand="grvLista_ItemCommand" ShowGroupPanel="True" EnableTheming="False" ShowFooter="True">
                        <HeaderStyle Font-Bold="true" ForeColor="Black"/>
                        <MasterTableView NoMasterRecordsText="Nenhum registro encontrado">
                            <Columns>
                                <telerik:GridTemplateColumn ItemStyle-Width="60px" HeaderText="Ações">
                                    <ItemTemplate>
                                        <asp:ImageButton ID="btnVisualizar" runat="server" CommandArgument=''<%# Eval("'+@PrimaryKey+'") %>'' CommandName="Visualizar" ImageUrl="~/Images/Icones/magnifier.png" ToolTip="Visualizar"/>
                                        <asp:ImageButton ID="btnEditar" runat="server" CommandArgument=''<%# Eval("'+@PrimaryKey+'") %>'' CommandName="Editar" ImageUrl="~/Images/Icones/database_edit.png" ToolTip="Editar"/>
                                        <asp:ImageButton ID="btnExcluir" runat="server" CommandArgument=''<%# Eval("'+@PrimaryKey+'") %>'' CommandName="Excluir" ImageUrl="~/Images/Icones/cross.png" ToolTip="Excluir" OnClientClick="if(confirm(''Deseja realmente excluir este item?'')) return true; else return false;"/>
                                    </ItemTemplate>
                                    <ItemStyle Width="30px"></ItemStyle>
                                    </telerik:GridTemplateColumn>'
   If Object_Id('tempdb..#Columns') Is Not Null Drop Table #Columns  
   Select Identity(Int,1,1) ColumnId   
		, Name ColumnName  
		,Length  
		,TYPE_NAME(Xtype) TypeName 
   Into #Columns   
   From SysColumns Where Id = Object_Id(@TableName)
   
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

                                    
                                    
print'                          <telerik:GridBoundColumn UniqueName="'+@ColumnName+'" DataField="'+@ColumnName+'" HeaderText="'+@ColumnName+'">
                                </telerik:GridBoundColumn>'                                
		Select @ColumnId = @ColumnId + 1  
	End  
                                  

print'                                
                            </Columns>
                        </MasterTableView>
                        <GroupPanel Text="<b>Para agrupar, clique na coluna e arraste aqui</b>">
                        </GroupPanel>
                        <GroupingSettings ShowUnGroupButton="True" />
                        <ClientSettings AllowGroupExpandCollapse="True" ReorderColumnsOnClient="True" AllowDragToGroup="True" AllowColumnsReorder="True" EnableRowHoverStyle="True">
                        </ClientSettings>
                        <HeaderContextMenu EnableAutoScroll="True">
                        </HeaderContextMenu>
                    </telerik:RadGrid>
                </td>
			</tr>
		</table>
                    
        <uc1:'+@TableName+'Add ID="ctrl'+@TableName+'Add" runat="server" />
    </ContentTemplate>
</asp:UpdatePanel>
'
End


