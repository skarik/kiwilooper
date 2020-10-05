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
	instance_create_depth(390, 215, 0, o_charaRobot);
}

if (m_gennyCount <= 2 && gennyCountPrev > 2)
{
	with (ot_3DSpinnaz)
	{
		image_blend = make_color_rgb(222, 41, 218);
		m_updateMesh();
	}
	instance_create_depth(240, 206, 0, o_charaRobot);
}

if (m_gennyCount <= 1 && gennyCountPrev > 1)
{
	instance_create_depth(240, 360, 0, o_charaRobot);
	instance_create_depth(400, 366, 0, o_charaRobot);
	instance_create_depth(320, 220, 0, o_charaRobot);
}

if (m_gennyCount <= 0 && gennyCountPrev > 0)
{
	Gameplay.m_tallyCount = 1; // Reset the tally count for the restart
	
	// Kill all robots
	with (o_charaRobot)
	{
		hp -= 1; 
	}
	
	// go to the final room
	room_goto_next();
}