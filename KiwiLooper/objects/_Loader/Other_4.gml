commonStart();

// Loader state for later
bRoomIsSet = false;

inew(System);
inew(Screen);
inew(GameCamera);
inew(Time);
inew(Debug);
inew(Settings);
inew(Game);
inew(Audio);

if (Debug.enable_gmlive)
	inew(obj_gmlive);

// Update persistance
System.persistent = true;
Screen.persistent = true;
GameCamera.persistent = true;
Debug.persistent = true;
Settings.persistent = true;

// Update layers
Screen.layer = System.layer;
GameCamera.layer = System.layer;
Debug.layer = System.layer;
Settings.layer = System.layer;

// Load fonts
fontsLoad();
// Load global shaders
shadersGlobalLoad();

// Load soundscales
soundscapesLoad();

// Loop through each room and set the views
var t_currentRoom = room_first;
while (room_exists(t_currentRoom))
{
	if (t_currentRoom != room)
	{
		room_set_view_enabled(t_currentRoom, true);
		// Set game viewport
		room_set_viewport(t_currentRoom, 0,
			true,
			0, 0, Screen.width / Screen.pixelScale, Screen.height / Screen.pixelScale);
		// Set window viewport
		room_set_viewport(t_currentRoom, 1,
			false,
			0, 0, Screen.width, Screen.height);
		// We use raw cameras instead of views, now.
	}
	t_currentRoom = room_next(t_currentRoom);
}

// Update the window
window_set_size(Screen.width, Screen.height);
window_set_position((display_get_width() - Screen.width) / 2.0 + Settings.startup_window_xoffset,
					(display_get_height() - Screen.height) / 2.0 + Settings.startup_window_yoffset); // Center the window

// Output some debug info
debugLog(kLogOutput, "working_directory: " + working_directory);
debugLog(kLogOutput, "program_directory: " + program_directory);
debugLog(kLogOutput, "temp_directory: " + temp_directory);
debugLog(kLogOutput, "default depth buffer state: " + (surface_get_depth_disable() ? "off" : "on"));

// Finish and go to next room:

// First, run the command line options
if (string_length(Settings.startup_command) > 0)
{
	dcmdRunString(Settings.startup_command);
}

// Once the command line options are run, if we're still in this room, run other level settings
if (_Loader.bRoomIsSet == false)
{
	if (Settings.startup_overrideSave)
	{
		if (room_exists(Settings.startup_roomOverride))
			room_goto(Settings.startup_roomOverride);
		else
			room_goto_next();
	}
	else
	{
		// If not, we just continue normally.
		room_goto_next();
	}
}

// TODO: Handle game save/load with gameLoad and Debug.reset. May not be necessary.