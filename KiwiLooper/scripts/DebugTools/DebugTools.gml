///@function Debug_CreateWorldRenderText(x, y, z, text, color=c_white, align=fa_left)
function Debug_CreateWorldRenderText(x, y, z, text, color=c_white, align=fa_left)
{
	var uis_info = inew(o_uisScriptable);
	uis_info.x = x;
	uis_info.y = y;
	uis_info.z = z;
	uis_info.text = text;
	uis_info.color = color;
	uis_info.align = align;
	
	uis_info.m_renderEvent = method(uis_info, function()
	{
		var position = o_Camera3D.positionToView(x, y, z);
		if (position[2] > 0)
		{
			draw_set_alpha(1.0);
			draw_set_color(color);
			draw_set_halign(align);
			draw_set_valign(fa_middle);
			draw_set_font(f_04b03);
			draw_text(position[0], position[1], text);
		}
	});
	
	return uis_info;
}
