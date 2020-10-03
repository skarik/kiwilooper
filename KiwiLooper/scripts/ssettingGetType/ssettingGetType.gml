/// @function ssettingGetType(settingname)
/// @param settingname {Setting}
/// @returns kSettingType
function ssettingGetType(argument0) {
#macro kSettingTypeFloat	0
#macro kSettingTypeBoolean	1
#macro kSettingTypeControl	2
#macro kSettingTypeEnum		3
#macro kSettingTypeUnknown	null

	var settingname = argument0;

	if (is_array(controlSettingGet(settingname)))
		return kSettingTypeControl;

	switch (settingname)
	{
		case "total_volume":
		case "sfx_volume":
		case "music_volume":
		case "speech_volume":
			return kSettingTypeFloat;
		
		case "blood":
			return kSettingTypeBoolean;
	
		case "autoaim_item":
		case "autoaim_weapon":
			return kSettingTypeBoolean;
		
		case "ui_cursor":
			return kSettingTypeEnum;
		case "ui_font_size":
		case "ui_font_size_talk":
			return kSettingTypeEnum;
		case "ui_font_style":
			return kSettingTypeEnum;
		
		case "mlgmode":
			return kSettingTypeEnum;
	}

	return kSettingTypeUnknown;


}
