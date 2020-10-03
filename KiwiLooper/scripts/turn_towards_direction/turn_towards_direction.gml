/// @function turn_towards_direction(dir,target,rate)
/// @description Rotates the calling instance towards the target direction, at a given rate. 
/// @param dir {Real} direction we start at
/// @param target {Real} angle to turn towards (degrees)
/// @param rate {Real} maximum turning rate (degrees)
///
/// GMLscripts.com/license
function turn_towards_direction(argument0, argument1, argument2) {
	{
		var dir = argument0;
	    dir += median(-argument2, argument2, angle_difference(argument1, dir));
	    return dir;
	}


}
