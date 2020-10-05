/// @description Check number of gennys

var gennyCountPrev = m_gennyCount;
m_gennyCount = instance_number(o_charaPowercell);

if (m_gennyCount <= 3 && gennyCountPrev > 3)
{
	with (ot_3DSpinnaz)
	{
		image_blend = make_color_rgb(31, 192, 192);
		m_updateMesh();
	}
}

if (m_gennyCount <= 2 && gennyCountPrev > 2)
{
	with (ot_3DSpinnaz)
	{
		image_blend = make_color_rgb(222, 41, 218);
		m_updateMesh();
	}
}

if (m_gennyCount <= 0 && gennyCountPrev > 0)
{
	Gameplay.m_tallyCount = 1; // Reset the tally count for the restart
	
	// go to the final room
	room_goto_next();
}