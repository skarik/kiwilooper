/// @description Update volumes

if (m_state == 0)
{
	m_player.m_trackVolume[0] = 0.0;
	m_player.m_trackVolume[1] = 0.0;
	m_player.m_trackVolume[2] = 0.0;
	
	if (iexists(o_playerKiwi) && iexists(osc_engineGenny))
	{
		if (point_distance(o_playerKiwi.x, o_playerKiwi.y, osc_engineGenny.x, osc_engineGenny.y) < 16 * 14)
		{
			m_state = 1;
		}
	}
}
else if (m_state == 1)
{
	m_player.m_trackVolume[0] = 1.0;
	m_player.m_trackVolume[1] = 0.0;
	m_player.m_trackVolume[2] = 0.0;
	
	if (instance_number(o_charaPowercell) < 4)
	{
		m_state = 2;
	}
}
else if (m_state == 2)
{
	m_player.m_trackVolume[0] = 0.0;
	m_player.m_trackVolume[1] = 1.0;
	m_player.m_trackVolume[2] = 0.0;
	
	if (instance_number(o_charaPowercell) < 2)
	{
		m_state = 3;
	}
}
else if (m_state == 3)
{
	m_player.m_trackVolume[0] = 0.0;
	m_player.m_trackVolume[1] = 0.0;
	m_player.m_trackVolume[2] = 1.0;
	
	if (instance_number(o_charaPowercell) < 1)
	{
		m_state = 4;
	}
}
else if (m_state == 4)
{
	m_player.m_trackVolume[0] = 0.0;
	m_player.m_trackVolume[1] = 0.0;
	m_player.m_trackVolume[2] = 0.0;
}