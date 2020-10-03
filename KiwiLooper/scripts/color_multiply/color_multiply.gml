function color_multiply(argument0, argument1) {
	var col0 = argument0;
	var col1 = argument1;

	var col0_r = color_get_red(col0) / 255.0;
	var col0_g = color_get_green(col0) / 255.0;
	var col0_b = color_get_blue(col0) / 255.0;

	var col1_r = color_get_red(col1) / 255.0;
	var col1_g = color_get_green(col1) / 255.0;
	var col1_b = color_get_blue(col1) / 255.0;

	var colf_r = col0_r * col1_r;
	var colf_g = col0_g * col1_g;
	var colf_b = col0_b * col1_b;

	return make_color_rgb(colf_r * 255.0, colf_g * 255.0, colf_b * 255.0);


}
