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
	
	// Load in tiles
	{
		var tilemap = new ATilemap();
		MapLoadTilemap(filedata, tilemap);
		
		tilemap.BuildLayers(null);
	}
	
	// Load in props
	{
		var propmap = new APropMap();
		MapLoadProps(filedata, propmap);
		
		propmap.RebuildPropLayer(null);
	}
	
	// W/ props & ents ready, start 3d-ify chain
	{
		// Create the 3d-ify chain
		inew(o_tileset3DIze);
	}
	
	// Load in ents:
	{
		var entlist = new AEntityList();
		MapLoadEntities(filedata, entlist);
		
		// Loop through all items in the ent & transform them out of proxies
		for (var entIndex = 0; entIndex < entlist.GetEntityCount(); ++entIndex)
		{
			var entInstance = entlist.GetEntity(entIndex);
			var ent = entInstance.entity;
			
			if (ent.proxy != kProxyTypeNone)
			{
				// Since the create event can overwrite some variables, save all the instance values
				var saved_property_info = [];
				for (var propIndex = 0; propIndex < array_length(ent.properties); ++propIndex)
				{
					var property = ent.properties[propIndex];
					var bSpecialTransform = entpropIsSpecialTransform(property);
					
					if (bSpecialTransform)
					{
						if (property[1] == kValueTypePosition)
						{
							array_push(saved_property_info, ["x", entInstance.x]);
							array_push(saved_property_info, ["y", entInstance.y]);
							array_push(saved_property_info, ["z", entInstance.z]);
						}
						else if (property[1] == kValueTypeRotation)
						{
							array_push(saved_property_info, ["xrotation", entInstance.xrotation]);
							array_push(saved_property_info, ["yrotation", entInstance.yrotation]);
							array_push(saved_property_info, ["zrotation", entInstance.zrotation]);
						}
						else if (property[1] == kValueTypeScale)
						{
							array_push(saved_property_info, ["xscale", entInstance.xscale]);
							array_push(saved_property_info, ["yscale", entInstance.yscale]);
							array_push(saved_property_info, ["zscale", entInstance.zscale]);
						}
					}
					else
					{
						array_push(saved_property_info, [property[0], variable_instance_get(entInstance, property[0])]);
					}
				}
				
				// Change the instance
				with (entInstance)
				{
					instance_change(ent.objectIndex, true);
				}
				
				// Update the saved values now, now that the object has been initialized
				// (TODO: this may be a non-issue, experiment in the future)
				//for (var propIndex = 0; propIndex < saved_propertyInfo
				// This will not work, the object's create event is NOT called on the instance_change call.
			}
		}
	}
	
	MapFreeFiledata(filedata);
	delete filedata;
}