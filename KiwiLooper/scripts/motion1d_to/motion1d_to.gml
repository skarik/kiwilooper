/// @function motion1d_to(start, end, speed)
/// @param start
/// @param end
/// @param speed
function motion1d_to(argument0, argument1, argument2) {

	var start = argument0;
	var target = argument1;
	var tspeed = argument2;

	if (start < target)
		start = min(target, start + tspeed);
	else
		start = max(target, start - tspeed);
	
	return start;


}
