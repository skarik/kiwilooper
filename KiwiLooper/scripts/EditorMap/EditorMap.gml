/// @function AMapTile() constructor
/// @notes A map tile that represents a filled tile in the map.
function AMapTile() constructor
{
	// Default floor tile. No special rules.
	floorType = 1;
	// Default wall tile. Walls use themselves for the bottom, then themselves-32 for their top.
	wallType = 37;
	// 16 block height. Default is 0, room outer floor default is -1.
	height = 0;
	
	x = 0;
	y = 0;
}