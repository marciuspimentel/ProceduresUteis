Create Procedure [dbo].[GenerateProcedureGet]
(
	@ObjectName Varchar(256)= 'Fatura'
)
AS Begin
Set Nocount On;

If Object_Id('tempdb..#ForeignKey') Is Not Null Drop Table #ForeignKey  
If Object_Id('tempdb..#Columns') Is Not Null Drop Table #Columns
If Object_Id('tempdb..#ColumnTable') Is Not Null Drop Table #ColumnTable  
If Object_Id('tempdb..#TableJoin') Is Not Null Drop Table #TableJoin
If Object_Id('tempdb..#ColumnWhere') Is Not Null Drop Table #ColumnWhere

Select 
	ColumnBase			= Cl.name
	,ColumnBaseId		= Cl.column_id
	,TableBaseId		= Cl.object_id
	,ColumnReference	= Fc.name
	,ColumnReferenceId	= Fc.column_id
	,TableReferenceId	= Fc.object_id
	,Schemma			= Sc.name
	,ISNullable			= Fc.is_nullable 
	,TableReference		= Tl.name
	,TablePrefix		= Left(Tl.Name,2)	
Into #ForeignKey
From Sys.columns				Cl(Nolock)
Join Sys.foreign_key_columns	Fk(Nolock)On FK.Parent_column_id = Cl.Column_id And Fk.Parent_object_id = Cl.Object_id
Join Sys.columns				Fc(Nolock)On Fc.object_id = Fk.referenced_object_id and FC.Column_id = Fk.referenced_column_id
Join Sys.tables					Tl(Nolock)On Tl.object_id = Fk.Referenced_object_id And Tl.type = 'U'
Join Sys.schemas				Sc(Nolock)On Sc.schema_id = Tl.schema_id
Where Cl.Object_id = Object_id(@ObjectName)    
Order By Cl.column_id

Create Table #ColumnTable   
(
	ColumnTableId	Int Identity(1,1) Primary Key
	,TableId		Int
	,TableName		Varchar(512)
	,ColumnId		Int
	,ColumnName		Varchar(512)
	,Length			Bigint
	,Scale			Int
	,TypeName		Varchar(512)
	,IsParameter	Bit Default(1)
	,TablePrefix	Varchar(3)
	,IsForeignKey	Bit Default(0)
	,TableJoinId	Int
	,ColumnJoin		Varchar(512)
	,OrderJoin		Int 	
)

Insert Into #ColumnTable
(	
	TableId
	,TableName
	,ColumnId			
	,ColumnName		
	,Length		
	,Scale			
	,TypeName		
	,IsParameter	
	,TablePrefix
	,TableJoinId
	,IsForeignKey
	,ColumnJoin		
	,OrderJoin
)
Select 
	TableId		  = sc.object_id
	,TableName	  = @ObjectName
	,ColumnId	  =	sc.column_id
	,ColumnName   = sc.name 
	,Length		  = Sc.max_length
	,Scale		  = Sc.scale
	,TypeName     = st.name
	,IsParameter  = 1
	,TablePrefix  = Left(@ObjectName,2)
	,TableJoinId  = Fk.referenced_object_id
	,0
	,ColumnJoin	  = Fc.name
	,1
From Sys.Columns					Sc(Nolock)
Join Sys.types						St(Nolock)On Sc.system_type_id = St.system_type_id
Left Join Sys.foreign_key_columns	Fk(Nolock)On FK.Parent_column_id = Sc.Column_id And Fk.Parent_object_id = Sc.Object_id
Left Join Sys.columns				Fc(Nolock)On Fc.object_id = Fk.referenced_object_id and FC.Column_id = Fk.referenced_column_id
Where Sc.object_id = Object_Id(@ObjectName)
Order By Sc.column_id

Insert Into #ColumnTable
(	
	TableId
	,TableName
	,ColumnId		
	,ColumnName		
	,Length			
	,Scale
	,TypeName		
	,IsParameter	
	,TablePrefix
	,TableJoinId
	,IsForeignKey
	,ColumnJoin
	,OrderJoin
)
Select 		
	TableReferenceId
	,Fk.TableReference
	,Fk.ColumnReferenceId
	,ColumName = Fk.TableReference + Cl.name
	,Cl.max_length
	,Cl.scale
	,NULL
	,0
	,Fk.TablePrefix
	,0
	,1
	,Cl.name
	,1
