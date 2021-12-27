/// @function DrawSpriteRectangle(x1, y1, x2, y2, outline)
function DrawSpriteRectangle(x1, y1, x2, y2, outline)
{
	if (outline)
	{
		draw_sprite_ext(sfx_square, 0, (x1 + x2) * 0.5, y1 + 0.5, (x2 - x1) * 0.5, 0.5, 0.0, draw_get_color(), draw_get_alpha());
		draw_sprite_ext(sfx_square, 0, (x1 + x2) * 0.5, y2 - 0.5, (x2 - x1) * 0.5, 0.5, 0.0, draw_get_color(), draw_get_alpha());
		draw_sprite_ext(sfx_square, 0, x1 + 0.5, (y1 + y2) * 0.5, 0.5, (y2 - y1 - 2) * 0.5, 0.0, draw_get_color(), draw_get_alpha());
		draw_sprite_ext(sfx_square, 0, x2 - 0.5, (y1 + y2) * 0.5, 0.5, (y2 - y1 - 2) * 0.5, 0.0, draw_get_color(), draw_get_alpha());
	}
	else
	{
		draw_sprite_ext(sfx_square, 0, (x1 + x2) * 0.5, (y1 + y2) * 0.5, (x2 - x1) * 0.5, (y2 - y1) * 0.5, 0.0, draw_get_color(), draw_get_alpha());
	}
}

/// @function DrawSpriteLine(x1, y1, x2, y2)
function DrawSpriteLine(x1, y1, x2, y2)
{
	var dir = point_direction(x1, y1, x2, y2);
	var dist = point_distance(x1, y1, x2, y2);
	
	draw_sprite_ext(sfx_square, 0, (x1 + x2) * 0.5 + 0.5, (y1 + y2) * 0.5 + 0.5, (dist + 2) * 0.5, 0.5, dir, draw_get_color(), draw_get_alpha());
}