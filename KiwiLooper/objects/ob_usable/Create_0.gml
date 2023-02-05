/// @description Inherit & setup

event_inherited();

#macro kUseInfoTypeDefault	0
#macro kUseInfoTypeBig		1
#macro kUseInfoTypeItem		2

m_priority = 1;
m_infoIcon = spr_metalPC;
m_onActivation = function(activatedBy)
{
	; // Nothing yet
}
m_onCheckEnabled = function()
{
	return true; // Default always enabled
}