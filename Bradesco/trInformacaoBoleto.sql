USE [CobrancaOnline]
GO
Create Trigger [dbo].[trInformacaoBoleto] On [dbo].[tblBoleto] For Insert, Update 
As
Begin
	Declare 
		 @BoletoId			Bigint
		,@Vencimento		DateTime	
		,@Valor				Decimal(20,2)	
		,@Agencia			Int
		,@DigitoAgencia		Int
		,@Conta				Int	
		,@DigitoConta		Int			
		,@CarteiraString	Varchar(8)		
		,@NossoNumero		Varchar(256)
		,@LinhaDigitavel	Varchar(256)
		,@CedNossoNumero	Bigint
		,@ID				Int
		,@Max				Int
		,@CedId				Int
		,@CodigoBarra		Varchar(128)
		,@DigitoCodigoBarra Int
	
	
	If(Update(BolDataVencimento) Or Update(BolValorTotal) Or Update(CedId))
		Begin
			Select @ID = 1, @Max = Count(BolId) From Inserted Where PortalCobranca = 1
		
			While(@ID <= @Max)
				Begin
					Select 
						@Vencimento			= I.BolDataVencimento
						,@Valor				= I.BolValorTotal
						,@Agencia			= C.CedAgencia
						,@CedId				= I.CedId
						,@CarteiraString	= Format(Cast(C.CedCarteira As Int),'00')
						,@CedNossoNumero	= C.CedNossoNumero
						,@BoletoId			= I.BolId
					From inserted	I
					Join tblCedente	C(Nolock) On I.CedId = C.CedId
					Where PortalCobranca = 1

					Set @NossoNumero = dbo.CalculaNossoNumero(@CarteiraString,@CedNossoNumero,11);
					Set @CodigoBarra = dbo.CalculaCodigoBarra(@NossoNumero,@Vencimento,@CedId,@Valor);
					Set @LinhaDigitavel = dbo.CalculaLinhaDigitavel(@NossoNumero,@Vencimento,237,@CedId,@Valor)
					Set @DigitoCodigoBarra = dbo.CalculaDigitoCodigoBarra(REPLACE(@CodigoBarra,'X',''));

					If(@NossoNumero <> '' And @CodigoBarra <> '' And @LinhaDigitavel <> '' And 
						@LinhaDigitavel IS Not NULL And @CodigoBarra Is Not NULL And @NossoNumero Is Not NULL)
					Begin
						Update tblBoleto 
						Set BolNossoNumero			= @NossoNumero
							,BolCodigoBarra			= REPLACE(@CodigoBarra,'X',Cast(@DigitoCodigoBarra As varchar(128)))
							,BolLinhaDigitavel		= @LinhaDigitavel
						Where BolId	= @BoletoId
					End
			
					Select @ID = @ID + 1		
				End
		End	
End