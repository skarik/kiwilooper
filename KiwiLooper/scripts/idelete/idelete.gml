/// @function idelete(object_to_delete)
function idelete(argument0) {
	if (argument0 == noone)
		return 0;
	with (argument0)
	{
	    instance_destroy();
	}  
	return 0;


}
