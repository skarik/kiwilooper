#macro kGameLoadingNone 0
#macro kGameLoadingFromGMS 1
#macro kGameLoadingFromDisk 2
#macro kGameLoadingInvalid 3

/// @function Game_GetMapId()
/// @desc Generates map ID based on current map information
function Game_GetMapId()
{
	if (is_string(global.game_loadingMap))
	{
		return global.game_loadingMap;
	}
	else if (room_exists(room) && room != rm_EmptyMap)
	{
		return room_get_name(room);
	}
	return undefined;
}

/// @function Game_LoadMap( map, [asEditor = false] )
/// @desc Load the given map or room.
function Game_LoadMap( map, asEditor = false )
{
	global.game_editorRun = asEditor;
	
	PersistentStateRoomEnd(Game_GetMapId());
	
	if (is_undefined(map))
	{
		global.game_loadingInfo = kGameLoadingInvalid;
		room_goto(rm_EmptyMap);
	}
	else if (is_string(map))
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

/// @function Game_AdvanceMap( map )
function Game_AdvanceMap( map )
{
	if (map == null)
	{
		if (room_last != room)
		{
			global.game_loadingInfo = kGameLoadingFromGMS;
			room_goto_next();
		}
		else
		{
			global.game_loadingInfo = kGameLoadingInvalid;
			room_goto(rm_EmptyMap);
		}
	}
	else
	{
		Game_LoadMap(map);
	}
}

/// @function Game_Event_RoomStart()
function Game_Event_RoomStart()
{
	// Create gameplay
	if (!iexists(Gameplay))
		inew(Gameplay);
	
	// Clear out persistence
	PersistentStateRoomStart(Game_GetMapId());
	
	// Load up all the room info
	_Game_LoadMapInternal();
	
	// Create editor info
	if (global.game_editorRun)
	{
		if (!iexists(o_Editor_InGameplayInfo))
			inew(o_Editor_InGameplayInfo);
			
		// Also, reset the cameras
		with (o_Camera3D)
		{
			event_perform(ev_create, 0);
		}
	}
		
	// If NOT loading from disk, perform callbacks on objects
	if (global.game_loadingInfo == kGameLoadingFromGMS)
	{
		with (all)
		{
			if (variable_instance_exists(id, "onPostLevelLoad"))
			{
				// Perform post-level load
				var executor = inew(_execute_step);
				with (executor)
				{
					fn = function()
					{
						target.onPostLevelLoad();
					};
				}
				executor.target = entInstance;
			}
		}
	}
}

// Call by object `Game` in Room Start event.
function _Game_LoadMapInternal()
{
	static ShowFailureMessage = function(extra_text="")
	{
		// Pop up the "invalid info" UI bit
		var uis_info = inew(o_uisScriptable);
		uis_info.extra_text = extra_text;
		uis_info.m_renderEvent = method(uis_info, function()
		{
			draw_set_alpha(1.0);
			draw_set_color(c_white);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_font(f_04b03);
			draw_text(GameCamera.width / 2, GameCamera.height / 2, "NO LEVEL LOADED"+extra_text);
		});
	}
	
	if (global.game_loadingInfo == kGameLoadingInvalid)
	{
		ShowFailureMessage();
	}
	
	if (global.game_loadingInfo != kGameLoadingFromDisk)
	{
		return;
	}
	
	// Load in the map
	var filedata = MapLoadFiledata(global.game_loadingMap);
	if (filedata == null)
	{
		ShowFailureMessage("\ncould not load \"" + global.game_loadingMap + "\"");
		return;
	}
	
	
	// Load in tiles to check the map version
	var bHasTilemap = false;
	var tilemap = new ATilemap();
	{
		MapLoadTilemap(filedata, tilemap);
		
		// Do we have a tilemap?
		bHasTilemap = array_length(tilemap.tiles) > 0;
	}
	
	if (bHasTilemap)
	{
		// Load in tiles
		{
			tilemap.BuildLayers(null);
		}
		
		// Load in props
		{
			var propmap = new APropMap();
			MapLoadProps(filedata, propmap);
		
			propmap.RebuildPropLayer(null);
		}
	
		// W/ props & ents ready, start 3d-ify chain
		if (!iexists(o_tileset3DIze) || !iexists(global.tiles_main)) ///global.tiles_main is defined in collision, should be cleaned up
		{
			// Create the 3d-ify chain
			global.tiles_main = null;
			inew(o_tileset3DIze);
		}
	}
	else
	{
		// Load in geometry
		{
			var geometry = new AMapGeometry();
			MapLoadGeometry(filedata, geometry);
			
			// Create manager with the geometry
			var geo_render = inew(o_geometry3DIze);
			geo_render.SetGeometry(geometry);
			geo_render.Initialize();
		}
		
		// Load in props
		{
			var propmap = new APropMap();
			MapLoadProps(filedata, propmap);
			
			// Create the prop renderer with the propmap
			var props = inew(o_props3DIze2);
			props.SetMap(propmap);
			props.BuildMesh();
		}
		
		// Set up collision info
		global.tiles_main = null;
		global.geometry_main = instance_find(o_geometry3DIze, 0);
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
						// TODO: Is this needed here?
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
					// check the type - if it's a lively, we need to loop through all the current instances and find the matching one to replace the value
					else if (property[1] == kValueTypeLively)
					{
						for (var entSearchIndex = 0; entSearchIndex < entlist.GetEntityCount(); ++entSearchIndex)
						{
							var entSearchInstance = entlist.GetEntity(entSearchIndex);
							var entSearch = entSearchInstance.entity;
							
							var targetname = variable_instance_get(entSearchInstance, "targetname");
							if (!is_undefined(targetname))
							{
								if (targetname == variable_instance_get(entInstance, property[0]))
								{
									variable_instance_set(entInstance, property[0], entSearchInstance);
									array_push(saved_property_info, [property[0], entSearchInstance]);
									break; // Found!
								}
							}
						}
					}
					// all other types of variables just get copied over naiively
					else
					{
						array_push(saved_property_info, [property[0], variable_instance_get(entInstance, property[0])]);
					}
				}
				
				// Change the instance
				{
					// Make final instance
					var entReplacement = inew(ent.objectIndex);
					
					// Copy over system values
					entReplacement.entity = entInstance.entity;
					entReplacement.entityMapIndex = entInstance.entityMapIndex;
					
					// Finish replacement & delete old
					idelete(entInstance);
					entlist.ReplaceEntity(entIndex, entReplacement);
					entInstance = entReplacement;
				}
				
				// Copy all saved properties over
				for (var propIndex = 0; propIndex < array_length(saved_property_info); ++propIndex)
				{
					var property_name = saved_property_info[propIndex][0];
					var property_value = saved_property_info[propIndex][1];
								
					variable_instance_set(entInstance, property_name, property_value);
				}
				
				// Load in persistence information
				PersistentStateApply(entInstance);
							
				// Perform post-level-load
				if (iexists(entInstance)) // Persistence apply could destroy this instance.
				{
					if (variable_instance_exists(entInstance, "onPostLevelLoad"))
					{
						//entInstance.onPostLevelLoad();
						executeNextStep(method(entInstance, entInstance.onPostLevelLoad), entInstance);
					}
				}
			}
			// No proxy, we set the properties directly so we're OK.
			else
			{
				// Load in persistence information
				PersistentStateApply(entInstance);
				
				// Perform post-level-load 
				if (iexists(entInstance)) // Persistence apply could destroy this instance.
				{
					if (variable_instance_exists(entInstance, "onPostLevelLoad"))
					{
						//entInstance.onPostLevelLoad();
						executeNextStep(method(entInstance, entInstance.onPostLevelLoad), entInstance);
					}
				}
			}
		}
		
		// Update the transform heirarchy listing
		Parenting_BuildHeirarchy(entlist);
		if (Parenting_NeedsPerStepUpdate())
		{
			// Create the parenting updater
			inew(GameParentingUpdater);
		}
	}
	
	// Load in splats
	{
		var splatmap = new ASplatMap();
		MapLoadSplats(filedata, splatmap);
		
		splatmap.SpawnSplats();
	}
	
	MapFreeFiledata(filedata);
	delete filedata;
}

/// @function Game_Event_Cleanup()
function Game_Event_Cleanup()
{
	PersistentStateGameFree();
}

//=============================================================================

///@function function Game_LoadEditor(fromTestSession)
function Game_LoadEditor(fromTestSession)
{
	// Destroy world renderers
	idelete(o_tileset3DIze);
	idelete(o_props3DIze);
	// Destroy world renderers v2
	idelete(o_geometry3DIze);
	idelete(o_props3DIze2);
	// Destroy all splatters for good measure
	idelete(ob_splatter);
	// Destroy all effects
	idelete(ob_environmentEffect);
	
	// Destroy all characters
	idelete(ob_character);
	
	// Destroy gameplay now
	idelete(Gameplay);
	
	// Destroy all UI
	idelete(ob_userInterfaceElement); // This should be OK with callee's
	
	// Kill leaking audio
	idelete(ob_audioAmbient);
	idelete(ob_audioPlayer);
	
	// Mark we're no longer loading anything
	global.game_editorRun = false;
	global.game_loadingInfo = kGameLoadingNone;
	global.game_loadingMap = "";
	
	// Return to the editor, the state of it should stay saved
	room_goto(rm_EditorLevel);
}