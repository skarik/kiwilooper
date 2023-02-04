// shows various text rectangles
function AKUi_StatusRectangles() : AKiwiUiComponent() constructor
{
	static Build = function(params, ctx)
	{
		var scale = params.scale;
		var tex;
		
		draw_set_color(params.color);
	
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
				rectangle_positions[i] = Vector3FromTranslation(params.player)
					.addSelf(params.screen_z.multiply(-32.0 * scale))
					.addSelf(params.screen_y.multiply(-16.0 * scale))
					.addSelf(params.screen_x.multiply((i - 2) * 18.0 * scale))
					;
					
				tex = Ui3Tex_Rect(ctx, notice_rect_height * 3, notice_rect_height, true);
				Ui3Tex_TextRect(ctx, tex, 2, 2, rectangle_text[i]);
				Ui3Shape_Billboard(ctx, tex,
					rectangle_positions[i].x, rectangle_positions[i].y, rectangle_positions[i].z,
					0.2, 0.2, true);
			}
		}
	}
}

//=============================================================================

// show object interaction popup
function AKUi_ObjectInteraction() : AKiwiUiComponent() constructor
{
	static Build = function(params, ctx)
	{
		var tex;
		
		// Draw the object info stuff
		var usable = o_playerKiwi.interactionTarget;
		if (iexists(usable))
		{
			// Small use
			//if (!usable.m_bigUseInfo)
			{
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				draw_set_font(f_Oxygen7);
				
				var no_info_text	= string_upper("no_info_found");
				var dbg_info_text	= string_upper("royale_dbg_fallback");
				var use_text = "[_] " + loc_text("ui usable", usable.m_useText);
				
				draw_set_font(f_04b03);
				var dbg_info_text_width = string_width(dbg_info_text);
				draw_set_font(f_Oxygen10);
				var use_text_width = string_width(use_text);
				
				tex = Ui3Tex_Space(ctx, max(use_text_width, dbg_info_text_width), 50);
				{
					// Draw the USE rectangle
					draw_set_color(params.color);
					static kMargin = 3;
					Ui3Tex_RectRect(ctx, tex, 0, 17, use_text_width + kMargin * 2, 20, true);
					Ui3Tex_RectRect(ctx, tex, 0 + 1, 17 + 1, use_text_width + kMargin * 2 - 2, 20 - 2, true);
					Ui3Tex_TextRect(ctx, tex, 0 + kMargin, 17 + kMargin, use_text);
				
					// Draw the debug flashy text
					draw_set_color(merge_color(params.color, c_black, 0.5));
					draw_set_font(f_04b03);
					Ui3Tex_TextRect(ctx, tex, 0, 0, no_info_text);
					Ui3Tex_TextRect(ctx, tex, 0, 8, dbg_info_text);
				}
				var display_position = Vector3FromTranslation(usable).addSelf(params.screen_x.multiply(-10.0 * params.scale));
				Ui3Shape_Billboard(ctx, tex,
					display_position.x, display_position.y, display_position.z,
					0.15, 0.15, true);
					
				// Add the diamond icon
				draw_set_color(params.color);
				tex = Ui3Tex_Rect(ctx, 16, 16, true);
				Ui3Tex_RectRect(ctx, tex, 1, 1, 14, 14, true);
				Ui3Shape_Billboard(ctx, tex,
					usable.x, usable.y, usable.z,
					0.15, 0.15, true,
					45);
				draw_set_color(params.color);
				
				// TODO: Draw the line from the item to the box??? Maybe not, maybe too dirty.
			}
			// Big USE panel!
			/*else
			{
				draw_set_halign(fa_center);
				draw_set_valign(fa_bottom);
				draw_set_font(f_Oxygen10);
				tex = Ui3Tex_Text(ctx, usable.m_useText);
				Ui3Shape_Billboard(ctx, tex, usable.x, usable.y, usable.z, 0.2, 0.2, true);
			}*/
		}
	}
}