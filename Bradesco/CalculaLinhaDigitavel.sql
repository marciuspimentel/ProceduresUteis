USE [CobrancaOnline]
GO
Create Function [dbo].[CalculaLinhaDigitavel]
(
	@NossoNumero	Varchar(32)		= ''
	,@Vencimento	Datetime		= ''
	,@Banco			Int				= 237
	,@CedenteId		Int				= 2
	,@Valor			Decimal(20,2)	= 0
) 
Returns Varchar(128)
As Begin

Declare @LinhaDigitavelFormatado	Varchar(128) = NULL

If(@Banco > 0)
Begin	
	Declare @CedAgencia					Int = NULL
			,@CedCarteira				Int = NULL	
			,@CedConta					Int = NULL
			,@DigitoVerificador			Varchar(1) = RIGHT(@NossoNumero,1)
			,@NossoNumeroSemDigito		Varchar(11) = LEFT(@NossoNumero,(LEN(@NossoNumero) - 1))
			,@Bloco1					Varchar(16) = '2379'			
			,@Bloco2					Varchar(16) = ''		
			,@Bloco3					Varchar(16) = ''				
			,@Bloco4					Varchar(16) = ''				
			,@DigitoBloco1Int			Int = 0
			,@DigitoBloco1				Varchar(1) = ''
			,@DigitoBloco2Int			Int = 0
			,@DigitoBloco2				Varchar(1) = ''			
			,@DigitoBloco3Int			Int = 0
			,@DigitoBloco3				Varchar(1) = ''	
			,@DigitoAvulso4				Int = 0			
			,@CodigoBarra				Varchar(64) = ''

	Select	
		@CedAgencia		= CedAgencia
		,@CedCarteira	= CedCarteira
		,@CedConta		= CedConta
	From tblCedente (Nolock)
	Where CedId = @CedenteId

	/*Fator de Vencimento: Indica o vencimento, pois é o nº de dias entre 07/10/97 até o vencimento. 
	Entre 07/10/1997 e 29/06/2009 são 4283 dias, nesse caso o fator de vencimento para um boleto que vença em 29/06/2009 será 4283.
	Select DATEDIFF(DAY,'1997-10-07','2018-04-23') */				

	Select @CodigoBarra = dbo.CalculaCodigoBarra(@NossoNumero,@Vencimento,@CedenteId,@Valor);

	Set @Bloco1 += RIGHT(FORMAT(@CedAgencia,'0000'),4);
	Set @Bloco1 += LEFT(FORMAT(@CedCarteira,'00'),1);		
	Set @DigitoBloco1Int = dbo.CalculaBase10(Cast(@Bloco1 As bigint));
	Set @DigitoBloco1 = Cast(Case When (10 - (@DigitoBloco1Int%10)) = 10 Then 0 Else @DigitoBloco1Int End As varchar(1));	
	Set @Bloco1 += Cast(@DigitoBloco1 As varchar(1));	

	Set @Bloco2	+= RIGHT(FORMAT(@CedCarteira,'00'),1);
	Set @Bloco2	+= LEFT(RIGHT(FORMAT(CAST(@NossoNumeroSemDigito AS bigint),'00000000000000'),11),9);	
	Set @DigitoBloco2Int = dbo.CalculaBase10(Cast(@Bloco2 As bigint));
	Set @DigitoBloco2 = Cast(Case When (10 - (@DigitoBloco2Int%10)) = 10 Then 0 Else @DigitoBloco2Int End As varchar(1));	
	Set @Bloco2 += Cast(@DigitoBloco2 As varchar(1));	

	Set @Bloco3	+= RIGHT(FORMAT(CAST(@NossoNumeroSemDigito AS bigint),'00000000000000'),2);
	Set @Bloco3	+= RIGHT(FORMAT(CAST(@CedConta AS bigint),'0000000'),7);
	Set @Bloco3	+= '0'	;
	Set @DigitoBloco3Int = dbo.CalculaBase10(Cast(@Bloco3 As bigint));
	Set @DigitoBloco3 = Cast(Case When (10 - (@DigitoBloco3Int%10)) = 10 Then 0 Else @DigitoBloco3Int End As varchar(1));	
	Set @Bloco3 += Cast(@DigitoBloco3 As varchar(1));	

	Set @Bloco4 = FORMAT(DATEDIFF(DAY,'1997-10-07',@Vencimento),'0000');
	Set @Bloco4 += FORMAT((@Valor * 100),'0000000000');
	
	Set @DigitoAvulso4 = dbo.CalculaDigitoCodigoBarra(REPLACE(@CodigoBarra,'X',''));--dbo.CalculaBase11(Cast(@Bloco4 As bigint));

	Select @LinhaDigitavelFormatado =
			LEFT(@Bloco1,5)		+ '.'	+
			RIGHT(@Bloco1,5)	+ '  '	+
			LEFT(@Bloco2,5)		+ '.'	+
			RIGHT(@Bloco2,6)	+ '  '	+
			LEFT(@Bloco3,5)		+ '.'	+
			RIGHT(@Bloco3,6)	+ '  '	+ Cast(@DigitoAvulso4 As varchar) + '  ' +
			@Bloco4
End

Return @LinhaDigitavelFormatado;
End
