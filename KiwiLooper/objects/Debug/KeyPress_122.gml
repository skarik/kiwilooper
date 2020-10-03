/// @description start recording

if (recordModeEnabled == false)
{
	recordModeEnabled = true;
	captureModeEnabled = true;
	ms_prev_on = on;
	on = false;
}
else
{
	on = ms_prev_on;
	recordModeEnabled = false;
	
	// Save out to GIF
	with (Screen)
	{
		var dir = "screenshots";
        if ( !directory_exists(dir) )
            directory_create(dir);
        // Ensure screenshots are not overridden
        while ( file_exists(dir + "/recording_" + string_replace_all(string_format(record_shot_output_count,4,0)," ","0") + ".gif") )
            record_shot_output_count += 1;
		var output_filename = dir + "/recording_" + string_replace_all(string_format(record_shot_output_count,4,0)," ","0") + ".gif";
		
		// Preprocess gif
		var kGifUpscale = 2.0;
		//var kGifWidth = 560; //Screen.width / Screen.pixelScale;
		//var kGifHeight = 560; //Screen.height / Screen.pixelScale; 
		
		var kGifWidth = Debug.gifWidth;//Screen.width / Screen.pixelScale;
		var kGifHeight = Debug.gifHeight;//Screen.height / Screen.pixelScale; 
		
		var temp_surface = array_create(0);
		for (var i = 0; i < record_shot_count; ++i)
		{
			//gif_add_surface(gif, record_shot[i], 2);
			gpu_set_blendenable(false);
			gpu_set_blendmode_ext(bm_one, bm_zero);
			
			temp_surface[i] = surface_create(kGifWidth, kGifHeight);
			surface_set_target(temp_surface[i]);
			draw_surface_ext(record_shot[i],
							 (kGifWidth/kGifUpscale - surface_get_width(record_shot[i])) * 0.5 * kGifUpscale,
							 (kGifHeight/kGifUpscale - surface_get_height(record_shot[i])) * 0.5 * kGifUpscale,
							 kGifUpscale,
							 kGifUpscale,
							 0.0,
							 c_white,
							 1.0);
			surface_reset_target();
			
			gpu_set_blendmode(bm_normal);
		}
		
		// Create GIF
		var gif = gif_open(kGifWidth, kGifHeight);
		// Add all the surfaces in
		for (var i = 0; i < record_shot_count; ++i)
		{
			//gif_add_surface(gif, record_shot[i], 2);
			gif_add_surface(gif, temp_surface[i], 2, 0, 0, 3);
		}
		// Save
		gif_save(gif, output_filename);
		
		// Free all the shots
		for (var i = 0; i < record_shot_count; ++i)
		{
			surface_free(record_shot[i]);
			surface_free(temp_surface[i]);
		}
		record_shot_count = 0;
	}
}