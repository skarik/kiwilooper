function paletteUpdate() {
	var pal_index = global.pal_current;

	// Update blend
	global.pal_current_blend = motion1d_to(global.pal_current_blend, pal_index, Time.deltaTime * 2.0);

	// update main palette
	{
		// Create surface
		if (!surface_exists(global.pal_surface3d))
			global.pal_surface3d = surface_create(global.pal_lutWidth * global.pal_lutWidth, global.pal_lutWidth);
	
		// Set to draw onto the 3D palette
		surface_set_target(global.pal_surface3d);

		// Refresh with the base 3D palette
		gpu_set_blendenable(false);
		gpu_set_blendmode_ext(bm_one, bm_zero);
		if (global.pal_current_blend == pal_index)
			draw_sprite(global.pal_sprite3d[pal_index], 0, 0, 0);
		else
		{
			draw_sprite(global.pal_sprite3d[floor(global.pal_current_blend)], 0, 0, 0);
			gpu_set_blendenable(true);
			gpu_set_blendmode(bm_normal);
			draw_sprite_ext(global.pal_sprite3d[ceil(global.pal_current_blend)], 0, 0, 0, 1.0, 1.0, 0.0, c_white, frac(global.pal_current_blend));
		}

		// now draw overlays that are registered
		/*gpu_set_blendenable(true);
		gpu_set_blendmode_ext(bm_dest_color, bm_src_color);
		draw_set_color(global.pal_overlay_madd2);
		draw_rectangle(0, 0, global.pal_lutWidth * global.pal_lutWidth, global.pal_lutWidth, false);*/

		// pop render stack (dumb)
		surface_reset_target();
	}

	// also update the secondary palette
	{
		// Create surface
		if (!surface_exists(global.pal_surface3d2))
			global.pal_surface3d2 = surface_create(global.pal_lutWidth * global.pal_lutWidth, global.pal_lutWidth);
	
		// Set to draw onto the 3D palette
		surface_set_target(global.pal_surface3d2);

		// Refresh with the base 3d palette
		gpu_set_blendenable(false);
		gpu_set_blendmode_ext(bm_one, bm_zero);
		if (global.pal_current_blend == pal_index)
			draw_sprite(global.pal_sprite3d2[pal_index], 0, 0, 0);
		else
		{
			draw_sprite(global.pal_sprite3d2[floor(global.pal_current_blend)], 0, 0, 0);
			gpu_set_blendenable(true);
			gpu_set_blendmode(bm_normal);
			draw_sprite_ext(global.pal_sprite3d2[ceil(global.pal_current_blend)], 0, 0, 0, 1.0, 1.0, 0.0, c_white, frac(global.pal_current_blend));
		}

		// now draw overlays that are registered
		/*gpu_set_blendenable(true);
		gpu_set_blendmode_ext(bm_dest_color, bm_src_color);
		draw_set_color(global.pal_overlay_madd2);
		draw_rectangle(0, 0, global.pal_lutWidth * global.pal_lutWidth, global.pal_lutWidth, false);*/

		// pop render stack (dumb)
		surface_reset_target();
	}


	// update static wide palette
	{
		// Create surface
		if (!surface_exists(global.pal_surfaceUI3d))
			global.pal_surfaceUI3d = surface_create(global.pal_lutWidth * global.pal_lutWidth, global.pal_lutWidth);
	
		// Set to draw onto the 3D palette
		surface_set_target(global.pal_surfaceUI3d);

		// Refresh with the base 3D palette
		gpu_set_blendenable(false);
		gpu_set_blendmode_ext(bm_one, bm_zero);
		draw_sprite(global.pal_sprite3d[kPaletteUI], 0, 0, 0);

		// now draw overlays that are registered
		/*gpu_set_blendenable(true);
		gpu_set_blendmode_ext(bm_dest_color, bm_src_color);
		draw_set_color(global.pal_overlay_madd2);
		draw_rectangle(0, 0, global.pal_lutWidth * global.pal_lutWidth, global.pal_lutWidth, false);*/

		// pop render stack (dumb)
		surface_reset_target();
	}

	// also update the secondary palette
	{
		// Create surface
		if (!surface_exists(global.pal_surfaceUI3d2))
			global.pal_surfaceUI3d2 = surface_create(global.pal_lutWidth * global.pal_lutWidth, global.pal_lutWidth);
	
		// Set to draw onto the 3D palette
		surface_set_target(global.pal_surfaceUI3d2);

		// Refresh with the base 3d palette
		gpu_set_blendenable(false);
		gpu_set_blendmode_ext(bm_one, bm_zero);
		draw_sprite(global.pal_sprite3d2[kPaletteUI], 0, 0, 0);

		// now draw overlays that are registered
		/*gpu_set_blendenable(true);
		gpu_set_blendmode_ext(bm_dest_color, bm_src_color);
		draw_set_color(global.pal_overlay_madd2);
		draw_rectangle(0, 0, global.pal_lutWidth * global.pal_lutWidth, global.pal_lutWidth, false);*/

		// pop render stack (dumb)
		surface_reset_target();
	}

	// reset draw state
	gpu_set_blendenable(true);
	gpu_set_blendmode(bm_normal);

	// return the 3d palette
	return global.pal_surface3d;


}
