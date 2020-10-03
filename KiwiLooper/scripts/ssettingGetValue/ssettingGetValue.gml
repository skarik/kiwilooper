/// @function ssettingGetValue(settingname)
/// @param settingname {String}
/// @returns Varied type, depending on result of ssettingGetType
function ssettingGetValue(argument0) {
	var settingname = argument0;

	var control_result = controlSettingGet(settingname);
	if (is_array(control_result))
		return control_result;
	
	switch (settingname)
	{
		case "total_volume": return Settings.audio_total_volume;
			break;
		case "sfx_volume": return Settings.audio_sfx_volume;
			break;
		case "music_volume": return Settings.audio_music_volume;
			break;
		case "speech_volume": return Settings.audio_speech_volume;
			break;
		
		case "blood": return Settings.gameplay_blood;
			break;
		case "autoaim_item": return Settings.gameplay_autoaim_item;
			break;
		case "autoaim_weapon": return Settings.gameplay_autoaim_weapon;
			break;
		case "ui_cursor": return Settings.gameplay_ui_cursor;
			break;
		case "ui_font_size": return Settings.gameplay_ui_font_size;
			break;
		case "ui_font_size_talk": return Settings.gameplay_ui_font_size_talk;
			break;
		case "ui_font_style": return Settings.gameplay_ui_font_style;
			break;
		case "mlgmode": return Settings.gameplay_mlg_farm_mode;
	}

	return null;


}
