/// @function motion2d_to(start, end, speed)
/// @param start
/// @param end
/// @param speed
function motion2d_to(argument0, argument1, argument2) {

	var start = argument0;
	var target = argument1;
	var tspeed = argument2;

	var dir = point_direction(start[0], start[1], target[0], target[1]);
	var dist = point_distance(start[0], start[1], target[0], target[1]);
	if (dist <= tspeed)
	{
		start = target;
	}
	else
	{	// todo: optimize
		start[0] += lengthdir_x(tspeed, dir);
		start[1] += lengthdir_y(tspeed, dir);
	}
	
	return start;


}