From #ForeignKey	Fk(Nolock)
Join Sys.columns	Cl(Nolock) On Cl.object_id = Fk.TableReferenceId 
Where Cl.name Like '%Descric%'
Or Cl.name Like '%Nome%'
Or Cl.name Like '%RazaoSoci%'
Or Cl.name Like '%Alias%' 
Order By Cl.column_id
 
Insert Into #ColumnTable
(	
	TableId
	,TableName
	,ColumnId		
	,ColumnName		
	,Length			
	,Scale
	,TypeName		
	,IsParameter	
	,TablePrefix
	,TableJoinId
	,IsForeignKey
	,ColumnJoin
	,OrderJoin
)
Select 		
	Fk.TableReferenceId
	,Fk.TableReference
	,Fk.ColumnReferenceId
	,ColumName = Cl.name
	,Cl.max_length
	,Cl.scale
	,NULL
	,0
	,Fk.TablePrefix
	,0
	,1
	,Null
	,1
From #ForeignKey		Fk(Nolock)
Join Sys.columns		Cl(Nolock) On Cl.object_id = Fk.TableReferenceId 
Left Join #ColumnTable	Ct(Nolock) On Fk.ColumnReferenceId = Ct.ColumnId And Fk.TableReferenceId = Ct.TableId And Ct.IsParameter = 0
Where Ct.ColumnId Is NULL
Order By Cl.column_id


