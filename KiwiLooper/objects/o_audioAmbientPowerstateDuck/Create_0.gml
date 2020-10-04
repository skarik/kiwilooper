/// @description Loop ambient & fully duck

// Inherit the parent event
event_inherited();

// Force zero volume
if (iexists(m_audioSound))
{
	m_audioSound.gain = 0.0;
}