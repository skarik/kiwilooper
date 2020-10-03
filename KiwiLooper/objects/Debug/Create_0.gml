if (singleton_this()) exit; // Make this object a singleton

captureModeEnabled = false;
recordModeEnabled = false;
convention_mode = false; // turn on for convention demos
demo_mode = false;

// Enable debug mode for now
on = false;
show_squad_info = false;
enable_gmlive = false;

// Debug lines:
debug_line[0] = "";
debug_line_count = 0;

// Debug mode restart all swatch:
reset = convention_mode || demo_mode;// || debug_mode;
// Farm id
farm_id = current_time;


// Debug effects
var record_overlay = inew(o_debugRecordOverlay);
	record_overlay.persistent = true;
	

// status
gifWidth = 560;//Screen.width;// / Screen.pixelScale;
gifHeight = 560;//Screen.height;// / Screen.pixelScale;

if (convention_mode || demo_mode)
{
	window_set_fullscreen(true);
}