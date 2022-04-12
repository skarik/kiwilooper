function settingsStartupDefaults()
{
	with (Settings)
	{
		startup_roomOverride = null;
		startup_overrideSave = false;
		startup_command = "";
	
		startup_window_xoffset = 0;
		startup_window_yoffset = 0;
		
		for (var i = 0; i < parameter_count(); ++i)
		{
			startup_command += parameter_string(i + 1) + "; ";
		}
	}
}
