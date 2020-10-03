/// @function ssettingGetEnumName(settingname, enumvalue)
/// @param settingname {Setting}
/// @param enumvalue {Real}
/// @returns String
function ssettingGetEnumName(argument0, argument1) {
	var settingname = argument0;
	var enumvalue = argument1;

	switch (settingname)
	{
		case "ui_cursor":
			if (enumvalue == 0)
				return "Regular";
			else if (enumvalue == 1)
				return "Line to";
			else if (enumvalue == 2)
				return "Minimal";
			break;
		
		case "ui_font_size":
		case "ui_font_size_talk":
			return string(enumvalue);
		
		case "ui_font_style":
			if (enumvalue == 0)
				return "Default";
			break;
		
		case "mlgmode":
			return enumvalue ? "On" : "Off";
	}

	return null;


}
