/// @description Effect_ScreenShake(magnitude,length,fade)
/// @param magnitude
/// @param length
/// @param fade
function effectScreenShake(argument0, argument1, argument2) {

	var screenshake = inew(o_fxScreenshake);
	screenshake.magnitude	= argument0;
	screenshake.life		= argument1;
	screenshake.maxlife		= argument1;
	screenshake.fade		= argument2;
	return screenshake;




}
