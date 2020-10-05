/// @description Update intensity based on the power

if (iexists(o_livelyRoomState))
{
	intensity = sin(Time.time * 2.0 - y / 32.0) * 6.0 - 5.0;
	intensity = min(intensity * 1.4, 1.0);
}