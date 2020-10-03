/// @function ssettingGetMin(settingname)
/// @param settingname {Setting}
/// @returns Varied type, depending on result of ssettingGetType
function ssettingGetMin(argument0) {
	var settingname = argument0;

	switch (settingname)
	{
		case "total_volume":
		case "sfx_volume":
		case "music_volume":
		case "speech_volume":
			return 0.0;
		
		case "ui_cursor":
			return 0;
		
		case "ui_font_size":
			return 9;
		case "ui_font_size_talk":
			return 7;
		
		case "ui_font_style":
			return 0;
		
		case "mlgmode":
			return 0;
	}

	return null;


}
