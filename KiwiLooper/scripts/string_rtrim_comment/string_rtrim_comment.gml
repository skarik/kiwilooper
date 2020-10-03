/// @description  string_rtrim_comment(str)
/// @param str
function string_rtrim_comment(argument0) {
	//
	//  Returns the given string with whitespace stripped from its end.
	//  Whitespace is defined as SPACE, TAB, NL, VT, FF, CR.
	//
	//      str         string of text, string
	//
	/// GMLscripts.com/license
	{
	    var str,l,r,o0,o1;
	    str = argument0;
	    //r = string_length(str);
	    /*repeat (r - 1)
	    {
	        o0 = ord(string_char_at(str,r));
	        o1 = ord(string_char_at(str,r));
	        if (o0 == ord('/') && o0 == o1) 
	        else r -= 1;
	    }
	    return string_copy(str,1,r);*/
	    r = string_length(str);
	    l = 0;
	    repeat (r)
	    {
	        o0 = ord(string_char_at(str,l));
	        o1 = ord(string_char_at(str,l+1));
	        if (o0 == ord("/") && o0 == o1) break;
	        l += 1;
	    }
	    return string_copy(str,1,l);
	}




}
