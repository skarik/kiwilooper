/// @description draw_text_spaced(x, y, text, padding)
/// @param x
/// @param y
/// @param text
/// @param padding
/// @returns Last width used to draw.
function draw_text_spaced(argument0, argument1, argument2, argument3) {
	var dx = argument0;
	var dy = argument1;
	var dtext = argument2;
	var dpadding = argument3;

	var dalignment = draw_get_halign();
	draw_set_halign(fa_left);

	var l_renderString = dtext;
	var l_renderStringLength = string_length(l_renderString);
	var l_pixelWidth = string_width(l_renderString);
	var l_pixelLetterPadding = dpadding;
	var l_pixelWidthModded = l_pixelWidth + l_pixelLetterPadding * (l_renderStringLength - 1);
	var l_pixelHalfWidthCenter = floor((l_pixelWidthModded + string_length("m")) * 0.5);
	var l_penX = 0;

	if (dalignment == fa_left)
	{
		for (var i = 1; i <= l_renderStringLength; ++i)
		{
			var l_character = string_char_at(l_renderString, i);
			draw_text(dx + l_penX, dy, l_character);
			l_penX += ceil(string_width(l_character) + l_pixelLetterPadding);
		}
	}
	else if (dalignment == fa_center)
	{
		for (var i = 1; i <= l_renderStringLength; ++i)
		{
			var l_character = string_char_at(l_renderString, i);
			draw_text(dx - l_pixelHalfWidthCenter + l_penX, dy, l_character);
			l_penX += ceil(string_width(l_character) + l_pixelLetterPadding);
		}
	}
	else if (dalignment == fa_right)
	{
		for (var i = 1; i <= l_renderStringLength; ++i)
		{
			var l_character = string_char_at(l_renderString, i);
			draw_text(dx - l_pixelWidthModded + l_penX, dy, l_character);
			l_penX += ceil(string_width(l_character) + l_pixelLetterPadding);
		}
	}

	draw_set_halign(dalignment);

	return l_penX;


}
