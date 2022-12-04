/// @func _controlStructUpdate(DO NOT CALL)
/// @desc This function should not be called directly.
function _controlStructCreate()
{
	var control = {
		value: 0.0,	
		previous: 0.0,
		
		down: false,
		pressed: false,
		released: false,
	};
	
	return control;
}

/// @func _controlStructUpdate(DO NOT CALL)
/// @desc This function should not be called directly.
/// @param control {object}
/// @param newValue {real}
function _controlStructUpdate(control, newValue)
{
	control.previous = control.value;
	control.value = newValue;

	var wasDown = control.down;
	control.down = abs(control.value) > 0.707;

	control.released = wasDown && !control.down;
	control.pressed = !wasDown && control.down;
}

/// @function _controlStructFree(DO NOT CALL)
/// @desc This function should not be called directly.
/// @param {Struct} control
function _controlStructFree(control)
{
	delete control;
}

/// @function controlForward(targetControl, sourceControl)
/// @desc Copies the relevant state of the control to the given control.
function controlForward(targetControl, sourceControl)
{
	targetControl.value = sourceControl.value;
	targetControl.previous = sourceControl.previous;
	
	targetControl.down = sourceControl.down;
	targetControl.released = sourceControl.released;
	targetControl.pressed = sourceControl.pressed;
}