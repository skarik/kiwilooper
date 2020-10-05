/// @description Check for player to arrive

if (place_meeting(x, y, o_playerKiwi))
{
	if (!m_fadeOut)
	{
		inew(o_screenAbberationIn);
		effectAbberate(-0.1, 0.05, false);
		effectAbberate(0.15, 0.10, false);
		m_fadeOut = true;
	}
}

if (m_fadeOut)
{
	m_fadeTime += Time.deltaTime;
	if (m_fadeTime > 0.5)
	{
		room_goto_next();
	}
}