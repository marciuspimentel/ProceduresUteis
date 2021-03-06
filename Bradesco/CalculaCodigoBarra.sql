USE [CobrancaOnline]
GO
Create Function [dbo].[CalculaCodigoBarra]
(
	@NossoNumero	Varchar(32)		= ''
	,@Vencimento	Datetime		= ''	
	,@CedenteId		Int				= 2
	,@Valor			Decimal(20,2)	= 0
) 
Returns Varchar(128)
As Begin

Declare @CedAgencia					Int = NULL
		,@CedCarteira				Int = NULL	
		,@CedConta					Int = NULL
		,@DigitoVerificador			Varchar(1) = RIGHT(@NossoNumero,1)
		,@NossoNumeroSemDigito		Varchar(11) = LEFT(@NossoNumero,(LEN(@NossoNumero) - 1))
		,@Bloco						Varchar(128) = ''					

Select	
	@CedAgencia		= CedAgencia
	,@CedCarteira	= CedCarteira
	,@CedConta		= CedConta
From tblCedente (Nolock)
Where CedId = @CedenteId

/*Fator de Vencimento: Indica o vencimento, pois é o nº de dias entre 07/10/97 até o vencimento. 
Entre 07/10/1997 e 29/06/2009 são 4283 dias, nesse caso o fator de vencimento para um boleto que vença em 29/06/2009 será 4283.
Select DATEDIFF(DAY,'1997-10-07','2018-04-23') */				

Set @Bloco += '2379X';
Set @Bloco += FORMAT(DATEDIFF(DAY,'1997-10-07',@Vencimento),'0000');	
Set @Bloco += FORMAT((@Valor * 100),'0000000000');	
Set @Bloco += RIGHT(FORMAT(@CedAgencia,'0000'),4);
Set @Bloco += RIGHT(FORMAT(@CedCarteira,'00'),2);
Set @Bloco += RIGHT(FORMAT(CAST(@NossoNumeroSemDigito AS bigint),'00000000000000'),11);
Set @Bloco += RIGHT(FORMAT(CAST(@CedConta AS bigint),'0000000'),7);
Set @Bloco += '0';

Return @Bloco;

End