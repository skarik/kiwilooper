/// @function _controlParseCheckType(DO NOT USE)
/// @desc Polls the given input array and returns input from -1.0 to 1.0.
/// @param input {real} Input value
/// @param type {enum} Type of input given
function _controlParseCheckType(argument0, argument1) {
	var input_in = argument0;
	var control_type = argument1;

	if (abs(input_in) > 0.1)
		lastControlType = control_type;
	
	return input_in;


}
