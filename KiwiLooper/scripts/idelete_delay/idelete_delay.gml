/// @function idelete_delay(object, delay)
/// @param object
/// @param delay {Real, seconds}
function idelete_delay(argument0, argument1) {
	var to_delete = argument0;
	var delay = argument1;

	var deleter = inew(_delete_delay);
		deleter.delay = delay;
		deleter.target = to_delete;
	
	return deleter;


}
