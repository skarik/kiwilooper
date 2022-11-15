/// @description Screenshot & fullscreen toggle

var screenshot_requested = false;
if (keyboard_check_pressed(vk_f5))
{
	debugLog(kLogOutput, "screenshot requested");
	screenshot_requested = true;
}

var t_capturedSurface = m_outputSurfaceHistory[0];

if ((screenshot_requested || screenshot_auto_enabled) && surface_exists(t_capturedSurface))
{
    screenshot_timer += Time.dt;
    // Take a screenshot every 1.0s
    if ( screenshot_timer > 1.0 || screenshot_requested )
    {
        screenshot_timer = 0;
        
        // Create screenshot dir
        //var dir = "./screenshots";
		var dir = "screenshots";
        if ( !directory_exists(dir) )
            directory_create(dir);
        // Ensure screenshots are not overridden
        while ( file_exists(dir + "/shot_" + string_replace_all(string_format(screenshot_count,4,0)," ","0") + ".png") )
            screenshot_count += 1;
            
        // Save the current screen
        var filename = "shot_" + string_replace_all(string_format(screenshot_count,4,0)," ","0") + ".png";
        //surface_save(t_capturedSurface, working_directory + "/" + filename);
		surface_save(t_capturedSurface, dir + "/" + filename);
        screenshot_count += 1;
		
		debugLog(kLogOutput, "screenshot " + string(screenshot_count) + " taken to " + filename);
    }
}

// Fullscreen toggle
if (keyboard_check_direct(vk_lalt) && keyboard_check_pressed(vk_enter))
{
	window_set_fullscreen(!window_get_fullscreen());
	WindowOnResize();
}

// Window resize call manually (event does not trigger properly)
if (savedwidth != window_get_width() || savedheight != window_get_height())
{
	WindowOnResize();
}
