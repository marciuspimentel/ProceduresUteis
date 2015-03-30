Create Procedure GenerateProcedureSET
(  
	@ObjectName varchar(120) = 'CLiente'  
)  
As  
Begin  
Set nocount ON;
 
 If Object_Id('tempdb..#Tables') Is Not Null Drop Table #Tables  
 If Object_Id('tempdb..#PrimaryKeys') Is Not Null Drop Table #PrimaryKeys    
  
 Declare 
	@TableId		Int   
	,@TableName		Varchar(60)  
	,@TableMax		Int  
	,@PrimaryKey	Varchar(60)  
	,@ForignKey		Varchar(60)  
	,@ColumnId		Int  
	,@ColumnName	Varchar(60)  
	,@TypeName		Varchar(60)  
	,@ColumnMax		Int  
	,@Length		BigInt  
	,@Scale			Int
	,@PadRight		Int

  
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
  
While (@TableId <= @TableMax)  
Begin  
	Select @TableName = TableName From #Tables Where TableId = @TableId  
	Select @PrimaryKey = ColumnName From #PrimaryKeys Where  TableName = @TableName    

   If Object_Id('tempdb..#ColumnsSet') Is Not Null Drop Table #ColumnsSet  
   Select 
	   ColumnId		  = Identity(Int,1,1) 
 		,ColumnName   = sc.name 
		,Length		  = Sc.max_length
		,Scale		  = Sc.scale
		,TypeName     = st.name
   Into #ColumnsSet   
   From Sys.Columns	 Sc(Nolock)
   Join Sys.types	 St(Nolock)On Sc.system_type_id = St.system_type_id
   Where Sc.object_id = Object_Id(@ObjectName)
   Order By column_id
   
   Select @ColumnId = 1, @ColumnMax = Max(ColumnId) From #ColumnsSet
   Select @PadRight = (Select Top 1 LEN(ColumnName) From #ColumnsSet Order By LEN(ColumnName) Desc) 

   Print 'USE ' + DB_Name()  
   Print 'GO'  
   Print 'If OBJECT_ID(''Set'+@TableName+''') IS NOT NULL Drop Procedure dbo.Set' + @TableName+''  
   Print 'Go'  
   Print 'Create Procedure dbo.Set'+@TableName  
   Print '('    
 
   While(@ColumnId <= @ColumnMax)  
    Begin  
		Select	
			@ColumnName = ColumnName
			,@TypeName	= TypeName
			,@Length	= Length 
			,@Scale		= Scale
		From #ColumnsSet Where ColumnId = @ColumnId
       
		If(@ColumnId = 1)  
			Print '	 @' + Master.dbo.PadRight(@ColumnName,@PadRight,' ') + ' '+ Upper(@TypeName)  + Case When (@Length > 0 And @TypeName In ('Char', 'Varchar', 'NVarchar')) Then '('+Cast(@Length As Varchar)+')' Else '' End + Case When(@TypeName IN ('INT', 'DECIMAL', 'MONEY','NUMERIC')) Then ' = 0' Else ' = NULL' End 
		Else  
			Print '	,@' + Master.dbo.PadRight(@ColumnName,@PadRight,' ') + ' '+ Upper(@TypeName)  + Case When (@Length > 0 And @TypeName In ('Char', 'Varchar', 'NVarchar')) Then '('+Cast(@Length As Varchar)+')' When(@TypeName IN ('DECIMAL','DOUBLE','NUMERIC')) Then '('+Cast(@Length As Varchar)+','+Cast(@Scale As Varchar)+')'  Else '' End + Case When(@TypeName IN ('INT','BIGINT','DECIMAL','DOUBLE','NUMERIC')) Then ' = 0' Else ' = NULL' End

		Select @ColumnId = @ColumnId + 1  
	End  
   Print ')'  
   Print '/* Knowledge Base Documentation'  
   Print '<KBDocumentation>'  
   Print '		 <SubSystem>'+DB_Name()+'</SubSystem> '
   Print '		 <Description>'
   Print '		 	Procedure que realiza o Set da Tabela '+@TableName
   Print '		 </Description>'  
   Print '		 <Processing></Processing>'  
   Print '		 <ReturnOutput>See description.</ReturnOutput>'  
   Print '		 <Example></Example>  '
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
   Print '  If(@'+@PrimaryKey+' = 0)'   
   Print '  Begin'  
   Print '    Insert Into dbo.' + @TableName  
   Print '    ('  
     
   Select @ColumnId = 1  
  
   While(@ColumnId <= @ColumnMax)  
    Begin  
     Select @ColumnName = ColumnName, @TypeName = TypeName,@Length = Length From #ColumnsSet Where ColumnId = @ColumnId  
       
     If(@ColumnId = 2 And @ColumnName <> @PrimaryKey)  
   Print '		' + @ColumnName+ '  '  
     Else If(@ColumnName <> @PrimaryKey)   
   Print '		,' + @ColumnName+ '  '  
     Select @ColumnId = @ColumnId + 1  
    End  
  
   Print '    )'  
   Print '    Values'  
   Print '    ('  
  
   Select @ColumnId = 1  
  
   While(@ColumnId <= @ColumnMax)  
    Begin  
     Select @ColumnName = ColumnName, @TypeName = TypeName,@Length = Length From #ColumnsSet Where ColumnId = @ColumnId  
       
     If(@ColumnId = 2 And @ColumnName <> @PrimaryKey)  
   Print '		@' + @ColumnName+ '  '  
     Else If(@ColumnName <> @PrimaryKey)   
   Print '		,@' + @ColumnName+ '  '  
     Select @ColumnId = @ColumnId + 1  
    End    
   Print '	)'  
   Print '	Select @'+@PrimaryKey +' = @@IDENTITY'  
   Print '  End'  
   Print '  Else'  
   Print '   Begin'  
   Print '		Update dbo.'+@TableName 
   Print '		Set'  
     
   Select @ColumnId = 1  
  
   While(@ColumnId <= @ColumnMax)  
    Begin  
     Select @ColumnName = ColumnName, @TypeName = TypeName,@Length = Length From #ColumnsSet Where ColumnId = @ColumnId  
       
     If(@ColumnId = 2 And @ColumnName <> @PrimaryKey)  
   Print '			 ' + Master.dbo.PadRight(@ColumnName,@PadRight,' ') + ' = ISNULL(@'+@ColumnName+','+@ColumnName+')'  
     Else If(@ColumnName <> @PrimaryKey)   
   Print '			,' + Master.dbo.PadRight(@ColumnName,@PadRight,' ') + ' = ISNULL(@'+@ColumnName+','+@ColumnName+')'  
     Select @ColumnId = @ColumnId + 1  
    End  
   Print '			Where ' + @PrimaryKey + ' = @' + @PrimaryKey  
   Print '		End'  
   Print ''
   Print '  Select @'+ @PrimaryKey  
   Print ''
   Print 'End'  
   Print 'Go '  


   Select @TableId += 1;
End

End