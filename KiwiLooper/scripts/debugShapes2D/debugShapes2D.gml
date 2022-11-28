/// @function debugLine(x1, y1, x2, y2, color)
/// @param {Real} x1
/// @param {Real} y1
/// @param {Real} x2
/// @param {Real} y2
/// @param {RGBA32} color
function debugLine(argument0, argument1, argument2, argument3, argument4) {
	var dbb = inew(o_debugDLine);
	    dbb.x1 = argument0; dbb.y1 = argument1;
	    dbb.x2 = argument2; dbb.y2 = argument3;
	    dbb.image_blend = argument4;


}

/// @function debugBox(x1, y1, x2, y2, color)
/// @param {Real} x1
/// @param {Real} y1
/// @param {Real} x2
/// @param {Real} y2
/// @param {RGBA32} color
function debugBox(argument0, argument1, argument2, argument3, argument4) {
	var dbb = inew(o_debugDBox);
	    dbb.x1 = argument0; dbb.y1 = argument1;
	    dbb.x2 = argument2; dbb.y2 = argument3;
	    dbb.image_blend = argument4;


}

/// @function debugPoint(x, y, color)
/// @param {Real} x
/// @param {Real} y
/// @param {RGBA32} color
function debugPoint(argument0, argument1, argument2) {

	debugLine(argument0 - 3, argument1, argument0 + 2, argument1, argument2);
	debugLine(argument0, argument1 - 3, argument0, argument1 + 2, argument2);


}
