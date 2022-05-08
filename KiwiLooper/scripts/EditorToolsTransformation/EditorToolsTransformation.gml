/// @function AEditorToolStateTranslate() constructor
function AEditorToolStateTranslate() : AEditorToolStateSelect() constructor
{
	state = kEditorToolTranslate;
	
	Parent_onBegin = onBegin;
	Parent_onEnd = onEnd;
	Parent_onStep = onStep;
	Parent_onClickWorld = onClickWorld;
	
	m_transformGizmoConsumingMouse = false;
	m_transformGizmoWasConsumingMouse = false;
	m_previousTarget = null;
	
	m_dragWorldStart = new Vector3(0, 0, 0);
	
	onBegin = function()
	{
		Parent_onBegin();
		
		m_transformGizmo = m_editor.EditorGizmoGet(AEditorGizmoPointMove);
		m_transformGizmo.SetInvisible();
		m_transformGizmo.SetDisabled();
		
		m_editor.m_statusbar.m_toolHelpText = "Click to select objects. Use gizmo to move along an axis. Hold Alt to toggle snapping.";
	};
	onEnd = function(trueEnd)
	{
		Parent_onEnd(trueEnd);
		if (trueEnd)
		{
			m_transformGizmo.SetInvisible();
			m_transformGizmo.SetDisabled();
		}
		
		m_editor.toolGridTemporaryDisable = false; // Reset states
	};
	
	m_haveTileSelectionState = false;
	m_haveTileSelectionGhost = false;
	m_tileSelectionGhostTilemap = null;
	m_tileSelectionGhostRenderer = null;
	
	/// @function BeginTileSelection()
	BeginTileSelection = function()
	{
		if (!m_haveTileSelectionState)
		{
			m_haveTileSelectionState = true;
			m_haveTileSelectionGhost = false;
		}
	}
	/// @function EndTileSelection()
	EndTileSelection = function()
	{
		if (m_haveTileSelectionState)
		{
			// Clear up state
			m_haveTileSelectionState = false;
			
			// Clear up ghost
			if (m_haveTileSelectionGhost)
			{
				m_haveTileSelectionGhost = false;
				
				if (is_struct(m_tileSelectionGhostTilemap))
				{
					// TODO: confirm before we lose geo
					delete m_tileSelectionGhostTilemap;
					m_tileSelectionGhostTilemap = null;
				}
			
				if (iexists(m_tileSelectionGhostRenderer))
				{
					idelete(m_haveTileSelectionGhost);
					m_haveTileSelectionGhost = null;
				}
			}
		}
	}
	
	onStep = function()
	{
		// Keyboard "no-snap" override toggle
		m_editor.toolGridTemporaryDisable = keyboard_check(vk_alt);
		
		var bIsValidSelection = array_length(m_editor.m_selection) > 0;
		var bIsObjectSelection = bIsValidSelection;
		if (bIsValidSelection)
		{
			if (is_struct(m_editor.m_selection[0]))
			{
				if (m_editor.m_selection[0].type == kEditorSelection_Tile
					|| m_editor.m_selection[0].type == kEditorSelection_TileFace
					|| m_editor.m_selection[0].type == kEditorSelection_Voxel
					|| m_editor.m_selection[0].type == kEditorSelection_VoxelFace)
				{
					bIsObjectSelection = false;
				}
			}
		}
		var bIsTileSelection = !bIsObjectSelection && bIsValidSelection;
		
		if (bIsObjectSelection)
		{
			if (m_haveTileSelectionState)
			{
				EndTileSelection();
			}
			
			// Gather transform target first
			var target = m_editor.m_selection[0];
			var target_type = kEditorSelection_None;
			if (is_struct(m_editor.m_selection[0]))
			{
				if (m_editor.m_selection[0].type == kEditorSelection_Prop)
				{
					target = m_editor.m_selection[0].object;
					target_type = kEditorSelection_Prop;
				}
				else if (m_editor.m_selection[0].type == kEditorSelection_Splat)
				{
					target = m_editor.m_selection[0].object;
					target_type = kEditorSelection_Splat;
				}
			}
			
			// If the gizmo is not set up, then we set up initial gizmo position & reference position.
			if (!m_transformGizmo.m_enabled || m_previousTarget != target)
			{
				m_transformGizmo.SetVisible();
				m_transformGizmo.SetEnabled();
		
				m_transformGizmo.x = target.x;
				m_transformGizmo.y = target.y;
				m_transformGizmo.z = target.z;
				
				m_previousTarget = target;
			}
			// If the gizmo IS set up, then we update the selected objects' positions to the gizmo translation.
			else
			{
				var snap = m_editor.toolGrid && !m_editor.toolGridTemporaryDisable;
				var next_x = m_transformGizmo.m_dragX ? (snap ? round_nearest(m_transformGizmo.x, m_editor.toolGridSize) : m_transformGizmo.x) : target.x;
				var next_y = m_transformGizmo.m_dragY ? (snap ? round_nearest(m_transformGizmo.y, m_editor.toolGridSize) : m_transformGizmo.y) : target.y;
				var next_z = m_transformGizmo.m_dragZ ? (snap ? round_nearest(m_transformGizmo.z, m_editor.toolGridSize) : m_transformGizmo.z) : target.z;
				
				var bSignalChange = 
						target.x != next_x
					|| target.y != next_y
					|| target.z != next_z;
				
				target.x = next_x;
				target.y = next_y;
				target.z = next_z;
				
				if (bSignalChange)
				{
					EditorGlobalSignalTransformChange(target, target_type);
				}
			}
		}
		// Tile-based selection:
		else if (bIsTileSelection)
		{
			if (!m_haveTileSelectionState)
			{
				BeginTileSelection();
			}
			
			// Gather transform target first
			var tile = m_editor.m_selection[0];
			var target_type = kEditorSelection_None;
			if (m_editor.m_selection[0].type == kEditorSelection_Tile)
			{
				tile = m_editor.m_selection[0].object;
				target_type = kEditorSelection_Tile;
			}
			else if (m_editor.m_selection[0].type == kEditorSelection_TileFace)
			{
				tile = m_editor.m_selection[0].object.tile;
				target_type = kEditorSelection_Tile;
			}
			
			// Set up gizmo at the tile position
			if (!m_transformGizmo.m_enabled || m_previousTarget != tile)
			{
				// Todo: clear up ghost???
				
				m_transformGizmo.SetVisible();
				m_transformGizmo.SetEnabled();
		
				m_transformGizmo.x = tile.x * 16;
				m_transformGizmo.y = tile.y * 16;
				m_transformGizmo.z = tile.height * 16;
				
				m_previousTarget = tile;
				
				// set up initial drag spots
				m_dragWorldStart.copyFrom(m_transformGizmo);
			}
			// If the gizmo IS set up, then we ghost when the gizmo is updated.
			else
			{
				var bDragging = m_transformGizmo.m_dragX || m_transformGizmo.m_dragY || m_transformGizmo.m_dragZ;
				
				if (bDragging)
				{
					// Beginning drag:
					if (!m_haveTileSelectionGhost)
					{
						m_haveTileSelectionGhost = true;
						
						// Move the gizmo to the center of the selection
						m_transformGizmo.x = tile.x * 16;
						m_transformGizmo.y = tile.y * 16;
						m_transformGizmo.z = tile.height * 16;
						// set up initial drag spots
						m_dragWorldStart.copyFrom(m_transformGizmo);
						
						// Create a tileset with the selected tile
						m_tileSelectionGhostTilemap = new ATilemap();
						m_tileSelectionGhostTilemap.AddTile(tile);
						m_tileSelectionGhostTilemap.AddHeight(tile.height);
						
						// Remove the tile from the current map
						var workingTileIndex = m_editor.m_tilemap.GetTileIndex(tile);
						m_editor.m_tilemap.DeleteTileIndex(workingTileIndex);
						m_editor.m_tilemap.RemoveHeightSlow(tile.height);
						
						// Rebuild the current map
						with (m_editor)
						{
							idelete(o_tileset3DIze);
							
							// Delete all current intermediate layers
							MapFreeAllIntermediateLayers();
							// Set up the tiles
							m_tilemap.BuildLayers(intermediateLayers);
	
							// Create the 3d-ify chain
							inew(o_tileset3DIze);
						}
						
						// Delete the current map
						with (m_editor)
						{
							// Delete all current intermediate layers
							MapFreeAllIntermediateLayers();
						}
						// Build a temp map for the new tilemap
						var temp_layers = [];
						m_tileSelectionGhostTilemap.BuildLayers(temp_layers);
						// Create the map
						m_tileSelectionGhostRenderer = inew(o_tileset3DIze);
						
						// Now reset the main map to normal state
						layer_destroy_list(temp_layers);
						with (m_editor)
						{
							// Set up the tiles
							m_tilemap.BuildLayers(intermediateLayers);
							// Set up the props
							m_propmap.RebuildPropLayer(intermediateLayers);
						}
						
					}
					
					// Continuing drag:
					if (m_haveTileSelectionGhost)
					{
						// Update position of ghost based on start/stop
						m_tileSelectionGhostRenderer.x = m_transformGizmo.x - m_dragWorldStart.x;
						m_tileSelectionGhostRenderer.y = m_transformGizmo.y - m_dragWorldStart.y;
						m_tileSelectionGhostRenderer.z = m_transformGizmo.z - m_dragWorldStart.z;
					}
				}
				else if (!bDragging)
				{
					// Stopping drag:
					if (m_haveTileSelectionGhost)
					{
						m_haveTileSelectionGhost = false;
						
						// Remove the ghost renderer
						idelete(m_tileSelectionGhostRenderer);
						m_tileSelectionGhostRenderer = null;
						
						// Move the tile from the ghost back to the tileset
						for (var tileIndex = 0; tileIndex < array_length(m_tileSelectionGhostTilemap.tiles); ++tileIndex)
						{
							// Change the XYZ
							m_tileSelectionGhostTilemap.tiles[tileIndex].x += round((m_transformGizmo.x - m_dragWorldStart.x) / 16);
							m_tileSelectionGhostTilemap.tiles[tileIndex].y += round((m_transformGizmo.y - m_dragWorldStart.y) / 16);
							m_tileSelectionGhostTilemap.tiles[tileIndex].height += round((m_transformGizmo.z - m_dragWorldStart.z) / 16);
							// TODO: safe limits
							
							m_editor.m_tilemap.AddTile(m_tileSelectionGhostTilemap.tiles[tileIndex]);
							m_editor.m_tilemap.AddHeight(m_tileSelectionGhostTilemap.tiles[tileIndex].height);
						}
						delete m_tileSelectionGhostTilemap;
						m_tileSelectionGhostTilemap = null;
						
						// Rebuild the main map
						with (m_editor)
						{
							idelete(o_tileset3DIze);
							
							// Delete all current intermediate layers
							MapFreeAllIntermediateLayers();
							// Set up the tiles
							m_tilemap.BuildLayers(intermediateLayers);
							// Set up the props
							m_propmap.RebuildPropLayer(intermediateLayers);
	
							// Create the 3d-ify chain
							inew(o_tileset3DIze);
						}
					}
				}
			}
		}
		else
		{
			if (m_haveTileSelectionState)
			{
				EndTileSelection();
			}
			
			m_transformGizmo.SetInvisible();
			m_transformGizmo.SetDisabled();
		}
		
		m_transformGizmoWasConsumingMouse = m_transformGizmoConsumingMouse;
		m_transformGizmoConsumingMouse = m_transformGizmo.GetConsumingMouse();
		
		// Update like normal click if not using the transform gizmo
		if (!m_transformGizmo.GetEnabled() || !(m_transformGizmoConsumingMouse || m_transformGizmoWasConsumingMouse))
		{
			Parent_onStep();
		}
		// Otherwise, minimally update the picker visuals.
		else
		{
			PickerUpdateVisuals();
		}
	};
	
	onClickWorld = function(button, buttonState, screenPosition, worldPosition)
	{
		// Update like normal click if not using the transform gizmo
		if (!m_transformGizmo.GetEnabled() || !(m_transformGizmoConsumingMouse || m_transformGizmoWasConsumingMouse))
		{
			Parent_onClickWorld(button, buttonState, screenPosition, worldPosition);
		}
	};
}

