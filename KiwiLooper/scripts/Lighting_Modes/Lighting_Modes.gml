function Lighting_GetModeList()
{
	static possibleLightModes =
	[
		{
			index:	kLightModeNone,
			name:	"None",
			step:	function(){ intensity = 1.0; },
		},
	
		{
			index:	kLightModePowerstate,
			name:	"Powerstate",
			step:	function()
			{
				if (iexists(o_livelyRoomState))
				{
					intensity = motion1d_to(
						intensity,
						o_livelyRoomState.powered ? 1.0 : 0.0,
						Time.deltaTime * 2.0
						);
				}
				else
				{
					intensity = 1.0;
				}
			},
		},
	
		{
			index:	kLightModeYOscillate,
			name:	"Y Oscillate",
			step:	function()
			{
				intensity = sin(Time.time * 2.0 - y / 32.0) * 6.0 - 5.0;
				intensity = min(intensity * 1.4, 1.0);
			},
		},
	];
	
	return possibleLightModes;
}