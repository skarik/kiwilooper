/// @function ssettingSetValue(settingname, value)
/// @param settingname {String}
/// @param value {Varies} Varied type depending on result of ssettingGetType
function ssettingSetValue(argument0, argument1) {
	var settingname = argument0;
	var value = argument1;

	if (controlSettingSet(settingname, value))
		return true;
	
	switch (settingname)
	{
		case "total_volume": Settings.audio_total_volume = value;
			break;
		case "sfx_volume": Settings.audio_sfx_volume = value;
			break;
		case "music_volume": Settings.audio_music_volume = value;
			break;
		case "speech_volume": Settings.audio_speech_volume = value;
			break;
		
		case "blood": Settings.gameplay_blood = value;
			break;
		case "autoaim_item": Settings.gameplay_autoaim_item = value;
			break;
		case "autoaim_weapon": Settings.gameplay_autoaim_weapon = value;
			break;
		case "ui_cursor": Settings.gameplay_ui_cursor = value;
			break;
		case "ui_font_size": Settings.gameplay_ui_font_size = value;
			break;
		case "ui_font_size_talk": Settings.gameplay_ui_font_size_talk = value;
			break;
		case "ui_font_style": Settings.gameplay_ui_font_style = value;
			break;
		case "mlgmode": Settings.gameplay_mlg_farm_mode = value;
		
		default:
			return false;
	}

	return true;


}
