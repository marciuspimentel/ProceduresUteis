Create Procedure GenerateFileBCP
(
	@Directory		NVarchar(1024)	= Null
	,@FileName		NVarchar(256)	= Null
	,@UserName		NVarchar(256)	= Null
	,@Password		NVarchar(256)	= Null
	,@TableName		NVarchar(512)	= Null
	,@DataBase		NVarchar(256)	= Null
	,@Delimiter		NVarchar(1)		= ';'
	,@Header		NVarchar(512)	= Null
)
As Begin
Set Nocount On;
Begin Try

If OBJECT_ID('Tempdb.dbo.##TableBCP') Is Not Null
	Drop Table ##TableBCP

Create Table ##TableBCP
(
	TableColumn		Varchar(2048)
)

If(@Header Is Not NULL)
Begin
	Insert Into ##TableBCP(TableColumn)
	Values (@Header)
End

If OBJECT_ID('Tempdb.dbo.##TableColumns') Is Not Null
	Drop Table ##TableColumns

Create Table ##TableColumns
(
	Id				Int Identity(1,1) Primary Key
	,ColumnName		Varchar(256)
)

Declare @CommandSysColumn Varchar(1024) = Null
	    ,@TableObjectId	  Bigint = 0

Declare @TableObject Table
(
	Id	Bigint
)
Insert @TableObject
Exec('Select OBJECT_ID('''+@TableName+''')')

Select @TableObjectId = Id From @TableObject;

Set @CommandSysColumn = 'Insert ##TableColumns Select Name From Sys.columns Where Object_Id = Cast('''+Cast(@TableObjectId As Varchar)+''' As Bigint)';

Exec(@CommandSysColumn)

If Exists(Select Top 1 1 From ##TableColumns)
Begin
	Declare @Min				Int = 1
			,@Max				Int = 0
			,@ColumnConcat		Varchar(512) = ''

	Select @Max = Count(1)
	From ##TableColumns

	While @Min <= @Max
	Begin
		Select @ColumnConcat += +'Cast( ' + ColumnName +' As Varchar) ' + (Case When @Min = @Max Then '' Else '+' + ''';''' + '+' End) 
		From ##TableColumns Where Id = @Min

		Set @Min +=1;
	End
		
	Declare @CommandSelect	Varchar(1024) = Null

	Set @CommandSelect = 'Insert ##TableBCP Select ' + @ColumnConcat + ' As select1 From ' + @TableName

	Exec(@CommandSelect);
End

Declare @ErrorMessage NVarchar(max), @ErrorSeverity Int, @ErrorState Int;

Declare @SqlCommand			NVarchar(2048) = Null
		,@FullDirectory		NVarchar(512)  = Null

Set @FullDirectory = @Directory + '\' + @FileName;
Set @SqlCommand = 'bcp ##TableBCP out "'+@FullDirectory+'" -T -c -U'+@UserName+' -P'+@Password+'';

--Print @SqlCommand;
Exec Master..xp_cmdshell @SqlCommand

End Try
Begin Catch
	Select @ErrorMessage = ERROR_MESSAGE() + ' Line ' + cast(ERROR_LINE() as nvarchar(5)), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
	RaisError(@ErrorMessage, @ErrorSeverity, @ErrorState);
End Catch

End
