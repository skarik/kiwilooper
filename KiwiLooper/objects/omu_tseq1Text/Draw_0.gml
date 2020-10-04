/// @description Draw text

if (m_drawmode == 0)
{
	draw_set_font(f_DeValencia40);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_text(0, 0, "TALLY MARKS");
}
else if (m_drawmode == 1)
{
	draw_set_font(f_Oxygen12);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_text(0, 0, "[TALLY MARKS]");
}