gpu_set_blendenable(true);
gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_alpha);

var alpha = duiGetAlphaGlobal();

with (ob_colliderNoDepth)
{
	draw_sprite_ext(
		sprite_exists(mask_index) ? mask_index : sprite_index,
		image_index,
		x, y,
		image_xscale, image_yscale, image_angle,
		c_white, alpha * 0.5);
}
with (ob_colliderDepth)
{
	draw_sprite_ext(
		sprite_exists(mask_index) ? mask_index : sprite_index,
		image_index,
		x, y,
		image_xscale, image_yscale, image_angle,
		c_white, alpha * 0.5);
}

with (ob_elevationArea)
{
	if (z == o_PlayerTest.z)
	{
		draw_sprite_ext(
			sprite_exists(mask_index) ? mask_index : sprite_index,
			image_index,
			x, y,
			image_xscale, image_yscale, image_angle,
			c_white, alpha * 0.5);
	}
	else
	{
		draw_sprite_ext(
			sprite_exists(mask_index) ? mask_index : sprite_index,
			image_index,
			x, y,
			image_xscale, image_yscale, image_angle,
			c_gray, alpha * 0.5);
	}
}

with (o_PlayerTest)
{
	draw_sprite_ext(
		sprite_exists(mask_index) ? mask_index : sprite_index,
		image_index,
		x, y,
		image_xscale, image_yscale, image_angle,
		c_white, alpha * 0.5);
}

draw_set_alpha(alpha * 0.3);
draw_set_color(c_black);
draw_set_font(f_04b03);
with (ob_doodad)
{
	draw_set_valign(fa_top);
	draw_set_halign(fa_right);
	draw_text(x + 4, y + 2, "#" + string(index));
	draw_text(x + 4, y + 8, "z:" + string(z) + "+" + string(z_height));
}
/*draw_set_alpha(alpha * 0.3);
draw_set_color(c_white);
draw_set_font(f_04b03);
with (ob_colliderDepth)
{
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
	draw_text(x, y - 8, "z:" + string(z));
}*/

draw_set_alpha(alpha * 1.0);
paletteDebugDisplay();

// draw the cameras
draw_set_alpha(alpha * 0.5);
draw_set_color(c_lime);
with (GameCamera)
{
	draw_rectangle(
		view_x + 8,
		view_y + 8,
		view_x + width - 8,
		view_y + height - 8,
		true);
}