function debugOut(str)
{
	var source = id;
	with (Debug)
	{
	    if (debug_line_count > 60)
	    {
	        debug_line_count = 0;
			//debug_line = array_remove_index(debug_line, 0);
	    }
		
		// todo, use debug_get_callstack(2)[1]
    
	    debug_line[debug_line_count] = "[" + object_get_name(source.object_index) + "] " + str;
	    debug_line_count++
	}
}

#macro kLogOutput 0
#macro kLogWarning 1
#macro kLogError 2

/// @function debugLog(type, str)
function debugLog(type, str)
{
	debugOut(str); // todo: unify everything for easier debugging later
}
