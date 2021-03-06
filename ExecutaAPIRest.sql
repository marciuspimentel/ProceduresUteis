﻿Create Procedure ExecutaAPIRest
(
	@URL			Varchar(1024)	= NULL
	,@VERB			Varchar(12)		= NULL
	,@ContentType		Varchar(254)	= 'application/json'
	,@PostString		Varchar(Max)	= NULL
)
As Begin
Set Nocount ON;

Declare @Object			Int = 0
	,@ResponseText		Varchar(8000) = NULL
	,@CodeError		Int = 0;

Declare @Source		Varchar(255)
	,@Description	Varchar(255)   

Declare @ResultTable Table (Xml_result varchar(Max));

Exec @CodeError = sp_OACreate 'MSXML2.ServerXMLHTTP.3.0', @Object OUT;

If(@CodeError <> 0)
    Exec sp_OAGetErrorInfo @Object, @Source OUT, @Description OUT        	
Else
Begin
	Exec @CodeError = sp_OAMethod @Object, 'open', NULL, @ContentType, @url,'false','d0b1a0aaed2a529356471de4fe99cae2','8e7aa1a91fa68d06cd027914d3aa1140'
    If (@CodeError <> 0)
	Begin
		Exec @ResponseText = sp_OAGetErrorInfo @Object, @Source OUT, @Description OUT
        Set @ResponseText = 'Open '+ IsNulL(@Description,'No Description');
	End
    Else
    Begin
        Exec @CodeError = sp_OAMethod @Object, 'setRequestHeader', NULL, 'User-Agent', 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)'
        If(@CodeError <> 0)
		Begin		
			Exec @ResponseText = sp_OAGetErrorInfo @Object, @Source OUT, @Description OUT
            Set @ResponseText ='setRequestHeader:User-Agent '+ IsNulL(@Description,'No Description');
		End
        Else
        Begin
            Exec @CodeError = sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', @ContentType
            If (@CodeError<>0)
			Begin
				Exec @ResponseText = sp_OAGetErrorInfo @Object, @Source OUT, @Description OUT
                Set @ResponseText='setRequestHeader:Content-Type '+ IsNulL(@Description,'No Description');
			End
            Else
            Begin
                Exec @CodeError = sp_OAMethod @Object, 'send', Null, @PostString
                If (@CodeError<>0)
				Begin				
					Exec @ResponseText = sp_OAGetErrorInfo @Object, @Source OUT, @Description OUT
                    Set @ResponseText='setRequestHeader:Content-Type '+ IsNulL(@Description,'No Description');
				End
                Else
                Begin
                    Set @ResponseText = Null--make sure we don't return garbage
                    INSERT @ResultTable (xml_result)
                    Exec @CodeError = sp_OAGetProperty @Object, 'responseText' 
                    If (@CodeError<>0)
					Begin
						Exec @ResponseText = sp_OAGetErrorInfo @Object, @Source OUT, @Description OUT
						Set @ResponseText='responseText '+ IsNulL(@Description,'No Description');
					End                        
                    Else SELECT @ResponseText = xml_result FROM @ResultTable
                End
            End
        End
	End
End

Set @Description = ISNULL(@Description,'No Description');


Exec sp_OAMethod @Object, 'open',NULL,@VERB ,@URL,'false';
Exec sp_OAMethod @Object, 'send';
Exec sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;
Exec sp_OADestroy @Object;

Select @ResponseText As Reponse;

End