/// @function AEditorToolStateRotate() constructor
function AEditorToolStateRotate() : AEditorToolStateTranslate() constructor
{
	onBegin = function()
	{
		Parent_onBegin();
		
		m_transformGizmo = m_editor.EditorGizmoGet(AEditorGizmoPointRotate);
		m_transformGizmo.SetInvisible();
		m_transformGizmo.SetDisabled();
		
		m_editor.m_statusbar.m_toolHelpText = "Click to select objects. Use gizmo to rotate around an axis. Hold Alt to toggle snapping.";
	};
	
	onStep = function()
	{
		// Keyboard "no-snap" override toggle
		var bEnableAngleSnaps = keyboard_check(vk_shift);
		
		var bValidSelection = array_length(m_editor.m_selection) > 0;
		if (bValidSelection)
		{
			if (is_struct(m_editor.m_selection[0]))
			{
				if (m_editor.m_selection[0].type == kEditorSelection_Tile
					|| m_editor.m_selection[0].type == kEditorSelection_TileFace)
				{
					bValidSelection = false;
				}
			}
		}
		
		if (bValidSelection)
		{
			// Gather transform target first
			var target = m_editor.m_selection[0];
			var target_type = kEditorSelection_None;
			if (is_struct(m_editor.m_selection[0]))
			{
				if (m_editor.m_selection[0].type == kEditorSelection_Prop)
				{
					target = m_editor.m_selection[0].object;
					target_type = kEditorSelection_Prop;
				}
				else if (m_editor.m_selection[0].type == kEditorSelection_Splat)
				{
					target = m_editor.m_selection[0].object;
					target_type = kEditorSelection_Splat;
				}
			}
			var bCanRotate = is_struct(target) ? variable_struct_exists(target, "xrotation") : variable_instance_exists(target, "xrotation");
			
			// Move to the target position [always]
			m_transformGizmo.x = target.x;
			m_transformGizmo.y = target.y;
			m_transformGizmo.z = target.z;
			
			// If the gizmo is not set up, then we set up initial gizmo position & reference position.
			if (!m_transformGizmo.m_enabled || m_previousTarget != target)
			{
				m_transformGizmo.SetVisible();
				m_transformGizmo.SetEnabled();
		
				if (bCanRotate)
				{
					m_transformGizmo.xrotation = target.xrotation;
					m_transformGizmo.yrotation = target.yrotation;
					m_transformGizmo.zrotation = target.zrotation;
				}
				
				m_previousTarget = target;
			}
			// If the gizmo IS set up, then we update the selected objects' positions to the gizmo translation.
			else
			{
				if (bCanRotate)
				{
					var snap = bEnableAngleSnaps;
					var next_x = m_transformGizmo.m_dragX ? (snap ? round_nearest(m_transformGizmo.xrotation, 15) : m_transformGizmo.xrotation) : target.xrotation;
					var next_y = m_transformGizmo.m_dragY ? (snap ? round_nearest(m_transformGizmo.yrotation, 15) : m_transformGizmo.yrotation) : target.yrotation;
					var next_z = m_transformGizmo.m_dragZ ? (snap ? round_nearest(m_transformGizmo.zrotation, 15) : m_transformGizmo.zrotation) : target.zrotation;
				
					var bSignalChange = 
							target.xrotation != next_x
						|| target.yrotation != next_y
						|| target.zrotation != next_z;
				
					target.xrotation = next_x;
					target.yrotation = next_y;
					target.zrotation = next_z;
					
					if (bSignalChange)
					{
						EditorGlobalSignalTransformChange(target, target_type);
					}
				}
			}
		}
		else
		{
			m_transformGizmo.SetInvisible();
			m_transformGizmo.SetDisabled();
		}
		
		m_transformGizmoWasConsumingMouse = m_transformGizmoConsumingMouse;
		m_transformGizmoConsumingMouse = m_transformGizmo.GetConsumingMouse();
		
		// Update like normal click if not using the transform gizmo
		if (!m_transformGizmo.GetEnabled() || !(m_transformGizmoConsumingMouse || m_transformGizmoWasConsumingMouse))
		{
			Parent_onStep();
		}
		// Otherwise, minimally update the picker visuals.
		else
		{
			PickerUpdateVisuals();
		}
	};
}