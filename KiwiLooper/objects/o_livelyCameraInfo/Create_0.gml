/// @description Inherit & setup

event_inherited();

visible = false; // Not a visible object, so don't define a render.

m_wasToggled = false;
m_camInfo = undefined;

// Set up persistent state
PersistentState("enabled", kValueTypeBoolean);
PersistentState("m_wasToggled", kValueTypeBoolean);

m_onActivation = function(activatedBy)
{
	if (toggleOnActivation)
	{
		if (!toggleOnce
			|| (toggleOnce && !m_wasToggled))
		{
			m_wasToggled = true;
			enabled = !enabled;
		}
	}
	else
	{
		// Let's force it on
	}
}

// Cache the camerainfo struct on level load
onPostLevelLoad = function()
{
	m_camInfo = {
		angle:		cameraAngle.copy(),
		distance:	cameraDistance,
		fov:		cameraFieldOfView,
		position:	undefined,
		blendTime:	(timeToBlendTo > 0.0) ? timeToBlendTo : -1.0,
	};
}