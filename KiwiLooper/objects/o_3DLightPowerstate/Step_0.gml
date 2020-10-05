/// @description Update intensity based on the power

if (iexists(o_livelyRoomState))
{
	intensity = motion1d_to(intensity, o_livelyRoomState.powered ? 1.0 : 0.0, Time.deltaTime * 2.0);
}