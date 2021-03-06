USE [CobrancaOnline]
GO
Create Function [dbo].[CalculaNossoNumero]
(
	@Carteira	Varchar(2)	= '09'
	,@Id		Bigint		= 0
	,@Modelo	Int			= 11 
) 
Returns Varchar(32)
As Begin

Declare @NossoNumero		Varchar(32) = Null
		,@Numero			Varchar(32) = Null	
		,@DigitoVerificador Varchar(1) = Null
		,@Soma				Int = 0
		,@RestoDivisao		Int = 0

If(@Modelo = 11)
Begin	
	Set @Numero  = @Carteira + FORMAT(@Id,'00000000000');

	Select @Soma = (Cast(Left(@Numero,1) As Int) * 2) +
		   (Cast(Right(Left(@Numero,2),1) As Int) * 7) +
		   (Cast(Right(Left(@Numero,3),1) As Int) * 6) +
		   (Cast(Right(Left(@Numero,4),1) As Int) * 5) +
		   (Cast(Right(Left(@Numero,5),1) As Int) * 4) +
		   (Cast(Right(Left(@Numero,6),1) As Int) * 3) +
		   (Cast(Right(Left(@Numero,7),1) As Int) * 2) +
		   (Cast(Right(Left(@Numero,8),1) As Int) * 7) +
		   (Cast(Right(Left(@Numero,9),1) As Int) * 6) +
		   (Cast(Right(Left(@Numero,10),1) As Int) * 5) +
		   (Cast(Right(Left(@Numero,11),1) As Int) * 4) +
		   (Cast(Right(Left(@Numero,12),1) As Int) * 3) +
		   (Cast(Right(@Numero,1) As Int) * 2);

	Select @RestoDivisao = @Soma%11;

	If(@RestoDivisao = 1)
		Set @DigitoVerificador =  'P';
	Else If(@RestoDivisao = 0)
		Set @DigitoVerificador =  '0';
	Else Set @DigitoVerificador = Cast((11 - @RestoDivisao) As Varchar);

	Select @NossoNumero = FORMAT(@Id,'00000000000') + @DigitoVerificador
End




Return @NossoNumero;
End 
