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
			var is_enabled	= usable.m_onCheckEnabled();
			
			// Set up the UI plane.
			// We want it to have some "depth" to it, so we don't track the camera pitch perfectly.
			var frontface_direction = Vector3FromArray(o_Camera3D.m_viewForward);
			var t_cross_y = Vector3FromArray(o_Camera3D.m_viewUp).linearlerpSelf(new Vector3(0, 0, 1), 0.6).normalize().negateSelf();
			var t_cross_x = frontface_direction.cross(t_cross_y).negateSelf();
			var t_cross_z = t_cross_x.cross(t_cross_y); // Different than frontface_direction due to change to t_cross_y
			// TODO: use params.screen_x/y/z ??
			
			// Create some sine-noise for helping with vfx vibes
			var t_noise = new Vector3(
				sin(Time.time *  2.12) + cos(Time.time * -1.24) + sin(Time.time *  4.17),
				cos(Time.time * -1.53) + sin(Time.time *  3.11) + sin(Time.time * -5.21),
				sin(Time.time *  2.52) + sin(Time.time *  1.02) + sin(Time.time * -4.65))
				.multiply(params.scale * 0.05);
			
			//
			// Small use
			//
			if (usable.m_useInfoType == kUseInfoTypeDefault)
			{
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				//draw_set_font(f_Oxygen7);
				
				var no_info_text	= string_upper("no_info_found");
				var dbg_info_text	= string_upper("royale_dbg_fallback");
				var use_text = "[_] " + loc_text("ui usable", usable.m_useText);
				
				draw_set_font(f_04b03);
				var dbg_info_text_width = string_width(dbg_info_text);
				draw_set_font(f_RoboMono10Bold);
				var use_text_width = string_width(use_text);
				
				tex = Ui3Tex_Space(ctx, max(use_text_width, dbg_info_text_width), 50);
				{
					// Draw the USE rectangle
					draw_set_color(is_enabled ? params.color : c_red);
					static kMargin = 2;
					Ui3Tex_RectRect(ctx, tex, 0, 17, use_text_width + kMargin * 2, 19, true);
					Ui3Tex_RectRect(ctx, tex, 0 + 1, 17 + 1, use_text_width + kMargin * 2 - 2, 19 - 2, true);
					Ui3Tex_TextRect(ctx, tex, 0 + kMargin - 1, 17 + kMargin - 1, use_text);
				
					// Draw the debug flashy text
					draw_set_color(merge_color(params.color, c_black, 0.5));
					draw_set_font(f_04b03);
					Ui3Tex_TextRect(ctx, tex, 0, 0, no_info_text);
					Ui3Tex_TextRect(ctx, tex, 0, 8, dbg_info_text);
				}
				var display_position = Vector3FromTranslation(usable).addSelf(params.screen_x.multiply(-10.0 * params.scale));
				display_position.addSelf(t_noise);
				Ui3Shape_Plane(ctx, tex,
					display_position.x, display_position.y, display_position.z,
					t_cross_x, t_cross_y,
					0.15, 0.15, true);
					
				// TODO: Draw the line from the item to the box??? Maybe not, maybe too dirty.
			}
			//
			// Big USE panel!
			//
			else if (usable.m_useInfoType == kUseInfoTypeBig)
			{
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				
				var is_enabled	= usable.m_onCheckEnabled();
				
				var name_text	= string_upper(loc_text("ui usable", usable.vanityName));
				var group_text	= string_upper(loc_text("ui usable", usable.vanityGroup));
				var use_text	= "[_] " + loc_text("ui usable", usable.m_useText);
				var enable_text	= string_upper(loc_text("ui usable", usable.vanityEnable));
				var disable_text= string_upper(loc_text("ui usable", usable.vanityDisable));
				
				draw_set_font(f_RoboMono7);
				var name_text_width = string_width(name_text);
				draw_set_font(f_04b03);
				var group_text_width = string_width(group_text);
				draw_set_font(f_RoboMono12Bold);
				var use_text_width = string_width(use_text);
				draw_set_font(f_RoboMono10);
				var state_text_width = max(string_width(enable_text), string_width(disable_text)); // Don't change size when changing states, so take largest of both
				
				var box_width = max(name_text_width, group_text_width, use_text_width, state_text_width) + 4;
				
				var display_position;
				
				tex = Ui3Tex_Space(ctx, box_width, 70);
				{
					draw_set_color(is_enabled ? params.color : c_red);
					Ui3Tex_RectRect(ctx, tex, 0, 0, box_width, 70, true);
					Ui3Tex_RectRect(ctx, tex, 1, 1, box_width - 2, 70 - 2, true);
					Ui3Tex_RectRect(ctx, tex, 0, 13, box_width, 40, false);
					
					// Draw the vanity text
					draw_set_font(f_RoboMono7);
					Ui3Tex_TextRect(ctx, tex, 3, 2, name_text);
					draw_set_font(f_RoboMono10);
					Ui3Tex_TextRect(ctx, tex, 3, 52, is_enabled ? enable_text : disable_text);
					
					draw_set_color(c_black);
					// Draw inside the light: vanity group
					draw_set_font(f_04b03);
					Ui3Tex_TextRect(ctx, tex, 3, 15, group_text);
				}
				display_position = Vector3FromTranslation(usable).addSelf(params.screen_x.multiply(-10.0 * params.scale));
				display_position.addSelf(t_noise);
				Ui3Shape_Plane(ctx, tex,
					display_position.x, display_position.y, display_position.z,
					t_cross_x, t_cross_y,
					0.15, 0.15, true);
				
				// TODO: clip & conserve atlas space
				tex = Ui3Tex_Space(ctx, box_width, 70);
				{
					// Draw inside the light: use text
					if (is_enabled)
					{
						draw_set_font(f_RoboMono12Bold);
						draw_set_halign(fa_center);
						Ui3Tex_TextRect(ctx, tex, round(box_width / 2), 27, use_text);
					}
					else
					{ // TODO: draw this on a layer over the UI
						draw_set_font(f_RoboMono12Bold);
						draw_set_halign(fa_center);
						Ui3Tex_TextRect(ctx, tex, round(box_width / 2), 27, "X");
					}
				}
				display_position = Vector3FromTranslation(usable).addSelf(params.screen_x.multiply(-10.0 * params.scale));
				display_position.addSelf(t_cross_z.multiply(-2.0 * params.scale));
				Ui3Shape_Plane(ctx, tex,
					display_position.x, display_position.y, display_position.z,
					t_cross_x, t_cross_y,
					0.15, 0.15, true);
			}
			//
			// Item use!
			//
			else if (usable.m_useInfoType == kUseInfoTypeItem)
			{
				var dbg_info_text	= string_upper("royale_id_nn3.1");
				var name_text		= string_upper(loc_text("ui usable", usable.vanityName));
				var use_text		= "[_] " + loc_text("ui usable", usable.m_useText);
				
				draw_set_font(f_RoboMono7);
				var name_text_width = string_width(name_text);
				draw_set_font(f_04b03);
				var group_text_width = 0;
				draw_set_font(f_RoboMono12Bold);
				var use_text_width = string_width(use_text);
				
				var kIconMargin = 18;
				var box_width = max(60, name_text_width, group_text_width, use_text_width) + 6;
				var box_height = ceil((box_width - kIconMargin) / sprite_get_width(usable.m_infoIcon) * sprite_get_height(usable.m_infoIcon)) + 14;
				
				var display_position;
				
				// Draw the icon space
				// TODO: save space and crop the space to the icon
				tex = Ui3Tex_Space(ctx, box_width, box_height);
				{
					drawShaderSet(sh_unlitUiColorflat);
					{
						var sprite_scale = (box_width - kIconMargin * 2 - 1) / sprite_get_width(usable.m_infoIcon);
						draw_set_color(is_enabled ? params.color : c_red);
						Ui3Tex_SpriteRect(ctx, tex,
							kIconMargin, 13,
							usable.m_infoIcon, 0,
							sprite_scale, sprite_scale,
							0.0, draw_get_color(), 1.0);
					}
					drawShaderReset();
				}
				display_position = Vector3FromTranslation(usable).addSelf(params.screen_x.multiply(-10.0 * params.scale));
				display_position.addSelf(t_cross_z.multiply(4.0 * params.scale));
				display_position.addSelf(t_cross_y.multiply(1.0 * params.scale));
				Ui3Shape_Plane(ctx, tex,
					display_position.x, display_position.y, display_position.z,
					t_cross_x, t_cross_y,
					0.15, 0.15, true);
				
				// Draw main rect
				tex = Ui3Tex_Space(ctx, box_width, box_height);
				{
					draw_set_color(is_enabled ? params.color : c_red);
					Ui3Tex_RectRect(ctx, tex, 0, 0, box_width, box_height, true);
					Ui3Tex_RectRect(ctx, tex, 1, 1, box_width - 2, box_height - 2, true);
					Ui3Tex_RectRect(ctx, tex, 0, box_height - 26, box_width, 15, false);
					
					// Draw the vanity text
					draw_set_font(f_RoboMono7);
					draw_set_halign(fa_left);
					draw_set_valign(fa_top);
					Ui3Tex_TextRect(ctx, tex, 3, 2, name_text);
					
					draw_set_font(f_04b03);
					draw_set_color(merge_color(draw_get_color(), c_black, 0.5));
					draw_set_halign(fa_right);
					draw_set_halign(fa_bottom);
					Ui3Tex_TextRect(ctx, tex, box_width - 3, box_height - 10, dbg_info_text);
					
					draw_set_color(c_black);
					draw_set_font(f_RoboMono10Bold);
					draw_set_halign(fa_center);
					draw_set_valign(fa_top);
					Ui3Tex_TextRect(ctx, tex, round(box_width / 2), box_height - 27, use_text);
				}
				display_position = Vector3FromTranslation(usable).addSelf(params.screen_x.multiply(-10.0 * params.scale));
				display_position.addSelf(t_noise);
				Ui3Shape_Plane(ctx, tex,
					display_position.x, display_position.y, display_position.z,
					t_cross_x, t_cross_y,
					0.15, 0.15, true);
			}
			else
			{
				debugLog(kLogError, "Invalid useInfoType: \"" + string(usable.m_useInfoType) + "\"");
			}
			
			// Add the diamond icon
			draw_set_color(params.color);
			tex = Ui3Tex_Rect(ctx, 16, 16, true);
			Ui3Tex_RectRect(ctx, tex, 1, 1, 14, 14, true);
			Ui3Shape_Billboard(ctx, tex,
				usable.x, usable.y, usable.z,
				0.15, 0.15, true,
				45);
		}
	}
}