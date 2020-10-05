/// @description Draw over usable

if (iexists(o_playerKiwi))
{
	var draw_position = o_Camera3D.positionToView(
		o_playerKiwi.x,
		o_playerKiwi.y,
		o_playerKiwi.z + 16);
			
	draw_set_font(f_Oxygen10);
	draw_set_color(c_white);
	draw_set_alpha(m_alpha);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_text(draw_position[0], draw_position[1] - 100, text);
	
	draw_set_alpha(1.0);
}