function settingsGameplayLoad() {
	with (Settings)
	{
	    ini_open("settings.ini");
    
		gameplay_blood				= ini_read_real("gameplay", "blood", gameplay_blood);
		gameplay_autoaim_item		= ini_read_real("gameplay", "autoaim_item", gameplay_autoaim_item);
		gameplay_autoaim_weapon		= ini_read_real("gameplay", "autoaim_weapon", gameplay_autoaim_weapon);
		gameplay_ui_cursor			= ini_read_real("gameplay", "ui_cursor", gameplay_ui_cursor);
		gameplay_ui_font_size		= ini_read_real("gameplay", "ui_font_size", gameplay_ui_font_size);
		gameplay_ui_font_size_talk	= ini_read_real("gameplay", "ui_font_size_talk", gameplay_ui_font_size_talk);
		gameplay_ui_font_style		= ini_read_real("gameplay", "ui_font_style", gameplay_ui_font_style);
		gameplay_mlg_farm_mode		= ini_read_real("gameplay", "mlgmode", gameplay_mlg_farm_mode);

	    ini_close();
	}




}
