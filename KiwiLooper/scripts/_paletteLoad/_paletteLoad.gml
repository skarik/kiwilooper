function _paletteLoad(argument0, argument1) {
	var pal_index = argument0;
	var pal_source = argument1;

	var kFilenameSprite3D = "palette"+string(pal_index)+"_0.png";
	var kFilenameSprite3D2 = "palette"+string(pal_index)+"_1.png";

	// Init starting sprites
	global.pal_sprite3d[pal_index] = null;
	global.pal_sprite3d2[pal_index] = null;
	global.pal_color[pal_index] = [];
	global.pal_width[pal_index] = 0;

	if (file_exists(kFilenameSprite3D) && file_exists(kFilenameSprite3D2))
	{
		global.pal_sprite3d[pal_index] = sprite_add(kFilenameSprite3D, 0, 0, 0, 0, 0);
		global.pal_sprite3d2[pal_index] = sprite_add(kFilenameSprite3D2, 0, 0, 0, 0, 0);
	
		global.pal_granularity = 8;
		global.pal_lutWidth = 256 / global.pal_granularity;
		return;
	}

	var palette_width = sprite_get_width(pal_source);

	var palette_surface = surface_create(palette_width, 1);
	surface_set_target(palette_surface);
	draw_sprite(pal_source, 0, 0, 0);
	surface_reset_target();

	var palette_buffer = buffer_create(palette_width * 4, buffer_fixed, 4); 
	buffer_get_surface(palette_buffer, palette_surface, 0);

	// Pull out the palette colors
	var palette_color;
	for (var i = 0; i < palette_width; ++i)
	{
		var _col = buffer_read(palette_buffer, buffer_u32); 
	    //var _a = (_col >> 24) & 255;
	    var _b = (_col >> 16) & 255;
	    var _g = (_col >> 8) & 255;
	    var _r = _col & 255;  
	    var _final_col = make_color_rgb(_r, _g, _b);
	
		palette_color[i] = _final_col;
	}
	global.pal_color[pal_index] = palette_color;

	// Save the palette width now
	global.pal_width[pal_index] = palette_width;

	// Free up buffers now that we have the data in an array:
	buffer_delete(palette_buffer);
	surface_free(palette_surface);

	// Now, generate a 3d LUT
	global.pal_granularity = 8;
	global.pal_lutWidth = 256 / global.pal_granularity;
	var palette_lut = array_create(global.pal_lutWidth * global.pal_lutWidth * global.pal_lutWidth);
	var palette_lut2 = array_create(global.pal_lutWidth * global.pal_lutWidth * global.pal_lutWidth);
	for (var u = 0; u < global.pal_lutWidth; ++u)
	{
		for (var v = 0; v < global.pal_lutWidth; ++v)
		{
			for (var w = 0; w < global.pal_lutWidth; ++w)
			{
				var i3d = (u) + (v * global.pal_lutWidth) + (w * global.pal_lutWidth * global.pal_lutWidth);
				var _r = u * global.pal_granularity + global.pal_granularity / 2;
				var _g = v * global.pal_granularity + global.pal_granularity / 2;
				var _b = w * global.pal_granularity + global.pal_granularity / 2;
				var _rgb = make_color_rgb(_r, _g, _b);	
			
				// find the closest color
				var _delta = 256 * 256 * 3;
				var _color = c_black;
				for (var i = 0; i < palette_width; ++i)
				{
					var _deltaTest = sqr(color_get_red(palette_color[i]) - _r)
						+ sqr(color_get_green(palette_color[i]) - _g)
						+ sqr(color_get_blue(palette_color[i]) - _b);
					/*var _deltaTest = abs(color_get_value(global.pal_color[i]) - color_get_value(_rgb)) * 0.02
						+ abs(color_get_saturation(global.pal_color[i]) - color_get_saturation(_rgb)) * 0.0125
						+ abs(angle_difference(color_get_hue(global.pal_color[i]) / 255.0 * 360, color_get_hue(_rgb)  / 255.0 * 360) * (360.0 / 255)) * 0.02;*/
					
					if (_deltaTest < _delta)
					{
						_delta = _deltaTest;
						_color = palette_color[i];
					}
				}
			
				palette_lut[i3d] = _color;
			
				// find the second closest color
				_delta = 256 * 256 * 3; // reset delta
				var _color2 = c_black;
				for (var i = 0; i < palette_width; ++i)
				{
					if (palette_color[i] == _color) continue; // skip the actual closest
				
					var _deltaTest = sqr(color_get_red(palette_color[i]) - _r)
						+ sqr(color_get_green(palette_color[i]) - _g)
						+ sqr(color_get_blue(palette_color[i]) - _b);
					/*var _deltaTest = abs(color_get_value(global.pal_color[i]) - color_get_value(_rgb)) * 0.02
						+ abs(color_get_saturation(global.pal_color[i]) - color_get_saturation(_rgb)) * 0.0125
						+ abs(angle_difference(color_get_hue(global.pal_color[i]) / 255.0 * 360, color_get_hue(_rgb)  / 255.0 * 360) * (360.0 / 255)) * 0.02;*/
					
					if (_deltaTest < _delta)
					{
						_delta = _deltaTest;
						_color2 = palette_color[i];
					}
				}
			
				palette_lut2[i3d] = _color2;
			}
		}
	}
	// Save the LUTs
	global.pal_lut[pal_index] = palette_lut;
	global.pal_lut2[pal_index] = palette_lut2;

	// Now, create a texture from the 3d LUT
	global.pal_lutSplit = 1;
	var palette_surface3d = surface_create(global.pal_lutWidth * global.pal_lutWidth / global.pal_lutSplit, global.pal_lutWidth * global.pal_lutSplit);
	var palette_divLut = global.pal_lutWidth / global.pal_lutSplit;

	draw_set_alpha(1.0);
	{
		// Draw the 3D primary palette
		surface_set_target(palette_surface3d);
		for (var u = 0; u < global.pal_lutWidth; ++u)
		{
			for (var v = 0; v < global.pal_lutWidth; ++v)
			{
				for (var w = 0; w < global.pal_lutWidth; ++w)
				{
					var i3d = (u) + (v * global.pal_lutWidth) + (w * global.pal_lutWidth * global.pal_lutWidth);
					draw_set_color(palette_lut[i3d]);
					draw_point(
						u + (w % palette_divLut) * global.pal_lutWidth,
						v + floor(w / palette_divLut) * global.pal_lutWidth);
				}
			}
		}
		surface_reset_target();
		global.pal_sprite3d[pal_index] = sprite_create_from_surface(palette_surface3d, 0, 0, surface_get_width(palette_surface3d), surface_get_height(palette_surface3d), false, false, 0, 0);

		// Draw the 3D secondary palette
		surface_set_target(palette_surface3d);
		for (var u = 0; u < global.pal_lutWidth; ++u)
		{
			for (var v = 0; v < global.pal_lutWidth; ++v)
			{
				for (var w = 0; w < global.pal_lutWidth; ++w)
				{
					var i3d = (u) + (v * global.pal_lutWidth) + (w * global.pal_lutWidth * global.pal_lutWidth);
					draw_set_color(palette_lut2[i3d]);
					draw_point(
						u + (w % palette_divLut) * global.pal_lutWidth,
						v + floor(w / palette_divLut) * global.pal_lutWidth);
				}
			}
		}
		surface_reset_target();
		global.pal_sprite3d2[pal_index] = sprite_create_from_surface(palette_surface3d, 0, 0, surface_get_width(palette_surface3d), surface_get_height(palette_surface3d), false, false, 0, 0);
	}
	// clear drawing
	surface_free(palette_surface3d);

	// Save the files
	sprite_save(global.pal_sprite3d[pal_index], 0, kFilenameSprite3D);
	sprite_save(global.pal_sprite3d2[pal_index], 0, kFilenameSprite3D2);


}
