function string_width_spaced(argument0, argument1) {
	var dtext = argument0;
	var dpadding = argument1;

	var dalignment = draw_get_halign();
	draw_set_halign(fa_left);

	var l_renderString = dtext;
	var l_renderStringLength = string_length(l_renderString);
	var l_pixelWidth = string_width(l_renderString);
	var l_pixelLetterPadding = dpadding;
	var l_pixelWidthModded = l_pixelWidth + l_pixelLetterPadding * (l_renderStringLength - 1);

	draw_set_halign(dalignment);

	return l_pixelWidthModded;


}
