/// @description Update step


m_displayLength += Time.deltaTime * 40.0;
m_displayString = string_copy(m_messageString, 1, min(string_length(m_messageString), m_displayLength));

if (!m_wantsFade)
{
	m_displayFade += Time.deltaTime * 3.0;
	
	// Update inputs
	controlUpdate(m_displayFade < 1.0);
	
	// Update next display
	m_displayNext = m_displayLength >= string_length(m_messageString);
	
	// Check if input pressed
	if (m_displayNext
		&& (atkButton.pressed || useButton.pressed))
	{
		// Another string queued? Shunt it up
		if (string_length(m_messageStringQueued) > 1)
		{
			m_messageString = m_messageStringQueued;
			m_displayLength = 0;
			m_messageStringQueued = "";
		}
		// Otherwise we want to fade this thing out.
		else
		{
			m_wantsFade = true;
		}
	}
}
else
{
	if (m_displayFade > 1)
		m_displayFade = 1.0;
	m_displayFade -= Time.deltaTime * 3.0;
	if (m_displayFade <= 0.0)
	{
		instance_destroy();
	}
}