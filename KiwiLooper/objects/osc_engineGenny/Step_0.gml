/// @description Check number of gennys

var gennyCountPrev = m_gennyCount;
m_gennyCount = instance_number(o_charaPowercell);

if (m_gennyCount <= 0 && gennyCountPrev > 0)
{
	Gameplay.m_tallyCount = 1; // Reset the tally count for the restart
	
	// go to the final room
	room_goto_next();
}