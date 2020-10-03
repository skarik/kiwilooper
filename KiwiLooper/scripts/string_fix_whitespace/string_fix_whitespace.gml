/// @description string_fix_whitespace(string)
/// @param string
function string_fix_whitespace(argument0) {
	{
	    var str,result,l,r,o;
	    str = argument0;
	    result = "";
	    l = 1;
	    r = string_length(str);
	    repeat (r)
	    {
	        o = string_char_at(str,l);
	        if (is_space(o)) {
	            result += " ";
	        }
	        else {
	            result += o;
	        }
	        l++;
	    }
	    return result;
	}



}
