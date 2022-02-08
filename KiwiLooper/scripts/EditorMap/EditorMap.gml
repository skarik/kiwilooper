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

function ATilemap() constructor
{
	// An unordered array of all map tiles.
	tiles = [];
	// List of all used heights.
	usedHeights = [];
	
	static Clear = function()
	{
		tiles = [];
		usedHeights = [];
	}
	
	static AddTile = function(tile)
	{
		array_push(tiles, tile);
	}
	
	static DeleteTileIndex = function(tileIndex)
	{
		array_delete(tiles, tileIndex, 1); 
	}
	
	static GetPosition = function(x, y)
	{
		for (var tileIndex = 0; tileIndex < array_length(tiles); ++tileIndex)
		{
			var tileInfo = tiles[tileIndex];
			if (tileInfo.x == x && tileInfo.y == y)
			{
				return tileInfo;
			}
		}
		return null;
	}
	
	static GetPositionIndex = function(x, y)
	{
		for (var tileIndex = 0; tileIndex < array_length(tiles); ++tileIndex)
		{
			var tileInfo = tiles[tileIndex];
			if (tileInfo.x == x && tileInfo.y == y)
			{
				return tileIndex;
			}
		}
		return -1;
	}
	
	static HasPosition = function(x, y)
	{
		return is_struct(GetPosition(x, y));
	}
	
	static AddHeight = function(height)
	{
		if (!array_contains(usedHeights, height))
		{
			array_push(usedHeights, height);
		}
	}
	
	static RemoveHeightSlow = function(height)
	{
		for (var tileIndex = 0; tileIndex < array_length(tiles); ++tileIndex)
		{
			var tileInfo = tiles[tileIndex];
			if (tileInfo.height == height)
			{
				return;
			}
		}
		for (var heightIndex = 0; heightIndex < array_length(usedHeights); ++heightIndex)
		{
			if (usedHeights[heightIndex] == height)
			{
				array_delete(usedHeights, heightIndex, 1);
			}
		}
	}
}

function EditorTileMapSetup()
{
	m_tilemap = new ATilemap();
}