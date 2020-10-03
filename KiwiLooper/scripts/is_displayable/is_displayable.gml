/// @description  is_displayable(char)
/// @param char
function is_displayable(argument0) {
	var ch = ord(argument0);
	if (ch >= 32 && ch <= 126)
	{
		return true;
	}
	return false;


}
