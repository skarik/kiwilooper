function AKUi_BeeInventory() : AKiwiUiComponent() constructor
{
	static Build = function(params, ctx)
	{
		draw_set_color(params.color);
		
		var kBackColor = merge_color(params.color, c_navy, 0.8);
		
		var tex;
		
		draw_set_color(kBackColor);
		// Draw the inventory rect
		tex = Ui3Tex_Rect(ctx, 208, 140, true);
		{
			// Draw all the boxes for the inventory
			var kBoxCountX = 12;
			var kBoxCountY = 8;
			var kBoxSize = 15;
			var kBoxMargin = 2;
			
			for (var i_box_x = 0; i_box_x < kBoxCountX; ++i_box_x)
			{
				for (var i_box_y = 0; i_box_y < kBoxCountY; ++i_box_y)
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
			
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
			draw_set_font(f_RoboMono7);
			draw_set_color(params.color);
			Ui3Tex_TextRect(ctx, tex, 4, 4, "UV testing for procmesh");
		}
		var display_position = Vector3FromTranslation(params.player)
			.add(new Vector3(20.0, 10.0, 12.0).rotateZSelf(params.player.facingDirection));
		/*Ui3Shape_Billboard(ctx, tex,
			display_position.x, display_position.y, display_position.z,
			0.2, 0.2, true);*/
		Ui3Shape_ArcPlane(ctx, tex,
			display_position.x, display_position.y, display_position.z,
			params.screen_x, params.screen_y,
			40.0,
			-17, 21,
			0.2, 0.2, true);
		
		
		var kButtonWidth = 67;
		var kButtonHeight = 20;
		var kButtonMargin = 4;
		var kButtonText = [
			string_upper(loc_text("ui inventory", "Inventory")),
			string_upper(loc_text("ui inventory", "Tasks")),
			string_upper(loc_text("ui inventory", "Logs")),
		];
		
		draw_set_color(params.color);
		
		// Set up button back
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
				Ui3Tex_TextRect(ctx, tex, 1, 1, kButtonText[i_button]);
			}
			
			var display_button_position = display_position
				.add(new Vector3(0, 9.0 * (i_button - 1), 13.0).rotateZSelf(params.player.facingDirection));
			Ui3Shape_Billboard(ctx, tex_button_back,
				display_button_position.x, display_button_position.y, display_button_position.z,
				0.2, 0.2, true);
				
			display_button_position.addSelf(new Vector3(-2.0, 0, 0).rotateZSelf(params.player.facingDirection));
			Ui3Shape_Billboard(ctx, tex,
				display_button_position.x, display_button_position.y, display_button_position.z,
				0.2, 0.2, true);
		}
	}
}
