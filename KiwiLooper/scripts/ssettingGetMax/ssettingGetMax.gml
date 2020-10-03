/// @function ssettingGetMax(settingname)
/// @param settingname {Setting}
/// @returns Varied type, depending on result of ssettingGetType
function ssettingGetMax(argument0) {
	var settingname = argument0;

	switch (settingname)
	{
		case "total_volume":
		case "sfx_volume":
		case "music_volume":
		case "speech_volume":
			return  1.0;
		
		case "ui_cursor":
			return 2;
		
		case "ui_font_size":
			return 10;
		case "ui_font_size_talk":
			return 8;
		
		case "ui_font_style":
			return 0;
		
		case "mlgmode":
			return 1;
	}

	return null;


}
