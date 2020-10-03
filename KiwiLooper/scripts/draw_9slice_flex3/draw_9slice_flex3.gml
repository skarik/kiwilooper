/// @function draw_9slice_flex(x, y, width, height, sprite, h_width, v_width)
/// @param x
/// @param y
/// @param width
/// @param height
/// @param sprite
/// @param h_width
/// @param v_width
function draw_9slice_flex3(argument0, argument1, argument2, argument3, argument4, argument5, argument6) {

	var dx = argument0;
	var dy = argument1;
	var dwidth = argument2;
	var dheight = argument3;
	var sprite = argument4;
	var h_width = argument5;
	var v_width = argument6;
	var alpha = draw_get_alpha();

	// get full sprite size
	var spr_width = sprite_get_width(sprite);
	var spr_height = sprite_get_height(sprite);

	var spr_width_sub_margin = spr_width - h_width * 2.0;
	var spr_height_sub_margin = spr_height - v_width * 2.0;

	// Draw center:
	draw_sprite_part_ext(sprite, 1,
						 h_width,
						 0,
						 spr_width_sub_margin,
						 spr_height,
						 dx + h_width,
						 dy + v_width,
						 (dwidth - h_width * 2.0) / spr_width_sub_margin,
						 (dheight - v_width * 2.0) / spr_height,
						 c_white, alpha);

	// Draw edges:
	// top center
	draw_sprite_part_ext(sprite, 0,
						 h_width,
						 0,
						 spr_width_sub_margin,
						 v_width,
						 dx + h_width,
						 dy,
						 (dwidth - h_width * 2.0) / spr_width_sub_margin,
						 1.0,
						 c_white, alpha);
					 
	// bottom center
	draw_sprite_part_ext(sprite, 2,
						 h_width,
						 spr_height - v_width,
						 spr_width_sub_margin,
						 v_width,
						 dx + h_width,
						 dy + dheight - v_width,
						 (dwidth - h_width * 2.0) / spr_width_sub_margin,
						 1.0,
						 c_white, alpha);
					 
	// left center
	draw_sprite_part_ext(sprite, 1,
						 0,
						 0,
						 h_width,
						 spr_height,
						 dx,
						 dy + v_width,
						 1.0,
						 (dheight - v_width * 2.0) / spr_height,
						 c_white, alpha);
					 
	// right center
	draw_sprite_part_ext(sprite, 1,
						 spr_width - h_width,
						 0,
						 h_width,
						 spr_height,
						 dx + dwidth - h_width,
						 dy + v_width,
						 1.0,
						 (dheight - v_width * 2.0) / spr_height,
						 c_white, alpha);

	// Draw corners:
	// top left
	draw_sprite_part_ext(sprite, 0,
						 0,
						 0,
						 h_width,
						 v_width,
						 dx,
						 dy,
						 1.0,
						 1.0,
						 c_white, alpha);
	// top right
	draw_sprite_part_ext(sprite, 0,
						 spr_width - h_width,
						 0,
						 h_width,
						 v_width,
						 dx + dwidth - h_width,
						 dy,
						 1.0,
						 1.0,
						 c_white, alpha);
	// bottom left
	draw_sprite_part_ext(sprite, 2,
						 0,
						 spr_height - v_width,
						 h_width,
						 v_width,
						 dx,
						 dy + dheight - v_width,
						 1.0,
						 1.0,
						 c_white, alpha);
	// bottom right
	draw_sprite_part_ext(sprite, 2,
						 spr_width - h_width,
						 spr_height - v_width,
						 h_width,
						 v_width,
						 dx + dwidth - h_width,
						 dy + dheight - v_width,
						 1.0,
						 1.0,
						 c_white, alpha);


}
