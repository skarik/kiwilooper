#macro kGameLoadingInvalid 0
#macro kGameLoadingFromGMS 1
#macro kGameLoadingFromDisk 2

/// @function Game_LoadMap( map, [asEditor = false] )
/// @desc Load the given map or room.
function Game_LoadMap( map, asEditor = false )
{
	global.game_editorRun = asEditor;
	
	if (is_string(map))
	{
		global.game_loadingInfo = kGameLoadingFromDisk;
		global.game_loadingMap = map;
		room_goto(rm_EmptyMap);
	}
	else if (room_exists(map))
	{
		global.game_loadingInfo = kGameLoadingFromGMS;
		room_goto(map);
	}
	else
	{
		global.game_loadingInfo = kGameLoadingInvalid;
		room_goto(rm_EmptyMap);
	}
}

/// @function Game_Event_RoomStart()
function Game_Event_RoomStart()
{
	// Load up all the room info
	_Game_LoadMapInternal();

	// Create gameplay
	if (!iexists(Gameplay))
		inew(Gameplay);
}

// Call by object `Game` in Room Start event.
function _Game_LoadMapInternal()
{
	if (global.game_loadingInfo != kGameLoadingFromDisk)
	{
		return;
	}
	
	// Load in the map
	var filedata = MapLoadFiledata(global.game_loadingMap);
	
	// Load in the tiles first:
	{
		var tilemap = new ATilemap();
		MapLoadTilemap(filedata, tilemap);
		
	}
	
	
	MapLoadProps(filedata, EditorGet().m_propmap);
	MapLoadEntities(filedata, EditorGet().m_entityInstList);
	
	MapFreeFiledata(filedata);
	delete filedata;
	
}