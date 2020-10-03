/// @func _controlStructUpdate(DO NOT CALL)
/// @desc This function should not be called directly.
function _controlStructCreate() {
	var control = inew(_dummy);
	control.value = 0.0;
	control.previous = 0.0;

	control.down = false;
	control.pressed = false;
	control.released = false;

	control.persistent = true;

	return control;


}
