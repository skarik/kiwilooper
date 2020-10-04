/// @description Setup

event_inherited();

m_onActivation = function(activatedBy)
{
	if (iexists(m_door0))
		m_door0.m_onActivation(activatedBy);
	if (iexists(m_door1))
		m_door1.m_onActivation(activatedBy);
	if (iexists(m_door2))
		m_door2.m_onActivation(activatedBy);
}