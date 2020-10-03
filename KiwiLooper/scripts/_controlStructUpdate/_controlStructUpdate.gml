/// @func _controlStructUpdate(DO NOT CALL)
/// @desc This function should not be called directly.
/// @param control {object}
/// @param newValue {real}
function _controlStructUpdate(argument0, argument1) {
	var control = argument0;
	var newValue = argument1;

	control.previous = control.value;
	control.value = newValue;

	var wasDown = control.down;
	control.down = abs(control.value) > 0.707;

	control.released = wasDown && !control.down;
	control.pressed = !wasDown && control.down;



}
