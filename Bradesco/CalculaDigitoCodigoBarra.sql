USE [CobrancaOnline]
GO
Create Function [dbo].[CalculaDigitoCodigoBarra]
(
	@CodigoBarra			Varchar(64) = 0
) 
Returns Int 
As Begin

Declare @Posicao			Int = 0
		,@Tamanho			Int = 43		
		,@Multiplicador		Int = 2
		,@Valor				Int = 0
		,@LinhaReverse		Varchar(64) = Null
		,@ValorSoma			Int = 0

Select @LinhaReverse = REVERSE(@CodigoBarra);
		
While @Posicao < @Tamanho
Begin
	If(@Multiplicador = 10)
		Set @Multiplicador = 2;

	Select @Valor = LEFT(RIGHT(@LinhaReverse,(@Tamanho - @Posicao)),1);
	Select @ValorSoma += @Valor * @Multiplicador;	
	
	Set @Multiplicador += 1;
	Set @Posicao += 1;
End

Return Case When (11 - Cast((@ValorSoma%11) As int)) In (0,1,10) Then 1 Else (11 - Cast((@ValorSoma%11) As int)) End;

End		

