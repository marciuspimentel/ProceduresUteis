Create Function dbo.RemoveInvalidChars (@CharData VARCHAR(50)) 
RETURNS VARCHAR(256) 
AS BEGIN

DECLARE  @ASCIIChar	INT

	select @ASCIIChar = patindex('%[^a-zA-Z0-9 ]%', @CharData)
	while @ASCIIChar > 0
	begin
		select @CharData = replace(@CharData, substring(@CharData, @ASCIIChar, 1), '')
		select @ASCIIChar = patindex('%[^a-zA-Z0-9 ]%', @CharData)
	end

RETURN @CharData

End