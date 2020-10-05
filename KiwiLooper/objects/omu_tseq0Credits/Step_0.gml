/// @description Do effect timer

// Apply the game camera position
with (GameCamera)
{
	x = round(sin(Time.time * 11.2 * 0.25) * 2.0 + sin(Time.time * 7.4 * 0.25) * 2.0) * 0.25;
	y = round(cos(Time.time * 15.7 * 0.25) * 2.0 + sin(Time.time * 5.4 * 0.25) * 2.0) * 0.25;
	event_user(1);
}

// Do drawmode timer for initial logo
if (m_drawmode == 0)
{
	m_drawmodeTimer += Time.deltaTime;
	if (m_drawmodeTimer > 1.7
		|| (m_drawmodeTimer > 0.5 && controlAnyKey()))
	{
		m_drawmode = 1;
		// Reset timer 
		m_drawmodeTimer = 0.0;
		// Abberate on scene change
		effectAbberate(0.01, 0.05, false);
		effectScreenShake(3, 0.40, true);
	}
}
// Do step-by-step fade in
if (m_drawmode == 1)
{
	var drawmodeTimerPrevious = m_drawmodeTimer;
	m_drawmodeTimer += Time.deltaTime;
	if ((m_drawmodeTimer > 0.5 && drawmodeTimerPrevious <= 0.5)
		|| (m_drawmodeTimer > 0.9 && drawmodeTimerPrevious <= 0.9)
		|| (m_drawmodeTimer > 1.3 && drawmodeTimerPrevious <= 1.3))
	{
		effectAbberate(choose(0.01, -0.01), 0.05, true);
		effectScreenShake(2, 0.10, true);
		m_drawmodeCreditCount++;
	}
	
	// And end it
	if (controlAnyKey() || m_drawmodeTimer > 4.0)
	{
		room_goto_next();
	}
}