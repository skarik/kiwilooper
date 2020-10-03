/// @description Draw UI in worldspace

draw_set_alpha(alpha);

draw_set_color(c_electricity);
draw_set_font(f_04b03);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
with (ob_livelyPowered)
{
	draw_text(x, y, "in:   " + string(m_powerInput));
	draw_text(x, y + 8, "out: " + string(m_powerOutput));
	if (iexists(m_powerSource))
	{
		draw_line(x, y, m_powerSource.x, m_powerSource.y);
	}
}

draw_set_alpha(1.0);