USE [CobrancaOnline]
GO
Create Function [dbo].[CalculaBase11]
(
	@Valor		Bigint = 0
) 
Returns Int 
As Begin

Declare @Numero			Varchar(32) = ''
		,@Soma			Int = 0
		,@IntRetorno	Int = 0		

Set @Numero  = FORMAT(@Valor,'00000000000');

Select @Soma = (Cast(Left(@Numero,1) As Int) * 6) +
		(Cast(Right(Left(@Numero,2),1) As Int) * 5) +
		(Cast(Right(Left(@Numero,3),1) As Int) * 4) +
		(Cast(Right(Left(@Numero,4),1) As Int) * 3) +
		(Cast(Right(Left(@Numero,5),1) As Int) * 2) +
		(Cast(Right(Left(@Numero,6),1) As Int) * 9) +
		(Cast(Right(Left(@Numero,7),1) As Int) * 8) +
		(Cast(Right(Left(@Numero,8),1) As Int) * 7) +
		(Cast(Right(Left(@Numero,9),1) As Int) * 6) +
		(Cast(Right(Left(@Numero,10),1) As Int) * 5) +
		(Cast(Right(Left(@Numero,11),1) As Int) * 4) +
		(Cast(Right(Left(@Numero,12),1) As Int) * 3) +
		(Cast(Right(@Numero,1) As Int) * 2);

Set @IntRetorno = (11 - Cast((@Soma%11) As int));

Return @IntRetorno;

End