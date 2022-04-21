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

onPostLevelLoad = function() 
{
	// Reselect the light state when we finish loading up
	SelectLightMode();
}
onEditorStep = function()
{
	// Reselect light state every step in the editor to preview the settings
	SelectLightMode();
};
