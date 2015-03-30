Create Procedure CopyFiles
(	
	@PathSource			Varchar(512)
	,@PathDestination	Varchar(512)	
)
As
Begin
Set Nocount ON

Declare @Command Varchar(1000),@FullPath Varchar(1024)

Create Table #Diretorio
(
	DiretorioId				Int Identity(1,1) Primary Key
	,FileExists				Bit
	,DirectoryExists		Bit
	,ParentDirectoryExists	Bit
)

If(Right(@PathDestination,1) <> '\')
	Set @PathDestination = @PathDestination + '\'

If(Right(@PathSource,1) <> '\')
	Set @PathSource = @PathSource + '\'


Insert Into #Diretorio
(
	FileExists				
	,DirectoryExists		
	,ParentDirectoryExists
)
Exec Master.dbo.xp_fileexist @PathDestination

Declare @CommandCopy Varchar(1024)
Set @CommandCopy = 'xcopy ' + @PathSource +'*.* '  + @PathDestination		

If Exists (Select Top 1 1 From #Diretorio Where DirectoryExists = 1)
Begin

	------------------------------
	--Copia os Arquivos da Pasta--
	------------------------------
	Exec Master.dbo.xp_cmdshell @CommandCopy , no_output
End
Else 
	Begin
		Set @Command = 'mkdir ' + @PathDestination

		------------------------------------
		--Cria o Diretório caso não exista--
		------------------------------------

		Exec Master.dbo.xp_cmdshell @Command , no_output	

		------------------------------
		--Copia os Arquivos da Pasta--
		------------------------------
		Exec Master.dbo.xp_cmdshell @CommandCopy , no_output	
	End

Set Nocount OFF

End
