/// @description Draw over usable

if (iexists(o_Camera3D) && iexists(o_playerKiwi))
{
	if (iexists(o_playerKiwi.interactionTarget))
	{
		var draw_position = o_Camera3D.positionToView(
			o_playerKiwi.interactionTarget.x,
			o_playerKiwi.interactionTarget.y,
			o_playerKiwi.interactionTarget.z);
			
		draw_set_font(f_Oxygen10);
		draw_set_color(c_white);
		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		draw_text(draw_position[0], draw_position[1] - 24, "[_]" + o_playerKiwi.interactionTarget.m_useText);
	}
}