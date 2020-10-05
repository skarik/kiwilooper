/// @description Draw tally marks

for (var i = 0; i < Gameplay.m_tallyCount; i += 5)
{
	var tally_value = min(5, Gameplay.m_tallyCount - i) - 1;
	draw_sprite(sui_tallyMarks, tally_value, 32 + 42 * (i/5), 32);
}