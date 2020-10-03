function collision4_meeting(check_x, check_y, check_z)
{
	var x1 = check_x - sprite_get_xoffset(mask_index) + sprite_get_bbox_left(mask_index);
	var x2 = check_x - sprite_get_xoffset(mask_index) + sprite_get_bbox_right(mask_index);
	var y1 = check_y - sprite_get_yoffset(mask_index) + sprite_get_bbox_top(mask_index);
	var y2 = check_y - sprite_get_yoffset(mask_index) + sprite_get_bbox_bottom(mask_index);
	
	// Go to the tilemap, check the elevations
	if (iexists(o_tileset3DIze))
	{
		// Check for the tile collision at the given point (fast)
		var result_tile = max(
			o_tileset3DIze.m_heightMap.get(floor(x1 / 16), floor(y1 / 16)),
			o_tileset3DIze.m_heightMap.get(floor(x2 / 16), floor(y1 / 16)),
			o_tileset3DIze.m_heightMap.get(floor(x1 / 16), floor(y2 / 16)),
			o_tileset3DIze.m_heightMap.get(floor(x2 / 16), floor(y2 / 16))) * 16;
		
		// Check for all elevation spots
		var area_z_max = result_tile;
		// TODO: Handle bodies having higher election
		
		// Check against the highest Z
		if (area_z_max > check_z + 4)
		{
			return true;
		}
	}
	
	// No collision
	return false;
}