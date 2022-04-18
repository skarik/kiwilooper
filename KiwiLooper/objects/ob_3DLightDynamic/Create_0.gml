/// @description Define the types of behaviors

#macro kLightModeNone			0
#macro kLightModePowerstate		1
#macro kLightModeYOscillate		2

m_lightStepper = method(id, Lighting_GetModeList()[0].step);
SelectLightMode = function()
{
	m_lightStepper = method(id, Lighting_GetModeList()[mode].step);
};

SelectLightMode();

alarm[1] = 1;
