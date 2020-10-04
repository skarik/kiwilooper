#macro kMaxStepHeight 7

function collision4_get_highest(check_x, check_y, check_z)
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
		// Check all the corpses
		{
			var results_num = collision_rectangle_list(x1, y1, x2, y2, ob_usableCorpse, false, true, results, false);
			// Find the one with the highest Z
			for (var i = 0; i < results_num; ++i)
			{
				var corpse = results[|i];
				if (!corpse.onGround) continue;
				var area_z = corpse.z + corpse.height;
				area_z_max = max(area_z_max, area_z);
			}
			ds_list_clear(results);
		}

		// Done with results
		ds_list_destroy(results);
		
		return area_z_max;
	}
	
	return 0;
}

// Corpse special is specific checking for corpses. It's almost identical except for
// - thicker corpses
// - corpses above are ignored
function collision4_get_highest_corpseSpecial(check_x, check_y, check_z)
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
		// Check all the corpses
		{
			var results_num = collision_rectangle_list(x1, y1, x2, y2, ob_usableCorpse, false, true, results, false);
			// Find the one with the highest Z
			for (var i = 0; i < results_num; ++i)
			{
				var corpse = results[|i];
				if (!corpse.onGround) continue;
				if (onGround && corpse.z > z) continue; // Ignore bodies above
				var area_z = corpse.z + corpse.height + 2;
				area_z_max = max(area_z_max, area_z);
			}
			ds_list_clear(results);
		}

		// Done with results
		ds_list_destroy(results);
		
		return area_z_max;
	}
	
	return 0;
}

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
		// Check all the corpses
		{
			var results_num = collision_rectangle_list(x1, y1, x2, y2, ob_usableCorpse, false, true, results, false);
			// Find the one with the highest Z
			for (var i = 0; i < results_num; ++i)
			{
				var corpse = results[|i];
				if (!corpse.onGround) continue;
				var area_z = corpse.z + corpse.height;
				area_z_max = max(area_z_max, area_z);
			}
			ds_list_clear(results);
		}

		// Done with results
		ds_list_destroy(results);
		
		// Check against the highest Z
		if (area_z_max > check_z + kMaxStepHeight)
		{
			return true;
		}
	}
	
	// No collision
	return false;
}

/// @description collision4_line(x1, y1, z1, x2, y2, z2)
/// @param {Real} x1
/// @param {Real} y1
/// @param {Real} z1
/// @param {Real} x2
/// @param {Real} y2
/// @param {Real} z2
function collision4_line(check_x1, check_y1, check_z1, check_x2, check_y2, check_z2)
{
	// Go to the tilemap, check the elevations
	if (iexists(o_tileset3DIze))
	{
		var dx = check_x2 - check_x1;
		var dy = check_y2 - check_y1;
		var dz = check_z2 - check_z1;
	
		// Create the "slope" to step by when "rasterizing" the line
		var step_divisor = max(abs(dx), abs(dy), abs(dz));
		var mx = dx / step_divisor * 16.0;
		var my = dy / step_divisor * 16.0;
		var mz = dz / step_divisor * 16.0;
		
		// Initial sample position
		var sample_x = check_x1;
		var sample_y = check_y1;
		var sample_z = check_z1;
		var step_count = ceil(max(abs(dx / 16.0), abs(dy / 16.0), abs(dz / 16.0)));
		
		for (var i_step = 0; i_step < step_count; ++i_step)
		{
			var cel_x = floor(sample_x / 16);
			var cel_y = floor(sample_y / 16);
			
			var result_height = o_tileset3DIze.m_heightMap.get(cel_x, cel_y) * 16;
			
			if (result_height > sample_z + kMaxStepHeight)
			{
				return true;
			}
			
			// Go to next sample position
			sample_x += mx;
			sample_y += my;
			sample_z += mz;
		}
	}
	
	// TODO: Handle bodies & doors having higher elevation
	var results = ds_list_create();
	
	var check_xy_distance = point_distance(check_x1, check_y1, check_x2, check_y2);
	
	// Check all the doors
	{
		var results_num = collision_line_list(check_x1, check_y1, check_x2, check_y2, o_livelyDoor, false, true, results, false);
		// Find the one with the highest Z
		for (var i = 0; i < results_num; ++i)
		{
			var door = results[|i];
			var area_z = door.z + door.doorheight;
			
			// Get rough z for this
			var check_z = lerp(check_z1, check_z2, point_distance(check_x1, check_y1, door.x, door.y) / check_xy_distance);
			
			// Check against rough Z
			if (area_z > check_z + kMaxStepHeight)
			{
				ds_list_destroy(results);
				return true;
			}
		}
		ds_list_clear(results);
	}

	// Done with results
	ds_list_destroy(results);
	
	// No collision
	return false;
}