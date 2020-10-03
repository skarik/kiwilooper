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
