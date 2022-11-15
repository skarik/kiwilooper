#macro kLogVerbose 3
#macro kLogOutput 0
#macro kLogWarning 1
#macro kLogError 2

/// @function debugLog(type, str)
function debugLog(type, str)
{
	var sourceName = "";
	// Find the caller
	if (is_struct(self))
	{
		var stackIdentifier = debug_get_callstack(2)[1];
		stackIdentifier = string_replace(stackIdentifier, "gml_Script_", "");
		
		// now find the anon_ and grab that to the first _gml_GlobalScript
		// the file context would be the last _gml_GlobalScript_ to the last :
		var structNameStart = string_pos("anon_", stackIdentifier) + 5;
		var structNameEnd = string_pos("_gml_GlobalScript", stackIdentifier);
		var structName = string_copy(stackIdentifier, structNameStart, structNameEnd - structNameStart);
		
		var structContextStart = string_last_pos("_gml_GlobalScript", stackIdentifier) + 18;
		var structContextEnd = string_last_pos(":", stackIdentifier);
		var structContext = string_copy(stackIdentifier, structContextStart, structContextEnd - structContextStart);
		
		var structLine = string_copy(stackIdentifier, structContextEnd, string_length(stackIdentifier) - structContextEnd);
		
		sourceName = structContext + ":" + structName + structLine; // TODO: Clean the fuck up proper-like
	}
	else
	{
		var objectName = object_get_name(id.object_index);
		var stackIdentifier = debug_get_callstack(2)[1];
		stackIdentifier = string_replace(stackIdentifier, "gml_Object_" + objectName, "");
		stackIdentifier = string_replace(stackIdentifier, "gml_Script_", "");
		sourceName = objectName + ":" + stackIdentifier;
	}
	
	// Set up the output
	var outputString = "[" + sourceName + "] \t " + str;
	
	show_debug_message(outputString);
	
	with (Debug)
	{
		// TODO: Improve this lol
		if (debug_line_count > 60)
		{
			debug_line_count = 0;
			//debug_line = array_remove_index(debug_line, 0);
		}
		debug_line[debug_line_count++] = [outputString, type];
	}
}
