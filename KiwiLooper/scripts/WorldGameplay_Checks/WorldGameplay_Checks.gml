#macro kWorldSideFloor			0x01
#macro kWorldSideWall			0x02
#macro kWorldSideFloorAndWall	0x03

/// @function World_ShockAtPosition(x, y, z, checkSide=kWorldSideFloorAndWall)
/// @param x {Real}
/// @param y {Real}
/// @param z {Real}
/// @param checkSide {kWorldSide}
/// @desc Checks for shocking items. Should not be called every frame, due to slow speeds.
function World_ShockAtPosition(x, y, z, checkSide=kWorldSideFloorAndWall)
{
	if (checkSide & kWorldSideFloor)
	{
		//var wires = collision_rectangle(x - 4, y - 4, x + 4, y + 4, o_livelyExplodingWires, false, true);
		var wires = collision_point(x, y, o_livelyExplodingWires, false, true);
		if (iexists(wires) && abs(z - wires.z) < 16)
		{
			return true;
		}
		else if (iexists(o_livelyRoomState) && o_livelyRoomState.powered
			&& collision4_get_groundtype(x, y, z) == kGroundType_Tileset
			&& collision4_get_tileextra(x, y) == kTileExtras_Shock)
		{
			return true;
		}
	}
	
	return false;
}

/// @function World_WaterAtPosition(x, y, z)
/// @param x {Real}
/// @param y {Real}
/// @param z {Real}
/// @desc Checks if the given position is inside water.
function World_WaterAtPosition(x, y, z)
{
	var waterCount = instance_number(o_livelyWater);
	for (var waterIndex = 0; waterIndex < waterCount; ++waterIndex)
	{
		var waterBody = instance_find(o_livelyWater, waterIndex);
		
		if (x >= waterBody.x - xscale * 0.5 && x <= waterBody.x + xscale * 0.5
			&& y >= waterBody.y - yscale * 0.5 && y <= waterBody.y + yscale * 0.5
			&& z >= waterBody.z - zscale * 0.5 && z <= waterBody.z + zscale * 0.5)
		{
			return true;
		}
	}
	return false;
}

/// @function World_WaterBelowPosition(x, y, z)
/// @param x {Real}
/// @param y {Real}
/// @param z {Real}
/// @desc Checks if the given position is over water.
function World_WaterBelowPosition(x, y, z)
{
	var waterCount = instance_number(o_livelyWater);
	for (var waterIndex = 0; waterIndex < waterCount; ++waterIndex)
	{
		var waterBody = instance_find(o_livelyWater, waterIndex);
		
		if (x >= waterBody.x - xscale * 0.5 && x <= waterBody.x + xscale * 0.5
			&& y >= waterBody.y - yscale * 0.5 && y <= waterBody.y + yscale * 0.5)
		{
			var z_bot = waterBody.z - zscale * 0.5;
			if (z >= z_bot)
			{
				return true;
			}
		}
	}
	return false;
}

/// @function World_WaterBelowDistance(x, y, z)
/// @param x {Real}
/// @param y {Real}
/// @param z {Real}
/// @desc Checks if the given position is over water, and if it is, calculates shortest distance. If no water, returns <0.
function World_WaterBelowDistance(x, y, z)
{
	var min_dist = -1;
	var waterCount = instance_number(o_livelyWater);
	for (var waterIndex = 0; waterIndex < waterCount; ++waterIndex)
	{
		var waterBody = instance_find(o_livelyWater, waterIndex);
		
		if (x >= waterBody.x - xscale * 0.5 && x <= waterBody.x + xscale * 0.5
			&& y >= waterBody.y - yscale * 0.5 && y <= waterBody.y + yscale * 0.5)
		{
			var z_bot = waterBody.z - zscale * 0.5;
			if (z > z_bot)
			{
				var z_top = waterBody.z + zscale * 0.5;
				var dist = max(0, z - z_top);
				if (min_dist == -1 || dist < min_dist)
				{
					min_dist = dist;
				}
			}
		}
	}
	return min_dist;
}