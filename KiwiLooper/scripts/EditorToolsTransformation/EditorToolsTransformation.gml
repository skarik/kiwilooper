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
	
	m_previousTargets = [];
	m_previousTargetsStart = [];
	
	m_isDragging = false;
	m_dragWorldStart = new Vector3(0, 0, 0);
	m_dragWorldStartTile = new Vector3(0, 0, 0); // This gets updated constantly as tiles are committed instantly
	
	m_transformGizmo = null;
	
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
		
		// Disable limiting the mouse position to inside the window:
		Screen.limitMouseMode = kLimitMouseMode_None;
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
	
	BuildGhostRenderer = function()
	{
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
	DestroyGhostRenderer = function()
	{
		// Remove the ghost renderer
		idelete(m_tileSelectionGhostRenderer);
		m_tileSelectionGhostRenderer = null;
		
		// Remove the ghost tilemap
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
	
	onSignalTransformChange = function(entity, type)
	{
		if (is_struct(m_transformGizmo) && m_transformGizmo.m_enabled)
		{
			if (!m_isDragging && !m_transformGizmo.IsDraggingAny())
			{
				var temp_selection = EditorSelectionWrap(entity, type);
				if (array_contains_pred(m_editor.m_selection, temp_selection, EditorSelectionEqual))
				{
					// Run through all the objects and get their positions
					var target_center = EditorSelectionGetAveragePosition();
					m_transformGizmo.x = target_center.x;
					m_transformGizmo.y = target_center.y;
					m_transformGizmo.z = target_center.z;
				}
			}
		}
	}
	
	onStep = function()
	{
		// Keyboard "no-snap" override toggle
		m_editor.toolGridTemporaryDisable = keyboard_check(vk_alt);
		
		var bIsValidSelection = array_length(m_editor.m_selection) > 0;
		var bIsSingleSelection = m_editor.m_selectionSingle;
		
		if (!bIsValidSelection)
		{
			m_transformGizmo.SetInvisible();
			m_transformGizmo.SetDisabled();
			
			m_previousTargets = [];
		}
		else 
		{
			// If the gizmo is not set up, then we set up initial gizmo position & reference position.
			if (!m_transformGizmo.m_enabled || array_is_mismatch(m_previousTargets, m_editor.m_selection, EditorSelectionEqual))
			{
				m_transformGizmo.SetVisible();
				m_transformGizmo.SetEnabled();
				m_previousTargets = CE_ArrayClone(m_editor.m_selection);
				
				// Run through all the objects and get their positions
				var target_center = EditorSelectionGetAveragePosition();
				m_transformGizmo.x = target_center.x;
				m_transformGizmo.y = target_center.y;
				m_transformGizmo.z = target_center.z;
				
				// Mark starting point of the dragging start
				m_dragWorldStart.copyFrom(target_center);
				
				for (var selectIndex = 0; selectIndex < array_length(m_previousTargets); ++selectIndex)
				{
					m_previousTargetsStart[selectIndex] = EditorSelectionGetPosition(m_previousTargets[selectIndex]);
				}
			}
			
			var snap = m_editor.toolGrid && !m_editor.toolGridTemporaryDisable;
			var offset_x = bIsSingleSelection ? 0.0 : (snap ? (round_nearest(m_dragWorldStart.x, m_editor.toolGridSize) - m_dragWorldStart.x) : 0.0);
			var offset_y = bIsSingleSelection ? 0.0 : (snap ? (round_nearest(m_dragWorldStart.y, m_editor.toolGridSize) - m_dragWorldStart.y) : 0.0);
			var offset_z = bIsSingleSelection ? 0.0 : (snap ? (round_nearest(m_dragWorldStart.z, m_editor.toolGridSize) - m_dragWorldStart.z) : 0.0);
			m_transformGizmo.m_snapOffset = [offset_x, offset_y, offset_z];
			
			var delta_x = (m_transformGizmo.x - m_dragWorldStart.x);
			var delta_y = (m_transformGizmo.y - m_dragWorldStart.y);
			var delta_z = (m_transformGizmo.z - m_dragWorldStart.z);
			
			var bSignalAnyPropChange = false;
			var bSignalAnySplatChange = false;
			var signalProp = null;
			var signalSplat = null;
			
			// Run through the drag logic with each given type of object
			for (var selectIndex = 0; selectIndex < array_length(m_editor.m_selection); ++selectIndex)
			{
				var selection = m_editor.m_selection[selectIndex];
			
				// Gather transform target first
				var target = selection;
				var target_type = kEditorSelection_None;
				if (is_struct(selection))
				{
					if (selection.type == kEditorSelection_Prop)
					{
						target = selection.object;
						target_type = kEditorSelection_Prop;
					}
					else if (selection.type == kEditorSelection_Splat)
					{
						target = selection.object;
						target_type = kEditorSelection_Splat;
					}
					else if (selection.type == kEditorSelection_Tile || selection.type == kEditorSelection_TileFace)
						continue; // Skip the world stuff for now
				}
				
				// Apply the offset based on the drag position offset
				var startPosition = m_previousTargetsStart[selectIndex];
				
				var next_x = startPosition.x + delta_x;
				var next_y = startPosition.y + delta_y;
				var next_z = startPosition.z + delta_z;
				
				var bSignalChange = 
						target.x != next_x
					|| target.y != next_y
					|| target.z != next_z;
				
				target.x = next_x;
				target.y = next_y;
				target.z = next_z;
				
				if (bSignalChange)
				{
					EditorGlobalSignalTransformChange(target, target_type, kValueTypePosition, true);
					
					bSignalAnyPropChange |= (target_type == kEditorSelection_Prop);
					if (target_type == kEditorSelection_Prop)
						signalProp = target;
					bSignalAnySplatChange |= (target_type == kEditorSelection_Splat);
					if (target_type == kEditorSelection_Splat)
						signalSplat = target;
				}
			}
			
			if (m_transformGizmo.IsDraggingAny()
				&& array_is_any_of(m_editor.m_selection, function(value, index){ return is_struct(value) && value.type == kEditorSelection_Tile})
				)
			{
				if (!m_haveTileSelectionGhost)
				{
					m_haveTileSelectionGhost = true;
					
					// We need to set up a ghost
					m_dragWorldStartTile.copyFrom(m_transformGizmo);
					
					// Create a tileset with the selected tile
					m_tileSelectionGhostTilemap = new ATilemap();
					CE_ArrayForEach(
						m_editor.m_selection,
						function(value, index)
						{
							if (!is_struct(value) || value.type != kEditorSelection_Tile)
							{	
								return;
							}
							
							// Add the tile to the ghost map
							var tile = value.object;
							m_tileSelectionGhostTilemap.AddTile(tile);
							m_tileSelectionGhostTilemap.AddHeight(tile.height);
							
							// Remove the tile from the current map
							var workingTileIndex = m_editor.m_tilemap.GetTileIndex(tile);
							m_editor.m_tilemap.DeleteTileIndex(workingTileIndex);
							m_editor.m_tilemap.RemoveHeightSlow(tile.height);
						});
						
					// Build the ghost renderer now
					BuildGhostRenderer();
				}
				
				// Continuing drag:
				if (m_haveTileSelectionGhost)
				{
					// Update position of ghost based on start/stop
					m_tileSelectionGhostRenderer.x = round_nearest(m_transformGizmo.x - m_dragWorldStartTile.x, 16.0);
					m_tileSelectionGhostRenderer.y = round_nearest(m_transformGizmo.y - m_dragWorldStartTile.y, 16.0);
					m_tileSelectionGhostRenderer.z = round_nearest(m_transformGizmo.z - m_dragWorldStartTile.z, 16.0);
				}
			}
			else if (m_haveTileSelectionGhost)
			{
				m_haveTileSelectionGhost = false;
				
				// Move the tiles from the ghost back to the tileset
				for (var tileIndex = 0; tileIndex < array_length(m_tileSelectionGhostTilemap.tiles); ++tileIndex)
				{
					// Change the XYZ
					m_tileSelectionGhostTilemap.tiles[tileIndex].x += round((m_transformGizmo.x - m_dragWorldStartTile.x) / 16);
					m_tileSelectionGhostTilemap.tiles[tileIndex].y += round((m_transformGizmo.y - m_dragWorldStartTile.y) / 16);
					m_tileSelectionGhostTilemap.tiles[tileIndex].height += round((m_transformGizmo.z - m_dragWorldStartTile.z) / 16);
					// TODO: safe limits
							
					m_editor.m_tilemap.AddTile(m_tileSelectionGhostTilemap.tiles[tileIndex]);
					m_editor.m_tilemap.AddHeight(m_tileSelectionGhostTilemap.tiles[tileIndex].height);
				}
				
				// Destroy renderer
				DestroyGhostRenderer();
			}
			
			// Rebuild the splats & props at the end so we don't rebuild it multiple times in the movement loop
			if (bSignalAnyPropChange)	EditorGlobalSignalTransformChange(signalProp, kEditorSelection_Prop, kValueTypePosition);
			if (bSignalAnySplatChange)	EditorGlobalSignalTransformChange(signalSplat, kEditorSelection_Splat, kValueTypePosition);
			
			// Update dragging state after everything has been moved
			m_isDragging = m_transformGizmo.IsDraggingAny();
		}
		
		m_transformGizmoWasConsumingMouse = m_transformGizmoConsumingMouse;
		m_transformGizmoConsumingMouse = m_transformGizmo.GetConsumingMouse();
		
		// Apply mouse moving limits if we're dragging, reset if now
		if (m_isDragging)
		{
			Screen.limitMouseMode = kLimitMouseMode_Clamp;
		}
		else
		{
			Screen.limitMouseMode = kLimitMouseMode_None;
		}
		
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
		
		m_editor.m_statusbar.m_toolHelpText = "Click to select objects. Use gizmo to rotate around an axis. Hold Shift to enable snapping.";
	};
	
	// TODO onSignalTransformChange = function(entity, type)
	
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
						EditorGlobalSignalTransformChange(target, target_type, kValueTypeRotation);
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


/// @function AEditorToolStateScale() constructor
function AEditorToolStateScale() : AEditorToolStateTranslate() constructor
{
	onBegin = function()
	{
		Parent_onBegin();
		
		m_transformGizmo = m_editor.EditorGizmoGet(AEditorGizmoPointScale);
		m_transformGizmo.SetInvisible();
		m_transformGizmo.SetDisabled();
		
		m_editor.m_statusbar.m_toolHelpText = "Click to select objects. Use gizmo to scale a local axis. Hold Alt to toggle snapping.";
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
	
	// TODO onSignalTransformChange = function(entity, type)
	
	onStep = function()
	{
		// Keyboard "no-snap" override toggle
		m_editor.toolGridTemporaryDisable = keyboard_check(vk_alt);
		
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
			var bCanScale = is_struct(target) ? variable_struct_exists(target, "xscale") : variable_instance_exists(target, "xscale");
			
			// Move to the target position [always]
			/*m_transformGizmo.x = target.x;
			m_transformGizmo.y = target.y;
			m_transformGizmo.z = target.z;*/
			
			// If the gizmo is not set up, then we set up initial gizmo position & reference position.
			if (!m_transformGizmo.m_enabled || m_previousTarget != target)
			{
				m_transformGizmo.SetVisible();
				m_transformGizmo.SetEnabled();
		
				// Gizmo needs the rotation for proper editin's
				m_transformGizmo.xrotation = bCanRotate ? target.xrotation : 0.0;
				m_transformGizmo.yrotation = bCanRotate ? target.yrotation : 0.0;
				m_transformGizmo.zrotation = bCanRotate ? target.zrotation : 0.0;
				
				m_transformGizmo.x = target.x;
				m_transformGizmo.y = target.y;
				m_transformGizmo.z = target.z;
		
				if (bCanScale)
				{
					// set up the size of the scaling object
					m_transformGizmo.xscale = target.xscale;
					m_transformGizmo.yscale = target.yscale;
					m_transformGizmo.zscale = target.zscale;
					
					// we need the [unrotated] bbox of the object we're scaling:
					var bbox;
					if (target_type == kEditorSelection_None)
					{
						var entTypeInfo, entHhsz, entGizmoType, entOrient;
						
						// Get the entity info:
						entTypeInfo		= target.entity;
						entHhsz			= entTypeInfo.hullsize * 0.5;
						entGizmoType	= entTypeInfo.gizmoDrawmode;
						entOrient		= entTypeInfo.gizmoOrigin;
						
						// Get offset center
						//var entHSize = new Vector3(entHhsz * target.xscale, entHhsz * target.yscale, entHhsz * target.zscale); // TODO: scale the hhsz
						var entHSize = new Vector3(entHhsz, entHhsz, entHhsz); // TODO: scale the hhsz
						var entCenter = entGetSelectionCenter(target, entOrient, entHSize);
						bbox = new BBox3(entCenter.subtract(Vector3FromTranslation(target)), entHSize);
					}
					else if (target_type == kEditorSelection_Prop)
					{
						var prop = target;
						bbox = PropGetBBox(prop.sprite);
						//bbox.extents.multiplyComponentSelf(Vector3FromScale(prop));
					}
					else if (target_type == kEditorSelection_Splat)
					{
						var splat = target;
						var bbox = SplatGetBBox(splat);
						//bbox.extents.multiplyComponentSelf(Vector3FromScale(splat));
					}
					m_transformGizmo.bbox = bbox;
				}
				
				m_previousTarget = target;
			}
			// If the gizmo IS set up, then we update the selected objects' positions to the gizmo translation.
			else
			{
				if (bCanScale)
				{
					var snap = m_editor.toolGrid && !m_editor.toolGridTemporaryDisable;
					/*var next_x = m_transformGizmo.m_dragX ? (snap ? round_nearest(m_transformGizmo.xscale, 0.1) : m_transformGizmo.xscale) : target.xscale;
					var next_y = m_transformGizmo.m_dragY ? (snap ? round_nearest(m_transformGizmo.yscale, 0.1) : m_transformGizmo.yscale) : target.yscale;
					var next_z = m_transformGizmo.m_dragZ ? (snap ? round_nearest(m_transformGizmo.zscale, 0.1) : m_transformGizmo.zscale) : target.zscale;*/
					var next_x = m_transformGizmo.m_dragX ? m_transformGizmo.xscale : target.xscale;
					var next_y = m_transformGizmo.m_dragY ? m_transformGizmo.yscale : target.yscale;
					var next_z = m_transformGizmo.m_dragZ ? m_transformGizmo.zscale : target.zscale;
					
					var next_px = m_transformGizmo.IsDraggingAny() ? m_transformGizmo.x : target.x;
					var next_py = m_transformGizmo.IsDraggingAny() ? m_transformGizmo.y : target.y;
					var next_pz = m_transformGizmo.IsDraggingAny() ? m_transformGizmo.z : target.z;
				
					var bSignalChange = 
							target.xscale != next_x
						|| target.yscale != next_y
						|| target.zscale != next_z
						|| target.x != next_px
						|| target.y != next_py
						|| target.z != next_pz;
				
					target.xscale = next_x;
					target.yscale = next_y;
					target.zscale = next_z;
					
					target.x = next_px;
					target.y = next_py;
					target.z = next_pz;
					
					if (bSignalChange)
					{
						EditorGlobalSignalTransformChange(target, target_type, kValueTypePosition);
						EditorGlobalSignalTransformChange(target, target_type, kValueTypeScale);
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
