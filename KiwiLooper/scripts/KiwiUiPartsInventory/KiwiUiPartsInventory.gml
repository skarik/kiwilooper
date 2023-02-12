function AKUi_BeeInventory() : AKiwiUiComponent() constructor
{
	static Build = function(params, ctx)
	{
		if (params.player.inInventoryBlend < 0.5) return;
		
		draw_set_color(params.color);
		
		var kBackColor = merge_color(params.color, c_navy, 0.8);
		
		var tex;
		
		var inventory = params.player.m_inventory;
		
		var kBoxCountX = inventory.GetMaxWidth();
		var kBoxCountY = inventory.GetMaxHeight();
		var kBoxSize = 15;
		var kBoxMargin = 2;
		
		var bag_debug_text = "dbg:ROYALE_BAG_MANAGER";
		
		// Draw the inventory rect
		var kBoxWidth = kBoxCountX * (kBoxMargin + kBoxSize) + kBoxMargin;
		var kBoxHeight= kBoxCountY * (kBoxMargin + kBoxSize) + kBoxMargin;
		//tex = Ui3Tex_Rect(ctx, 208, 140, true);
		tex = Ui3Tex_Space(ctx, kBoxWidth, kBoxHeight + 10);
		{
			draw_set_color(kBackColor);
			Ui3Tex_RectRect(ctx, tex, 0, 0, kBoxWidth, kBoxHeight, true);
			
			// Draw all the boxes for the inventory
			var blocks = inventory.GetCachedBlocks();
			for (var i_box_x = 0; i_box_x < kBoxCountX; ++i_box_x)
			{
				for (var i_box_y = 0; i_box_y < kBoxCountY; ++i_box_y)
				{
					// If block isn't filled, draw a dot.
					if (!blocks[i_box_x + i_box_y * kBoxCountX].filled)
					{
						/*Ui3Tex_RectRect(ctx, tex,
							i_box_x * (kBoxSize + kBoxMargin) + kBoxMargin,
							i_box_y * (kBoxSize + kBoxMargin) + kBoxMargin,
							kBoxSize,
							kBoxSize,
							true);*/
						Ui3Tex_SpriteRect(ctx, tex,
							i_box_x * (kBoxSize + kBoxMargin) + kBoxMargin + kBoxSize * 0.5 - 1,
							i_box_y * (kBoxSize + kBoxMargin) + kBoxMargin + kBoxSize * 0.5 - 1,
							sui_vtos_dots, 2,
							1.0, 1.0, 0.0,
							draw_get_color(),
							1.0);
					}
				}
			}
			
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_font(f_RoboMono7);
			draw_set_color(params.color);
			//Ui3Tex_TextRect(ctx, tex, 4, 4, "UV testing");
			var items = inventory.GetItems();
			for (var i_items = 0; i_items < array_length(items); ++i_items)
			{
				// todo: i_items
				var item = items[i_items];
				Ui3Tex_RectRect(ctx, tex,
					item.x * (kBoxSize + kBoxMargin) + 1,
					item.y * (kBoxSize + kBoxMargin) + 1,
					item.width * (kBoxSize + kBoxMargin) - 2,
					item.height * (kBoxSize + kBoxMargin) - 2,
					true);
				Ui3Tex_TextRect(ctx, tex,
					item.x * (kBoxSize + kBoxMargin) + 3,
					item.y * (kBoxSize + kBoxMargin) + 3,
					item.name);
			}
			
			draw_set_color(kBackColor);
			draw_set_font(f_04b03);
			Ui3Tex_TextRect(ctx, tex, 1, kBoxHeight + 1, bag_debug_text);
		}
		var display_position = Vector3FromTranslation(params.player)
			.add(new Vector3(20.0, 10.0, 13.0).rotateZSelf(params.player.facingDirection));
		/*Ui3Shape_Billboard(ctx, tex,
			display_position.x, display_position.y, display_position.z,
			0.2, 0.2, true);*/
		Ui3Shape_ArcPlane(ctx, tex,
			display_position.x, display_position.y, display_position.z,
			params.screen_x, params.screen_y,
			330.0,
			-14, 15,
			0.2, 0.2, true);
			
		// Draw the money
		//var money_amount_text = string_format(inventory.GetMoney() / 1000.0, 3 + floor(log10(inventory.GetMoney())), 6);
		var money_amount_text = string_format(inventory.GetMoney() / 10000.0, floor(log10(inventory.GetMoney())) - 3, 6);
		money_amount_text = string_replace_all(money_amount_text, " ", "0");
		
		draw_set_color(params.color);
		tex = Ui3Tex_Space(ctx, 60, 10);
		{
			Ui3Tex_SpriteRect(ctx, tex,
				0, 0, sui_vtos_icons, 0,
				1.0, 1.0, 0.0,
				draw_get_color(), 1.0);
				
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_font(f_04b03);
			Ui3Tex_TextRect(ctx, tex,
				8, -1, money_amount_text);
		}
		var display_position_money = display_position
			.add(new Vector3(0.0, 0.0, 10.2));
		Ui3Shape_Billboard(ctx, tex,
			display_position_money.x, display_position_money.y, display_position_money.z,
			0.2, 0.2, true);
			
		// Draw the healthigatchi
		var kTamaWidth = kBoxWidth;
		var kTamaHeight = 43;
		
		var tama_dbg_text = "dbg:kiwi_HEALTH_HELPER";
		
		tex = Ui3Tex_Space(ctx, kTamaWidth, kTamaHeight + 10);
		{
			draw_set_color(params.color);
			Ui3Tex_RectRect(ctx, tex, 13, 0, kTamaWidth - 26, kTamaHeight, true);
			
			// Health sprite
			Ui3Tex_SpriteRect(ctx, tex, 1, kTamaHeight - 11, sui_vtos_icons, 5, 1.0, 1.0, 0.0, draw_get_color(), 1.0);
			// Hunger sprite
			Ui3Tex_SpriteRect(ctx, tex, kTamaWidth - 10, kTamaHeight - 10, sui_vtos_icons, 3, 1.0, 1.0, 0.0, draw_get_color(), 1.0);
			
			// Draw health bar background (curved rect)
			//Ui3Tex_RectRect(ctx, tex, 0, 0, 11, kTamaHeight - 13, true);
			Ui3Tex_LineRect(ctx, tex, 2, 0, 10, 0);
			Ui3Tex_LineRect(ctx, tex, 2, kTamaHeight - 13, 10, kTamaHeight - 13);
			Ui3Tex_LineRect(ctx, tex, 0, 2, 0, kTamaHeight - 14);
			Ui3Tex_LineRect(ctx, tex, 11, 2, 11, kTamaHeight - 14);
			// Draw hunger background
			Ui3Tex_LineRect(ctx, tex, kTamaWidth - 2 - 1, 0, kTamaWidth - 10 - 1, 0);
			Ui3Tex_LineRect(ctx, tex, kTamaWidth - 2 - 1, kTamaHeight - 13, kTamaWidth - 10 - 1, kTamaHeight - 13);
			Ui3Tex_LineRect(ctx, tex, kTamaWidth - 0 - 1, 2, kTamaWidth - 0 - 1, kTamaHeight - 14);
			Ui3Tex_LineRect(ctx, tex, kTamaWidth - 11 - 1, 2, kTamaWidth - 11 - 1, kTamaHeight - 14);
			
			// Draw health bar
			{
				// Start Y is based on Time
				var time_scalar = 0.6;
				var health_max_height = kTamaHeight - 14;
				var health_start_y = round( ((Time.time * time_scalar) % 1.0) * health_max_height );
				draw_set_color(c_white);
				for (var i = 0; i < 20; i += 1)
				{
					var parametric_time0 = Time.time * time_scalar + (i+0) / health_max_height;
					var parametric_time1 = Time.time * time_scalar + (i+2) / health_max_height;
				
					static Heartbeat = function(t)
					{
						var heartbeat_signal = max(0.0, (sin(t * 9) - 0.8) / 0.2);
						var heartbeat_tan = clamp(tan(round(t * 9 / 1.0) * 1.0), -5.0, 5.0);
						return (heartbeat_signal > 0.0) ? heartbeat_tan : 0.0;
					};
				
					var offset0 = Heartbeat(parametric_time0);
					var offset1 = Heartbeat(parametric_time1);
				
					var y0 = (health_start_y + i) % health_max_height;
					var y1 = (health_start_y + (i + 2)) % health_max_height;
				
					if (y0 < y1)
					{
						draw_set_alpha(min(1.0, i / 15));
						Ui3Tex_LineRect(ctx, tex,
							5 + offset0, y0,
							5 + offset1, y1
							);
					}
				}
			}
			draw_set_alpha(1.0);
			
			// Draw hunger bar
			draw_set_color(params.color);
			var hunger_level = 0.4;
			var hunger_max_height = kTamaHeight - 14;
			Ui3Tex_RectRect(ctx, tex, kTamaWidth - 11, 1 + lerp(hunger_max_height, 0.0, hunger_level), 10, lerp(0.0, hunger_max_height, hunger_level), false);
			
			draw_set_color(c_maroon);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_font(f_04b03);
			Ui3Tex_TextRect(ctx, tex, int64(kTamaWidth / 2), int64(kTamaHeight / 2), "MISSING ASSEMBLY\n\"TAMA.DLL\"");
			
			draw_set_color(kBackColor);
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_font(f_04b03);
			Ui3Tex_TextRect(ctx, tex, 0, kTamaHeight, tama_dbg_text);
		}
		Ui3Shape_ArcPlane(ctx, tex,
			display_position.x, display_position.y, display_position.z - 12.5,
			params.screen_x, params.screen_y,
			300.0,
			-14, 15,
			0.2, 0.2, true);
		
		// Draw buttons
		{
			var kButtonWidth = 50;
			var kButtonHeight = 20;
			var kButtonMargin = 4;
			var kButtonText = [
				string_upper(loc_text("ui inventory", "Storage")),
				string_upper(loc_text("ui inventory", "Tasks")),
				string_upper(loc_text("ui inventory", "Logs")),
			];
		
			// Set up button back
			draw_set_color(params.color);
			tex = Ui3Tex_Rect(ctx, kButtonWidth, kButtonHeight, true);
			{
				// TODO
			}
			var tex_button_back = tex;
			
			// Draw the button rects
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_font(f_RoboMono7);
			for (var i_button = 0; i_button < 3; ++i_button)
			{
				var selected = i_button == 0;
			
				tex = Ui3Tex_Space(ctx, kButtonWidth, kButtonHeight);
				if (selected)
				{
					draw_set_color(params.color);
					Ui3Tex_RectRect(ctx, tex, 0, 0, kButtonWidth, kButtonHeight, false);
					draw_set_color(c_black);
					Ui3Tex_TextRect(ctx, tex, 3, 3, kButtonText[i_button]);
					draw_set_color(params.color);
				}
				else
				{
					Ui3Tex_TextRect(ctx, tex, 2, 2, kButtonText[i_button]);
				}
				var display_angle = (i_button - 1) * -25.0;
			
				var display_button_position = display_position
					.add(new Vector3(i_button * 0.8 + ((i_button == 1) ? 1.2 : 0.0), 6.8 * (i_button - 1), 13.0).rotateZSelf(params.player.facingDirection));
				Ui3Shape_Plane(ctx, tex_button_back,
					display_button_position.x, display_button_position.y, display_button_position.z,
					params.screen_x.rotateZ(display_angle), params.screen_y.rotateZ(display_angle),
					0.2, 0.2, true);
				
				display_button_position
					.addSelf(new Vector3(-2.0, 0, 0).rotateZSelf(params.player.facingDirection));
				Ui3Shape_Plane(ctx, tex,
					display_button_position.x, display_button_position.y, display_button_position.z,
					params.screen_x.rotateZ(display_angle), params.screen_y.rotateZ(display_angle),
					0.2, 0.2, true);
			}
		} // End draw buttons
	}
}
