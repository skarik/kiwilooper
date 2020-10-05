/// @description Draw credits

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_ltgray);

if (m_drawmode == 0)
{
	draw_sprite_ext(
		sui_logo_small_white, 0,
		0, 0,
		0.49, 0.49,
		0.0,
		c_ltgray, 1.0);
	draw_set_font(f_DeValencia20);
	draw_text( 0, 90, "PRESENTS");
}
else if (m_drawmode == 1)
{
	draw_set_font(f_DeValencia20);
	draw_text(0, -100, "A LD47 GAME BY");

	draw_set_font(f_DeValencia40);
	draw_text(-130, 0, "NOHUA");
	draw_text( 130, 0, "SKARIK");
	draw_set_font(f_04b03);
	draw_text(-130, 31, "@NOHUMANZA");
	draw_text( 130, 31, "@SKARIK_EHS")

	draw_set_font(f_Oxygen10);
	if (m_drawmodeCreditCount >= 1)
	{
		draw_text(-130, 60, "PLANNING");
		draw_text( 130, 60, "PROGRAMMING");
	}
	if (m_drawmodeCreditCount >= 2)
	{
		draw_text(-130, 80, "ART");
		draw_text( 130, 80, "DESIGN");
	}
	if (m_drawmodeCreditCount >= 3)
	{
		draw_text(-130, 100, "CONCEPT");
		draw_text( 130, 100, "SOUND & MUSIC");
	}
}