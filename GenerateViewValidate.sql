Create Procedure GenerateViewValidate
(
	@ObjectName Varchar(120) = 'Plano'
)
/* Knowledge Base Documentation
<KBDocumentation>
		 <SubSystem>BILLING</SubSystem> 
		 <Description>
		 	Procedure que retorna os o Html para o User Control
		 </Description>
		 <Processing></Processing>
		 <ReturnOutput>See description.</ReturnOutput>
		 <Example>Exec GenerateView2</Example>
		 <Requirement></Requirement>
		 <Creation>
			  <UserID>marcius.pimentel</UserID>
			  <TimeStamp>2011-07-06</TimeStamp>
			  <Comments></Comments>
			  <RequestID></RequestID>
		 </Creation> 
</KBDocumentation> */
As Begin
Set Nocount On;

Select Distinct
	ROW_NUMBER()Over(Order By colid)				  ColumnID
	,C.Name				  ColumnName  
	,Length  		
	,TYPE_NAME(Xtype)	  TypeName
	,object_name(constid) IndexName  
	,object_name(fkeyid)  TableName  
	,object_name(rkeyid)  SourceTable 	
	,C.isnullable		  IsNullLable
Into #TableColumns
From SysColumns  C
Left Join SysForeignkeys	S On C.id = S.fkeyid And C.colid = S.fkey
Where Id = Object_Id(@ObjectName) 


Select 
	ColumnID 
	,ColumnName
	,TypeName
	,IndexName
	,TableName
	,SourceTable
	,IsNullLable
	,FormLabel = Case 
		When IndexName Is Null Then ColumnName
		Else SourceTable
	End
	,FormControl = Case	
			When ColumnID = 1 Then '<asp:Label ID="lbl'+ColumnName+'" runat="server" DataField="'+ColumnName+'"></asp:Label>'
			When TypeName = 'Varchar' Then '<telerik:RadTextBox ID="txt'+ColumnName+'" runat="server" DataField="'+ColumnName+'" Width="200px"></telerik:RadTextBox>'
			When TypeName = 'Int' And IndexName IS Not Null Then '<telerik:RadComboBox ID="ddl'+SourceTable+'" Runat="server" Filter="StartsWith" Height="150px" DataValueField="'+ColumnName+'" DataTextField="Descricao" AllowCustomText="True" EmptyMessage="Selecione um '+SourceTable+'" DataField="'+ColumnName+'" Width="200px"></telerik:RadComboBox>'
			When TypeName = 'Int' And IndexName IS Null Then '<telerik:RadNumericTextBox ID="txt'+ColumnName+'" runat="server" Type="Number" MinValue="0" DataField="'+ColumnName+'" Width="200px"><NumberFormat AllowRounding="False" DecimalDigits="0" GroupSeparator="" /></telerik:RadNumericTextBox>'
			When TypeName = 'Bit' Then '<asp:CheckBox ID="chk'+ColumnName+'" runat="server" DataField="'+ColumnName+'"/>'
			When TypeName = 'Decimal' Then '<telerik:RadNumericTextBox ID="txt'+ColumnName+'" runat="server" Type="Currency" MinValue="0" DataField="'+ColumnName+'" Width="200px"/>'
			When TypeName = 'Datetime' Or TypeName = 'Date' Or TypeName = 'SmallDateTime' Then '<telerik:RadDatePicker ID="txt'+ColumnName+'" runat="server" DataField="'+ColumnName+'" Width="200px"></telerik:RadDatePicker>'
		End
	,FormControlValidate = Case				
			When TypeName = 'Varchar' And IsNUllLable = 0 Then '<telerik:RadTextBox ID="txt'+ColumnName+'" runat="server" DataField="'+ColumnName+'" ValidationGroup="'+@ObjectName+'" ControlToValidate="txt'+ColumnName+'" Width="200px"></telerik:RadTextBox>'			
			When (TypeName = 'Datetime' Or TypeName = 'Date' Or TypeName = 'SmallDateTime') And IsNUllLable = 0 Then '<telerik:RadDatePicker ID="txt'+ColumnName+'" runat="server" DataField="'+ColumnName+'" ValidationGroup="'+@ObjectName+'" ControlToValidate="txt'+ColumnName+'" Width="200px"></telerik:RadDatePicker>'
			When TypeName = 'Decimal' And IsNUllLable = 0 Then '<telerik:RadNumericTextBox ID="txt'+ColumnName+'" runat="server" Type="Currency" MinValue="0" DataField="'+ColumnName+'" ValidationGroup="'+@ObjectName+'" ControlToValidate="txt'+ColumnName+'" Width="200px"/>'
			When TypeName = 'Int' And IndexName IS Null Then '<telerik:RadNumericTextBox ID="txt'+ColumnName+'" runat="server" Type="Number" MinValue="0"  ValidationGroup="'+@ObjectName+'" ControlToValidate="txt'+ColumnName+'" DataField="'+ColumnName+'" Width="200px"><NumberFormat AllowRounding="False" DecimalDigits="0" GroupSeparator="" /></telerik:RadNumericTextBox>'
		Else Null
		End
	,TextBox = Case	
			When (TypeName = 'Varchar' Or  TypeName = 'Datetime' Or TypeName = 'Date' Or TypeName = 'SmallDateTime' Or TypeName = 'Int' Or TypeName = 'Decimal') And IsNullLable = 0 And ColumnID <> 1 Then 'txt'+ColumnName
		Else Null
		End
