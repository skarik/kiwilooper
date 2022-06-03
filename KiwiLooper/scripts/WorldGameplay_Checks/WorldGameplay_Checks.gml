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
