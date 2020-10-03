/// @function debugPoint(x, y, color)
/// @param {Real} x
/// @param {Real} y
/// @param {RGBA32} color
function debugPoint(argument0, argument1, argument2) {

	debugLine(argument0 - 3, argument1, argument0 + 2, argument1, argument2);
	debugLine(argument0, argument1 - 3, argument0, argument1 + 2, argument2);


}
