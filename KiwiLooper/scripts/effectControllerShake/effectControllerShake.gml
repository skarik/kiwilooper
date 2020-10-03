/// @description Effect_ControllerShake(magnitude,length,fade)
/// @param magnitude
/// @param length
/// @param fade
function effectControllerShake(argument0, argument1, argument2) {

	var screenshake = inew(o_fxControllershake);
	screenshake.magnitude   = argument0;
	screenshake.life    = argument1;
	screenshake.maxlife = argument1;
	screenshake.fade    = argument2;
	return screenshake;



}
