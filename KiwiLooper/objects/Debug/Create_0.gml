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

// Game debugging values
lively_show_explode_wire_target = true;

/// @function Show()
/// @desc Show the debug UI
Show = function()
{
	if (!on)
	{
		// Enable & create debug menu
		on = true;
		visible = true;
		show_debug_overlay(true);
		if (!iexists(o_debugMenu)) {
			inew(o_debugMenu);	
		}
	}
}
/// @function Hide()
/// @desc Hide the debug UI
Hide = function()
{
	if (on)
	{
		// Disable debug menu
		on = false;
		visible = false;
		show_debug_overlay(false);
	}
}