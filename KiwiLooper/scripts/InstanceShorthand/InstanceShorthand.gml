/// @function idelete(object_to_delete)
function idelete(argument0)
{
	gml_pragma("forceinline");
	if (argument0 == noone)
		return 0;
	with (argument0)
	{
	    instance_destroy();
	}  
	return 0;
}

/// @function idelete_delay(object, delay=0)
/// @param object
/// @param delay {Real, seconds}
function idelete_delay(object, delay=0)
{
	var deleter = inew(_delete_delay);
		deleter.delay = delay;
		deleter.target = object;
	
	return deleter;
}

/// iexists(object_to_check)
function iexists(argument0)
{
	gml_pragma("forceinline");
	return instance_exists(argument0);
}

/// @function inew(object_index)
function inew(argument0)
{
	gml_pragma("forceinline");
	return instance_create_depth(0, 0, 0, argument0);
}

/// @function inew(object_index)
function inew_unique(argument0)
{
	gml_pragma("forceinline");
	if (!iexists(argument0))
	{
		return instance_create_depth(0, 0, 0, argument0);
	}
	return null;
}

/// @function place_unique(object_index, x, y)
function place_unique(argument0, argument1, argument2)
{
	gml_pragma("forceinline");
	if ( !position_meeting(argument0,argument1,argument2) )
	{
		return instance_create_layer(argument0,argument1,layer,argument2);
	}
	return null;
}
