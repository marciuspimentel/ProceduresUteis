USE [CobrancaOnline]
GO
Create Function [dbo].[CalculaBase10]
(
	@Valor		Bigint = 0
) 
Returns Int 
As Begin

Declare @Numero			Varchar(32) = ''
		,@Soma			Int = 0
		,@IntRetorno	Int = 0
		,@Soma1			Int = 0
		,@Soma2			Int = 0
		,@Soma3			Int = 0
		,@Soma4			Int = 0
		,@Soma5			Int = 0
		,@Soma6			Int = 0
		,@Soma7			Int = 0
		,@Soma8			Int = 0
		,@Soma9			Int = 0
		,@Soma0			Int = 0


Set @Numero  = FORMAT(@Valor,'0000000000');

Set @Soma0 = (Cast(Left(@Numero,1) As Int) * 1);
Set @Soma1 = (Cast(Right(Left(@Numero,2),1) As Int) * 2);
Set @Soma2 = (Cast(Right(Left(@Numero,3),1) As Int) * 1);
Set @Soma3 = (Cast(Right(Left(@Numero,4),1) As Int) * 2);
Set @Soma4 = (Cast(Right(Left(@Numero,5),1) As Int) * 1);
Set @Soma5 = (Cast(Right(Left(@Numero,6),1) As Int) * 2);
Set @Soma6 = (Cast(Right(Left(@Numero,7),1) As Int) * 1);
Set @Soma7 = (Cast(Right(Left(@Numero,8),1) As Int) * 2);
Set @Soma8 = (Cast(Right(Left(@Numero,9),1) As Int) * 1);
Set @Soma9 = (Cast(Right(@Numero,1) As Int) * 2);

Select @Soma = 
		(Case When @Soma0 > 10 Then (Cast(LEFT(@Soma0,1) As int) + Cast(RIGHT(@Soma0,1) As Int)) Else  @Soma0 End) +  		
		(Case When @Soma1 > 10 Then (Cast(LEFT(@Soma1,1) As Int) + Cast(RIGHT(@Soma1,1) As Int)) Else  @Soma1 End) +  		
		(Case When @Soma2 > 10 Then (Cast(LEFT(@Soma2,1) As Int) + Cast(RIGHT(@Soma2,1) As Int)) Else  @Soma2 End) +  		
		(Case When @Soma3 > 10 Then (Cast(LEFT(@Soma3,1) As Int) + Cast(RIGHT(@Soma3,1) As Int)) Else  @Soma3 End) +  		
		(Case When @Soma4 > 10 Then (Cast(LEFT(@Soma4,1) As Int) + Cast(RIGHT(@Soma4,1) As Int)) Else  @Soma4 End) +  		
		(Case When @Soma5 > 10 Then (Cast(LEFT(@Soma5,1) As Int) + Cast(RIGHT(@Soma5,1) As Int)) Else  @Soma5 End) +  		
		(Case When @Soma6 > 10 Then (Cast(LEFT(@Soma6,1) As Int) + Cast(RIGHT(@Soma6,1) As Int)) Else  @Soma6 End) +  		
		(Case When @Soma7 > 10 Then (Cast(LEFT(@Soma7,1) As Int) + Cast(RIGHT(@Soma7,1) As Int)) Else  @Soma7 End) +  		
		(Case When @Soma8 > 10 Then (Cast(LEFT(@Soma8,1) As Int) + Cast(RIGHT(@Soma8,1) As Int)) Else  @Soma8 End) + 				
		(Case When @Soma9 > 10 Then (Cast(LEFT(@Soma9,1) As Int) + Cast(RIGHT(@Soma9,1) As Int)) Else  @Soma9 End); 

Set @IntRetorno = (10 - Cast((@Soma%10) As int));

Return @IntRetorno;

End