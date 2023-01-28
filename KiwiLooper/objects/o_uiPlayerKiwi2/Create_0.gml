/// @description Set up rendering

// Set up main rendering
BuildUi = function(build_mode)
{
	var pl = instance_find(o_playerKiwi, 0);
	var screen_z = Vector3FromArray(o_Camera3D.m_viewForward);
	var screen_x = screen_z.cross(Vector3FromArray(o_Camera3D.m_viewUp));
	var screen_y = screen_z.cross(screen_x);
	
	var ctx, tex;
	ctx = Ui3Begin(build_mode);
	{
		var scale = Ui3PosScale(pl.x, pl.y, pl.z);
		
		static kHudColor = c_electricity;
		
		draw_set_color(kHudColor);
		
		// Start with debug hello world
		draw_set_font(f_Oxygen10);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		tex = Ui3Tex_Text(ctx, "hello");
		Ui3Shape_Billboard(ctx, tex, pl.x, pl.y, pl.z, 0.5 * scale, 0.5 * scale);
		tex = Ui3Tex_Text(ctx, "world");
		Ui3Shape_Billboard(ctx, tex, pl.x, pl.y, pl.z - 40.0, 0.5 * scale, 0.5 * scale);
		// TODO: Other stuff
		
		// TODO: Split some of these things into different objects or calls
		
		// rectangles for
		// LOCK for lockin
		// ALERT for enemies
		// HLTH for health
		// HELD for holding items
		// AOD for nearby hazards
		draw_set_font(f_Oxygen7);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		
		var notice_rect_height = string_height("M") + 3;
		var rectangle_text = ["LOCK", "ALERT", "HLTH", "HELD", "AOD"];
		
		var rectangle_draw = array_create(5, true);
		var rectangle_positions = array_create(5);
		for (var i = 0; i < 5; ++i)
		{
			if (rectangle_draw[i])
			{
				rectangle_positions[i] = Vector3FromTranslation(pl)
					.addSelf(screen_z.multiply(-32.0 * scale))
					.addSelf(screen_y.multiply(-16.0 * scale))
					.addSelf(screen_x.multiply((i - 2) * 18.0 * scale))
					;
					
				tex = Ui3Tex_Rect(ctx, notice_rect_height * 3, notice_rect_height, true);
				Ui3Tex_TextRect(ctx, tex, 2, 2, rectangle_text[i]);
				Ui3Shape_Billboard(ctx, tex,
					rectangle_positions[i].x, rectangle_positions[i].y, rectangle_positions[i].z,
					0.2, 0.2, true);
			}
		}
	
		// Draw the object info stuff
		var usable = o_playerKiwi.interactionTarget;
		if (iexists(usable))
		{
			// Small use
			if (!usable.m_bigUseInfo)
			{
				draw_set_halign(fa_center);
				draw_set_valign(fa_bottom);
				draw_set_font(f_Oxygen7);
				tex = Ui3Tex_Text(ctx, "[_]" + usable.m_useText);
				Ui3Shape_Billboard(ctx, tex, usable.x, usable.y, usable.z, 0.2, 0.2, true);
			}
			// Big USE panel!
			else
			{
				draw_set_halign(fa_center);
				draw_set_valign(fa_bottom);
				draw_set_font(f_Oxygen10);
				tex = Ui3Tex_Text(ctx, usable.m_useText);
				Ui3Shape_Billboard(ctx, tex, usable.x, usable.y, usable.z, 0.2, 0.2, true);
			}
		}
	}
	Ui3End(ctx);
}

// Create renderer
m_renderer = new Ui3Renderer(BuildUi);

// Set up final draw
m_renderEvent = function()
{
	gpu_push_state();
	gpu_set_ztestenable(false);
	gpu_set_zwriteenable(false); // TODO???
	m_renderer.Draw();
	gpu_pop_state();
}