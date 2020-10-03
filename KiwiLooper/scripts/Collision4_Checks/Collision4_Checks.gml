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
		
		// TODO: Handle bodies & doors having higher elevation
		var results = ds_list_create();
		
		// Check all the doors
		{
			var results_num = collision_rectangle_list(x1, y1, x2, y2, o_livelyDoor, false, true, results, false);
			// Find the one with the highest Z
			for (var i = 0; i < results_num; ++i)
			{
				var door = results[|i];
				var area_z = door.z + door.doorheight;
				area_z_max = max(area_z_max, area_z);
			}
			ds_list_clear(results);
		}

		// Done with results
		ds_list_destroy(results);
		
		// Check against the highest Z
		if (area_z_max > check_z + 4)
		{
			return true;
		}
	}
	
	// No collision
	return false;
}