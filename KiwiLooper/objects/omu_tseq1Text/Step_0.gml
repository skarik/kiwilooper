/// @description Do effect timer

// Apply the game camera position
with (GameCamera)
{
	x = round(sin(Time.time * 11.2) * 2.0 + sin(Time.time * 7.4) * 2.0) * 0.5;
	y = round(cos(Time.time * 15.7) * 2.0 + sin(Time.time * 5.4) * 2.0) * 0.5;
	event_user(1);
}

var effectTimerPrevious = m_effectTimer;
m_effectTimer += Time.deltaTime;

// Swap between text every so often
if ((m_effectTimer > 0.83 && effectTimerPrevious <= 0.83)
	|| (m_effectTimer > 0.99 && effectTimerPrevious <= 0.99)
	|| (m_effectTimer > 1.33 && effectTimerPrevious <= 1.33)
	)
{
	m_drawmode = 0;
	effectAbberate(0.02, 0.05, false);
}
if ((m_effectTimer > 0.8 && effectTimerPrevious <= 0.8)
	|| (m_effectTimer > 0.9 && effectTimerPrevious <= 0.9)
	|| (m_effectTimer > 1.3 && effectTimerPrevious <= 1.3)
	|| (m_effectTimer > 1.7 && effectTimerPrevious <= 1.7)
	)
{
	m_drawmode = 1;
	effectAbberate(0.01, 0.05, true);
}

// Go to next state
if ((m_effectTimer > 0.7 && controlAnyKey()) || (m_effectTimer > 2.0 && effectTimerPrevious <= 2.0))
{
	m_effectTimer = max(2.0, m_effectTimer);
}
// End this stage of the UI
if (m_effectTimer > 2.1)
{
	idelete(this);
	inew(omu_tseq2Graphics);
}