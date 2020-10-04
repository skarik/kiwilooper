/// @description Fade in

if (m_fadeIn)
{
	image_alpha += Time.deltaTime * 2.0;
}

if (image_alpha > 1.0)
{
	controlUpdate(false);
	
	if (abs(yAxis.value) > 0.5 && sign(yAxis.value) * sign(yAxis.previous) < 0.5)
	{
		m_menuSelection += sign(yAxis.value);
		m_menuSelection = clamp(m_menuSelection, 1, 2); // clamp to selection count
	}
	
	// Check mouse as well
	if (uPosition != uPositionPrevious || vPosition != vPositionPrevious)
	{
		m_menuSelection = -1;
		
		// Do actual option selection
		m_menuSelection = floor(vPosition / 40) + 1;
		if (m_menuSelection <= 0 || m_menuSelection > 2)
			m_menuSelection = -1;
	}
	
	// Check for press
	if (m_menuSelection != -1)
	{
		if (useButton.pressed || atkButton.pressed)
		{
			var selection = m_menuOptions[m_menuSelection];
			m_menuCallbacks[selection]();
		}
	}
}