Into #Table
From #TableColumns

Declare 
	@ContID Int = 1
	,@Quantidade Int
	,@FormControl			Varchar(8000) = Null
	,@FormControlValidate	Varchar(8000) = Null
	,@FormLabel				Varchar(200)= Null

Select @Quantidade = (Select COUNT(1) From #Table)
Print	'<asp:Panel ID="pnlPopup" runat="server" Visible="false">'
Print	'	<table class="bgTable" cellpadding="2" cellspacing="0" style="width: 100%">'
Print	'		<tr ID="PopupHeader" runat="server" Visible="true">'
Print	'			<th colspan="2">'
Print	'				&nbsp;Gerenciamento de '+@ObjectName+'s'
Print	'			</th>'
Print	'			<th style="width: 50px; text-align: right;">'
Print	'				<asp:Button ID="btnFechar" runat="server" Text="X" SkinID="btnClose" CausesValidation="false" onclick="btnFechar_Click" />&nbsp;'
Print	'			</th>'
Print	'		</tr>'
While @ContID <= @Quantidade
Begin
	Select
		@FormLabel = FormLabel
		,@FormControl = FormControl
		,@FormControlValidate = FormControlValidate
	From #Table 
	Where ColumnID = @ContID
	
	If(@ContID = 1)
	Begin
		Print	'		<tr>'
		Print	'			<td class="form-label">'
		Print	'				'+@FormLabel
		Print	'			</td>'
		Print	'			<td class="form-control">'
		Print	'				'+@FormControl
		Print	'			</td>'
		Print	'			<td>'
		Print	'			</td>'
		Print	'		</tr>'
	End
	Else 
		Begin	
		Print	'		<tr>'
		Print	'			<td class="form-label">'
		Print	'				'+@FormLabel
		Print	'			</td>'
		Print	'			<td class="form-control">'
		Print	'				'+IsNull(@FormControlValidate,@FormControl)
		Print	'			</td>'
		Print	'			<td>'
		Print	'			</td>'
		Print	'		</tr>'
	End
	
	Set @ContID = @ContID + 1;
End
Print	'		<tr>'
Print	'			<td colspan="2">'
Print	'				<asp:Button ID="btnSalvar" runat="server" Text="Salvar" ValidationGroup="'+@ObjectName+'" onclick="btnSalvar_Click" />'
Print	'			</td>'
Print	'		</tr>'
Print	'	</table>'
Print	'</asp:Panel>'



Set @ContID = 1
Set @Quantidade = 0

Delete From #Table Where TextBox Is Null

Select 
	Identity(Int,1,1) As TableValidationID
	,ColumnName
	,IsNullLable
	,TextBox
	,FormLabel
Into #TableValidation
From #Table

Print	'<telerik:RadInputManager ID="rim'+@ObjectName+'" runat="server">'
Print	'	<telerik:TextBoxSetting ErrorMessage="Campo Obrigatório">'
Print	'		<TargetControls>'

Set @Quantidade = (Select COUNT(1) From #TableValidation)

While @ContID <= @Quantidade
Begin		
	Select	@FormLabel = FormLabel From #TableValidation Where TableValidationID = @ContID
			
	Print	'			 <telerik:TargetInput ControlID="txt'+@FormLabel+'"/>'		
	
	Set @ContID = @ContID + 1;
End		
Print  '		</TargetControls>'
Print  '		<Validation IsRequired="True" ValidationGroup="'+@ObjectName+'" ValidateOnEvent="Submit" />'
Print  '    </telerik:TextBoxSetting>'	
Print  '</telerik:RadInputManager>'




End


