function settingsStartupSave() {
	with (Settings)
	{
	    ini_open("settings.ini");
    
		//startup_roomOverride	= ini_read_string("startup", "override", "");
		//startup_roomOverride	= room_get_index(startup_roomOverride);

	    ini_close();
	}




}