If Exists(Select Top 1 1 From #ColumnTable Ct Join #ColumnTable Cj ON Ct.TableId <> Cj.TableId And Ct.TablePrefix = Cj.TablePrefix)
Begin
	Update Ct
	Set TablePrefix = LEFT(UPPER(Ct.TableName),1)+RIGHT(Lower(Ct.TableName),1)
	From #ColumnTable Ct
	Join #ColumnTable Cj ON Ct.TableId <> Cj.TableId And Ct.TablePrefix = Cj.TablePrefix

	If Exists(Select Top 1 1 From #ColumnTable Ct Join #ColumnTable Cj ON Ct.TableId <> Cj.TableId And Ct.TablePrefix = Cj.TablePrefix)
	Begin
		Update Ct
		Set TablePrefix = LEFT(UPPER(Ct.TableName),1)+LEFT(Lower(Ct.TableName),1)
		From #ColumnTable Ct
		Join #ColumnTable Cj ON Ct.TableId <> Cj.TableId And Ct.TablePrefix = Cj.TablePrefix
	End

	If Exists(Select Top 1 1 From #ColumnTable Ct Join #ColumnTable Cj ON Ct.TableId <> Cj.TableId And Ct.TablePrefix = Cj.TablePrefix)
	Begin
		Update Ct
		Set TablePrefix = LEFT(UPPER(Ct.TableName),1)+RIGHT(LEFT(Lower(Ct.TableName),3),1)
		From #ColumnTable Ct
		Join #ColumnTable Cj ON Ct.TableId <> Cj.TableId And Ct.TablePrefix = Cj.TablePrefix
	End
	
	If Exists(Select Top 1 1 From #ColumnTable Ct Join #ColumnTable Cj ON Ct.TableId <> Cj.TableId And Ct.TablePrefix = Cj.TablePrefix)
	Begin
		Update Ci
		Set TablePrefix = LEFT(UPPER(Ci.TableName),1)+ Lower(Left(CHAR(Round(Rand() * 25 + 65, 0)),1))
		From #ColumnTable Ci
		Join (Select 
				Ct.ColumnTableId				
			From #ColumnTable Ct
			Join #ColumnTable Cj ON Ct.TableId <> Cj.TableId And Ct.TablePrefix = Cj.TablePrefix) As T On Ci.ColumnTableId = T.ColumnTableId
		Where Ci.IsParameter = 0
	End

End

Select	Distinct
	ColumnId			= Identity(Int,1,1)
	,ColumnName			= Ct.ColumnName
	,ColumnParameter	= Ct.TablePrefix +'.'+ Case When IsForeignKey = 0 Then Ct.ColumnName Else ISNULL(ColumnJoin,Ct.ColumnName) End
	,TablePrefix		= Ct.TablePrefix 
	,Ct.TypeName
	,Ct.IsForeignKey
	,Ct.IsParameter	
	,Ct.Length
	,Ct.Scale
	,Ct.TableName
	,OrderColumn		= Ct.ColumnId
Into #Columns 
From #ColumnTable		Ct(Nolock)
Order By Ct.IsForeignKey,Ct.ColumnId,Ct.TableName Asc

Create Table #TableJoin 
(
	TableId			Int Identity(1,1) Primary Key
	,TableName		Varchar(512)	
	,IsForeignKey	Bit
	,PrefixFrom		Varchar(5)
	,PrefixTo		Varchar(5)
	,ColumnFrom		Varchar(512)
	,ColumnTo		Varchar(512)
)


;With  TableJoin As 
(
	Select	Distinct	 		
		Cj.TableName
		,Ct.IsForeignKey
		,Ct.IsParameter	
		,PrefixFrom		= Ct.TablePrefix	
		,PrefixTo		= Cj.TablePrefix
		,ColumnFrom		= Ct.ColumnName
		,ColumnTo		= Ct.ColumnJoin
	From #ColumnTable			Ct(Nolock)
	Left Join #ColumnTable		Cj(Nolock) On Ct.TableJoinId = Cj.TableId
	Where Cj.TableName Is Not Null
)
Insert Into #TableJoin
(
	TableName		
	,IsForeignKey	
	,PrefixFrom
	,PrefixTo	
	,ColumnFrom		
	,ColumnTo		
)
Select Top 1		
	Ct.TableName
	,Ct.IsForeignKey	
	,Ct.TablePrefix	
	,NULL
	,ColumnFrom		= NULL
	,ColumnTo		= NULL
From #ColumnTable Ct
Where IsForeignKey = 0 
Union All
Select 
	TableName
	,IsForeignKey	= 1
	,PrefixFrom
	,PrefixTo	
	,PrefixFrom+'.'+ColumnFrom		
	,PrefixTo+'.'+ColumnTo		
From TableJoin

Select 
	ColumnId	= Identity(Int,1,1) 
	,ColumnName = TablePrefix + '.' + ColumnName
	,ColumnParameter = SUBSTRING(ColumnName,CHARINDEX('.',ColumnName)+1,512)
	,TypeName 
	,Length
	,Scale
Into #ColumnWhere
From #Columns 
Where IsParameter = 1

Declare @TableId		Int   
	  ,@TableName		Varchar(60)  
	  ,@TableMax		Int  
	  ,@PrefixFrom 		Varchar(5)
	  ,@PrefixTo 		Varchar(5)
	  ,@ColumnFrom		Varchar(512)
	  ,@ColumnTo		Varchar(512)
	  ,@PrimaryKey		Varchar(60)  
	  ,@ForignKey		Varchar(60)  
	  ,@ColumnId		Int  
	  ,@ColumnName		Varchar(60)  
	  ,@ColumnParameter Varchar(60)
	  ,@TypeName		Varchar(60)  
	  ,@ColumnMax		Int  
	  ,@Length			BigInt  
	  ,@Scale			Int
	  ,@PadRight		Int



Print 'IF OBJECT_ID(''Get'+ @ObjectName +''') IS NOT NULL Drop Procedure Get' + @ObjectName
Print 'GO'  
Print 'Create Procedure dbo.Get' + @ObjectName 
Print '('       
Select @ColumnId = 1    
Select @ColumnMax = Count(1) From #ColumnWhere
Select @PadRight = (Select Top 1 LEN(ColumnParameter) From #ColumnWhere Order By LEN(ColumnParameter) Desc) 

While(@ColumnId <= @ColumnMax)  
Begin  
	Select @ColumnName = ColumnParameter, @TypeName = TypeName,@Length = Length,@Scale = Scale From #ColumnWhere Where ColumnId = @ColumnId         
	If(@ColumnId = 1)  
		Print '    @' + @ColumnName+Replicate(' ',@PadRight - (Len(@ColumnName))) + '  '+ Upper(@TypeName)  + Case When (@Length > 0 And @TypeName In ('Char', 'Varchar', 'NVarchar')) Then '('+Cast(@Length As Varchar)+')' Else '' End + Case When(@TypeName IN ('INT', 'DECIMAL', 'MONEY','NUMERIC')) Then ' = 0' Else ' = NULL' End 
	Else  
		Print '	,@' + @ColumnName+Replicate(' ',@PadRight  - (Len(@ColumnName))) + ' '+ Upper(@TypeName)  + Case When (@Length > 0 And @TypeName In ('Char', 'Varchar', 'NVarchar')) Then '('+Cast(@Length As Varchar)+')' When(@TypeName IN ('DECIMAL','DOUBLE','NUMERIC')) Then '('+Cast(@Length As Varchar)+','+Cast(@Scale As Varchar)+')'  Else '' End + Case When(@TypeName IN ('INT','BIGINT','DECIMAL','DOUBLE','NUMERIC')) Then ' = 0' Else ' = NULL' End
		Select @ColumnId = @ColumnId + 1  
End 
Print ')'  
Print '/* Knowledge Base Documentation'  
Print '<KBDocumentation>'  
Print '		 <SubSystem>'+DB_Name()+'</SubSystem> '
Print '		 <Description>'
Print '		 	Procedure que realiza o Get da Tabela '+@ObjectName
Print '		 </Description>'  
Print '		 <Processing></Processing>'  
Print '		 <ReturnOutput>See description.</ReturnOutput>'  
Print '		 <Example>Exec Get'+@ObjectName+'</Example>'
Print '		 <Requirement></Requirement>'  
Print '		 <Creation>'
Print '			  <UserID>'+SYSTEM_USER+'</UserID>' 
Print '			  <TimeStamp>'+Cast(GETDATE() AS Varchar)+'</TimeStamp>'
Print '			  <Comments></Comments>'  
Print '			  <RequestID></RequestID>'
Print '		 </Creation> ' 
Print '</KBDocumentation> */'    
Print 'As'  
Print 'Begin'        
Print ''
Print 'Select' 
Select @ColumnId = 1  
Select @ColumnMax = Count(1) From #Columns
Select @PadRight = (Select Top 1 LEN(ColumnName) From #Columns Order By LEN(ColumnName) Desc) 
While(@ColumnId <= @ColumnMax)  
Begin  
    Select @ColumnName			= ColumnName
			,@TypeName			= TypeName
			,@Length			= Length 
			,@ColumnParameter	= ColumnParameter
	From #Columns
	Where ColumnId = @ColumnId      	
		   
  If(@ColumnId = 1)  
	Print '    ' + @ColumnName+Replicate(' ',@PadRight - (Len(@ColumnName))) + ' = ' + @ColumnParameter
   Else 
	Print '   ,' + @ColumnName+Replicate(' ',@PadRight - (Len(@ColumnName))) + ' = ' + @ColumnParameter
     Select @ColumnId = @ColumnId + 1  
End  

Select @TableId = 1  
Select @TableMax = Count(1) From #TableJoin
Select @PadRight = ((Select Top 1 Len(TableName) From #TableJoin Order by 1 Desc) + (Select Top 1 Len(TableName) From #TableJoin Order by 1 Asc)) + 10 --Calcula a quantidade de Espaço para Alinhar
While(@TableId <= @TableMax)  
Begin  	
    Select 
		@TableName		= TableName			
		,@ColumnFrom	= ColumnFrom
		,@ColumnTo		= ColumnTo
		,@PrefixFrom	= PrefixFrom
		,@PrefixTo		= PrefixTo
	From #TableJoin
	Where TableId = @TableId	
	
	If(@TableId = 1)
		Print 'From dbo.'+@TableName+Replicate(' ',@PadRight - (Len(@TableName)))+ '       ' + @PrefixFrom + '(Nolock) '
	Else
		Print 'Inner Join dbo.'+@TableName+Replicate(' ',@PadRight - (Len(@TableName))) + ' ' + @PrefixTo + '(Nolock) On ' + @ColumnFrom + ' = ' + @ColumnTo

	Select @TableId += 1;
End
Select @ColumnId = 1  
Select @ColumnMax = Count(1) From #ColumnWhere
Select @PadRight = (Select Top 1 Len(ColumnName) From #ColumnWhere Order by 1 Desc) + 5 --Calcula a quantidade de Espaço para Alinhar
While(@ColumnId <= @ColumnMax)  
Begin  
    Select 
		@ColumnName = ColumnName
		,@ColumnParameter = ColumnParameter
		,@TypeName	= TypeName
		,@Length	= Length 
	From #ColumnWhere Where ColumnId = @ColumnId  
	     
    If(@ColumnId = 1)
		Print 'Where  (' + @ColumnName+Replicate(' ',@PadRight - (Len(@ColumnName))) + ' = @' + @ColumnParameter + ' Or @' + @ColumnParameter + ' = 0)'
	Else 
		Print '   And (' + @ColumnName+Replicate(' ',@PadRight - (Len(@ColumnName))) + ' = @' + @ColumnParameter + ' OR @' + @ColumnParameter + Case When(@TypeName IN ('Int', 'Decimal', 'Money','Numeric')) Then '= 0)' Else  ' IS NULL)' End  
    Select @ColumnId = @ColumnId + 1  
End    
Print ''  
Print 'End'  


End