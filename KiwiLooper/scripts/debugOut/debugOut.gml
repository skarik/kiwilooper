function debugOut(argument0) {
	var str = argument0;
	var source = id;
	with (Debug)
	{
	    if (debug_line_count > 60)
	    {
	        debug_line_count = 0;
			//debug_line = array_remove_index(debug_line, 0);
	    }
    
	    debug_line[debug_line_count] = "[" + object_get_name(source.object_index) + "] " + str;
	    debug_line_count++   
	}



}
