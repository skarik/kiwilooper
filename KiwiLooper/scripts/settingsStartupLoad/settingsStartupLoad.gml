function settingsStartupLoad()
{
	with (Settings)
	{
	    ini_open("settings.ini");
    
		startup_roomOverride	= ini_read_string("startup", "override", "");
		startup_roomOverride	= room_get_index(startup_roomOverride);
	
		startup_overrideSave	= ini_read_real("startup", "overridesave", false);
	
		startup_command			+= ini_read_string("startup", "command", "");
	
		startup_window_xoffset	= ini_read_real("startup", "window_xoffset", 0);
		startup_window_yoffset	= ini_read_real("startup", "window_yoffset", 0);

	    ini_close();
	}
}
