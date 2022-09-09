#macro kPickerHitMaskTilemap	0x01
#macro kPickerHitMaskEntity		0x02
#macro kPickerHitMaskProp		0x04
#macro kPickerHitMaskSplat		0x08
///@function EditorPickerCast(rayStart, rayDir, outHitObjects, outHitDistances, outHitNormals, hitMask, ignoreList)
function EditorPickerCast(rayStart, rayDir, outHitObjects, outHitDistances, outHitNormals, hitMask=0xFF, ignoreList=[])
{
	var l_priorityHits = ds_priority_create();
		
	// Run through the ent table
	if (hitMask & kPickerHitMaskEntity)
	{
		for (var entTypeIndex = 0; entTypeIndex <= entlistIterationLength(); ++entTypeIndex)
		{
			var entTypeInfo, entType, entHhsz, entGizmoType, entOrient;
			if (entTypeIndex != entlistIterationLength())
			{
				entTypeInfo		= entlistIterationGet(entTypeIndex);
				entType			= entTypeInfo.objectIndex;
				entHhsz			= entTypeInfo.hullsize * 0.5;
				entGizmoType	= entTypeInfo.gizmoDrawmode;
				entOrient		= entTypeInfo.gizmoOrigin;
			}
			// Check for proxies:
			else
			{
				entType		= EditorGet().OProxyClass;
			}
			
			// Count through the ents
			var entCount = instance_number(entType);
			for (var entIndex = 0; entIndex < entCount; ++entIndex)
			{
				var ent = instance_find(entType, entIndex);
				// Check for proxies:
				if (entTypeIndex == entlistIterationLength())
				{
					entTypeInfo		= ent.entity;
					entHhsz			= entTypeInfo.hullsize * 0.5;
					entGizmoType	= entTypeInfo.gizmoDrawmode;
					entOrient		= entTypeInfo.gizmoOrigin;
				}
				
				// Get offset center
				var entHSize = new Vector3(entHhsz * ent.xscale, entHhsz * ent.yscale, entHhsz * ent.zscale);
				var entCenter = entGetSelectionCenter(ent, entOrient, entHSize);
				
				if (raycast4_box(new Vector3(entCenter.x - entHSize.x, entCenter.y - entHSize.y, entCenter.z - entHSize.z),
									new Vector3(entCenter.x + entHSize.y, entCenter.y + entHSize.y, entCenter.z + entHSize.z),
									rayStart, rayDir))
				{
					if (!array_contains_pred(ignoreList, ent, EditorSelectionEqual))
					{
						ds_priority_add(l_priorityHits, [ent, raycast4_get_hit_distance(), raycast4_get_hit_normal()], raycast4_get_hit_distance());
					}
				}
			}
		}
	}
		
	// Run through all props
	if (hitMask & kPickerHitMaskProp)
	{
		for (var propIndex = 0; propIndex < EditorGet().m_propmap.GetPropCount(); ++propIndex)
		{
			var prop = EditorGet().m_propmap.GetProp(propIndex);
			
			// Get the prop BBox & transform it into the world
			var propBBox = PropGetBBox(prop.sprite);
			var propTranslation = matrix_build_translation(prop);
			var propRotation = matrix_build_rotation(prop);
			
			if (raycast4_box_rotated(
				propBBox.center.add(Vector3FromTranslation(prop)),
				propBBox.extents.multiplyComponent(Vector3FromScale(prop)),
				propRotation,
				true,
				rayStart, rayDir))
			{
				var propAsSelection = EditorSelectionWrapProp(prop);
				if (!array_contains_pred(ignoreList, propAsSelection, EditorSelectionEqual))
				{
					ds_priority_add(l_priorityHits, [propAsSelection, raycast4_get_hit_distance(), raycast4_get_hit_normal()], raycast4_get_hit_distance());
				}
			}
		}
	}
		
	// Run through all splats
	if (hitMask & kPickerHitMaskSplat)
	{
		for (var splatIndex = 0; splatIndex < m_editor.m_splatmap.GetSplatCount(); ++splatIndex)
		{
			var splat = EditorGet().m_splatmap.GetSplat(splatIndex);
			
			// Get the splat BBox & transform it into the world
			var splatBBox = SplatGetBBox(splat);
			var splatRotation = matrix_build_rotation(splat);
			
			// Cast against it
			if (raycast4_box_rotated(
				splatBBox.center.add(Vector3FromTranslation(splat)),
				splatBBox.extents.multiplyComponent(Vector3FromScale(splat)),
				splatRotation,
				true,
				rayStart, rayDir))
			{
				ds_priority_add(l_priorityHits, [EditorSelectionWrapSplat(splat), raycast4_get_hit_distance(), raycast4_get_hit_normal()], raycast4_get_hit_distance());
			}
		}
	}
		
	// Run against the terrain
	if (hitMask & kPickerHitMaskTilemap)
	{
		if (raycast4_tilemap(rayStart, rayDir))
		{
			var hitBlockX = rayStart.x + rayDir.x * raycast4_get_hit_distance();
			var hitBlockY = rayStart.y + rayDir.y * raycast4_get_hit_distance();
			var hitBlockZ = rayStart.z + rayDir.z * raycast4_get_hit_distance();
			var hitNormal = new Vector3();
			hitNormal.copyFrom(raycast4_get_hit_normal());
			
			// Extrude the opposite from the hit normal, and get the block position
			var blockX = floor((hitBlockX - hitNormal.x) / 16.0);
			var blockY = floor((hitBlockY - hitNormal.y) / 16.0);
			var blockZ = floor((hitBlockZ - hitNormal.z) / 16.0);
			
			var tile_index = EditorGet().m_tilemap.GetPositionIndex(blockX, blockY);
			if (tile_index != -1)
			{
				ds_priority_add(l_priorityHits, [EditorSelectionWrapTile(EditorGet().m_tilemap.tiles[tile_index]), raycast4_get_hit_distance(), raycast4_get_hit_normal()], raycast4_get_hit_distance());
			}
		}
	}
		
	// Pull the priority to a list
	// TODO: someday make this less slow because we hit this all the time
	var l_priorityHitCount = ds_priority_size(l_priorityHits);
	for (var i = 0; i < l_priorityHitCount; ++i)
	{
		var minp = ds_priority_find_min(l_priorityHits);
		array_push(outHitObjects, minp[0]);
		array_push(outHitDistances, minp[1]);
		array_push(outHitNormals, minp[2]);
		ds_priority_delete_min(l_priorityHits);
	}
	ds_priority_destroy(l_priorityHits);
		
	return l_priorityHitCount;
}

///@function EditorPickerCast2(rayStart, rayDir, outHitObjects, outHitDistances, hitMask)
function EditorPickerCast2(rayStart, rayDir, outHitObjects, outHitDistances, hitMask=0xFF)
{
	var droppedNormals = [];
	return EditorPickerCast(rayStart, rayDir, outHitObjects, outHitDistances, droppedNormals, hitMask);
}

/// @function AEditorToolStateSelect() constructor
function AEditorToolStateSelect() : AEditorToolState() constructor
{
	state = kEditorToolSelect;
	
	kDragAreaThreshold = 3.0;
	m_leftClickDrag = false;
	m_leftClickStart = new Vector2(0, 0);
	m_leftClickEnd = new Vector2(0, 0);
	m_leftClickDragArea = 0;
	
	m_pickerLastClickList = [];
	m_pickerLastClickIndex = null;
	
	onBegin = function()
	{
		m_gizmo = m_editor.EditorGizmoGet(AEditorGizmoSelectBox);
		m_gizmo.SetVisible();
		m_gizmo.SetEnabled();
		
		m_editor.m_statusbar.m_toolHelpText = "Click to select objects.";
	};
	onEnd = function(trueEnd)
	{
		m_gizmo.SetInvisible();
		m_gizmo.SetDisabled();
	};
	
	onStep = function()
	{
		// Set up the grad box:
		if (m_leftClickDrag)
		{
			m_leftClickDragArea = abs(m_leftClickEnd.x - m_leftClickStart.x) * abs(m_leftClickEnd.y - m_leftClickStart.y);
			if (m_leftClickDragArea >= kDragAreaThreshold)
			{
				m_gizmo.SetVisible();
				m_gizmo.m_min.x = min(m_leftClickStart.x, m_leftClickEnd.x);
				m_gizmo.m_max.x = max(m_leftClickStart.x, m_leftClickEnd.x);
				m_gizmo.m_min.y = min(m_leftClickStart.y, m_leftClickEnd.y);
				m_gizmo.m_max.y = max(m_leftClickStart.y, m_leftClickEnd.y);
			}
		}
		else
		{
			m_gizmo.SetInvisible();
		}
		
		// Update picker visuals:
		PickerUpdateVisuals();
	};
	
	/// @function PickerUpdateVisuals()
	/// @desc Updates the picker's selection box visuals. This is done via gizmo.
	PickerUpdateVisuals = function()
	{
		m_showSelectGizmo = m_editor.EditorGizmoGet(AEditorGizmoMultiSelectBox3D);
		// Draw the box around the picker
		var l_selectionCount = array_length(m_editor.m_selection);
		if (l_selectionCount > 0)
		{
			m_showSelectGizmo.SetVisible();
			m_showSelectGizmo.SetEnabled();
			
			// Clear out array every frame to ensure correct sizing
			m_showSelectGizmo.m_mins = array_create(l_selectionCount);
			m_showSelectGizmo.m_maxes = array_create(l_selectionCount);
			m_showSelectGizmo.m_trses = array_create(l_selectionCount);
			
			// Build out the boxes for each item in the selection:
			for (var iSelection = 0; iSelection < l_selectionCount; ++iSelection)
			{
				var selection = m_editor.m_selection[iSelection];
			
				if (is_struct(selection))
				{
					if (selection.type == kEditorSelection_Prop)
					{
						var prop = selection.object;
					
						// get the bbox
						var propBBox = PropGetBBox(prop.sprite);
						var propTranslation = matrix_build_translation(prop);
						var propRotation = matrix_build_rotation(prop);
			
						propBBox.extents.multiplyComponentSelf(Vector3FromScale(prop));
					
						m_showSelectGizmo.m_mins[iSelection] = propBBox.getMin();
						m_showSelectGizmo.m_maxes[iSelection] = propBBox.getMax();
						m_showSelectGizmo.m_trses[iSelection] = matrix_multiply(propRotation, propTranslation);
					}
					else if (selection.type == kEditorSelection_Splat)
					{
						var splat = selection.object;
					
						// get the bbox
						var splatBBox = SplatGetBBox(splat);
						var splatTranslation = matrix_build_translation(splat);
						var splatRotation = matrix_build_rotation(splat);
			
						splatBBox.extents.multiplyComponentSelf(Vector3FromScale(splat));
					
						m_showSelectGizmo.m_mins[iSelection] = splatBBox.getMin();
						m_showSelectGizmo.m_maxes[iSelection] = splatBBox.getMax();
						m_showSelectGizmo.m_trses[iSelection] = matrix_multiply(splatRotation, splatTranslation);
					}
					// todo: tiles
					else if (selection.type == kEditorSelection_Tile)
					{
						var tile = selection.object;
					
						// todo
						m_showSelectGizmo.m_mins[iSelection]  = new Vector3(tile.x * 16,		 tile.y * 16,	   -16)				.add(new Vector3(-0.5, -0.5, -0.5));
						m_showSelectGizmo.m_maxes[iSelection] = new Vector3(tile.x * 16 + 16, tile.y * 16 + 16, tile.height * 16).add(new Vector3( 0.5,  0.5,  0.5));
						m_showSelectGizmo.m_trses[iSelection] = matrix_build_identity();
					}
				}
				else if (iexists(selection))
				{
					var entTypeInfo, entHhsz, entGizmoType, entOrient;
				
					// Get the entity info:
					entTypeInfo		= selection.entity;
					entHhsz			= entTypeInfo.hullsize * 0.5;
					entGizmoType	= entTypeInfo.gizmoDrawmode;
					entOrient		= entTypeInfo.gizmoOrigin;
				
					// Get offset center
					var entHSize = new Vector3(entHhsz * selection.xscale, entHhsz * selection.yscale, entHhsz * selection.zscale); // TODO: scale the hhsz
					var entCenter = entGetSelectionCenter(selection, entOrient, entHSize);
				
					/*m_showSelectGizmo.m_mins[iSelection] = new Vector3(entCenter.x - entHSize.x, entCenter.y - entHSize.y, entCenter.z - entHSize.z);
					m_showSelectGizmo.m_maxes[iSelection] = new Vector3(entCenter.x + entHSize.x, entCenter.y + entHSize.y, entCenter.z + entHSize.z);
					m_showSelectGizmo.m_trses[iSelection] = matrix_build_identity();*/
					
					var entTranslation = matrix_build_translation(entCenter);
					var entRotation = matrix_build_rotation(selection);
					m_showSelectGizmo.m_mins[iSelection] = entHSize.multiply(-1.0);
					m_showSelectGizmo.m_maxes[iSelection] = entHSize.copy();
					m_showSelectGizmo.m_trses[iSelection] = matrix_multiply(entRotation, entTranslation); //todo: need to rotate the hull offset first
				}
			}
		}
		else
		{
			m_showSelectGizmo.SetInvisible();
			m_showSelectGizmo.SetDisabled();
		}
	}
	
	onClickWorld = function(button, buttonState, screenPosition, worldPosition)
	{
		if (buttonState == kEditorToolButtonStateMake)
		{
			if (button == mb_left)
			{
				m_leftClickDrag = true;
				m_leftClickStart.x = m_editor.toolFlatX;
				m_leftClickStart.y = m_editor.toolFlatY;
			}
		}
		if (buttonState == kEditorToolButtonStateHeld)
		{
			if (button == mb_left)
			{
				m_leftClickEnd.x = m_editor.toolFlatX;
				m_leftClickEnd.y = m_editor.toolFlatY;
			}
		}
		if (buttonState == kEditorToolButtonStateBreak)
		{
			if (button == mb_left)
			{
				m_leftClickDrag = false;
				
				if (m_leftClickDragArea < kDragAreaThreshold)
				{
					PickerRun(keyboard_check(vk_control));
				}
				else
				{
					LassoRun();
				}
			}
		}
	};
	
	/// @function PickerRun(bAdditive = false)
	/// @desc Runs the picker.
	static PickerRun = function(bAdditive = false)
	{
		// If not additive, then reset the selection
		if (!bAdditive)
		{
			m_editor.m_selection = [];
			m_editor.m_selectionSingle = true;
		}
		
		var pixelX = m_editor.uPosition - GameCamera.view_x;
		var pixelY = m_editor.vPosition - GameCamera.view_y;
		
		// Get a ray
		var rayStart = new Vector3(o_Camera3D.x, o_Camera3D.y, o_Camera3D.z);
		var rayDir = Vector3FromArray(o_Camera3D.viewToRay(pixelX, pixelY));
		
		var closestEnt = null;
		
		// Cast against all objects in that specific ray
		var hitObjects = [];
		var hitDists = [];
		var hitCount = EditorPickerCast2(rayStart, rayDir, hitObjects, hitDists);
		if (hitCount > 0)
		{
			if (!bAdditive)
			{
				// if in single click mode, then we run through the list
				if (array_is_mismatch(m_pickerLastClickList, hitObjects, EditorSelectionEqual))
				{
					m_pickerLastClickList = CE_ArrayClone(hitObjects);
					m_pickerLastClickIndex = 0;
				}
				else
				{
					m_pickerLastClickIndex = (m_pickerLastClickIndex + 1) % hitCount;
				}
				closestEnt = hitObjects[m_pickerLastClickIndex];
			}
			else
			{
				// if in grabber mode, then we just add the last one
				m_pickerLastClickList = [];
				m_pickerLastClickIndex = null;
				
				closestEnt = hitObjects[0];
			}
		}
		
		// If we hit something, save it
		if (is_struct(closestEnt) || closestEnt != null)
		{
			// Not additive, just set up the selection
			if (!bAdditive)
			{
				m_editor.m_selection = [closestEnt];
				m_editor.m_selectionSingle = true;
			}
			// Additive, add/remove selection to end
			else
			{
				var selection_index = array_get_index_pred(m_editor.m_selection, closestEnt, EditorSelectionEqual);
				if (selection_index == null)
				{
					array_push(m_editor.m_selection, closestEnt);
				}
				else
				{
					array_delete(m_editor.m_selection, selection_index, 1);
				}
				m_editor.m_selectionSingle = array_length(m_editor.m_selection) <= 1;
			}
		}
	}
	
	/// @function LassoCast(lassoMin, lassoMax, outHitObjects)
	static LassoCast = function(lassoMin, lassoMax, outHitObjects)
	{
		var lassoRect = new Rect2(lassoMin, lassoMax);
		
		// Run through the ent table
		for (var entTypeIndex = 0; entTypeIndex <= entlistIterationLength(); ++entTypeIndex)
		{
			var entTypeInfo, entType, entHhsz, entGizmoType, entOrient;
			if (entTypeIndex != entlistIterationLength())
			{
				entTypeInfo		= entlistIterationGet(entTypeIndex);
				entType			= entTypeInfo.objectIndex;
				entHhsz			= entTypeInfo.hullsize * 0.5;
				entGizmoType	= entTypeInfo.gizmoDrawmode;
				entOrient		= entTypeInfo.gizmoOrigin;
			}
			// Check for proxies:
			else
			{
				entType		= m_editor.OProxyClass;
			}
			
			// Count through the ents
			var entCount = instance_number(entType);
			for (var entIndex = 0; entIndex < entCount; ++entIndex)
			{
				var ent = instance_find(entType, entIndex);
				// Check for proxies:
				if (entTypeIndex == entlistIterationLength())
				{
					entTypeInfo		= ent.entity;
					entHhsz			= entTypeInfo.hullsize * 0.5;
					entGizmoType	= entTypeInfo.gizmoDrawmode;
					entOrient		= entTypeInfo.gizmoOrigin;
				}
				
				// Get offset center
				var entHSize = new Vector3(entHhsz * ent.xscale, entHhsz * ent.yscale, entHhsz * ent.zscale);
				var entCenter = entGetSelectionCenter(ent, entOrient, entHSize);
				
				if (lassoRect.contains2(entCenter))
				{
					array_push(outHitObjects, ent);
				}
			}
		}
		
		// Run through all props
		for (var propIndex = 0; propIndex < m_editor.m_propmap.GetPropCount(); ++propIndex)
		{
			var prop = m_editor.m_propmap.GetProp(propIndex);
			
			// Get the prop BBox & transform it into the world
			var propBBox = PropGetBBox(prop.sprite);
			var propTranslation = matrix_build_translation(prop);
			var propRotation = matrix_build_rotation(prop);
			
			if (lassoRect.contains2(
					propBBox.center.add(Vector3FromTranslation(prop))))
			{
				array_push(outHitObjects, EditorSelectionWrapProp(prop));
			}
		}
		
		// Run through all splats
		for (var splatIndex = 0; splatIndex < m_editor.m_splatmap.GetSplatCount(); ++splatIndex)
		{
			var splat = m_editor.m_splatmap.GetSplat(splatIndex);
			
			// Get the splat BBox & transform it into the world
			var splatBBox = SplatGetBBox(splat);
			var splatRotation = matrix_build_rotation(splat);
			
			if (lassoRect.contains2(
					splatBBox.center.add(Vector3FromTranslation(splat))))
			{
				array_push(outHitObjects, EditorSelectionWrapSplat(splat));
			}
		}
		
		// Run against the terrain
		var lassoRectScaled = new Rect2(lassoMin.divide(16.0).subtract(new Vector2(0.5, 0.5)), lassoMax.divide(16.0).subtract(new Vector2(0.5, 0.5)));
		for (var tileIndex = 0; tileIndex < array_length(m_editor.m_tilemap.tiles); ++tileIndex)
		{
			var tile =  m_editor.m_tilemap.tiles[tileIndex];
			if (lassoRectScaled.contains2(tile))
			{
				array_push(outHitObjects, EditorSelectionWrapTile(tile));
			}
		}
		
		return array_length(outHitObjects);
	}
	
	/// @function LassoRun(bAdditive = false)
	static LassoRun = function(bAdditive = false)
	{
		// If not additive, then reset the selection
		if (!bAdditive)
		{
			m_editor.m_selection = [];
			m_editor.m_selectionSingle = true;
		}
		
		var rectStart = new Vector2(min(m_leftClickStart.x, m_leftClickEnd.x), min(m_leftClickStart.y, m_leftClickEnd.y));
		var rectEnd   = new Vector2(max(m_leftClickStart.x, m_leftClickEnd.x), max(m_leftClickStart.y, m_leftClickEnd.y));
		
		// Grab all the objects in the XY rect
		var hitObjects = [];
		var hitCount = LassoCast(rectStart, rectEnd, hitObjects);
		// Append all objects to the list
		if (hitCount > 0)
		{
			for (var i = 0; i < hitCount; ++i)
			{
				array_push(m_editor.m_selection, hitObjects[i]);
			}
		}
		
		m_editor.m_selectionSingle = array_length(m_editor.m_selection) <= 1;
	}
}


/// @function AEditorToolStateCamera() constructor
function AEditorToolStateCamera() : AEditorToolState() constructor
{
	state = kEditorToolCamera;
	
	m_mouseLeft = false;
	m_mouseRight = false;
	m_mouseMiddle = false;
	
	Parent_onBegin = onBegin;
	onBegin = function()
	{
		Parent_onBegin();
		
		m_editor.m_statusbar.m_toolHelpText = "Left drag to rotate. Right drag to flat pan (XY). Left + Right drag to camera pan (XYZ)."
		
		// Limit the mouse position to inside the window:
		Screen.limitMouse = true;
	};
	Parent_onEnd = onEnd;
	onEnd = function(trueEnd)
	{
		Parent_onEnd(trueEnd);
		
		// Disable limiting the mouse position to inside the window:
		Screen.limitMouse = false;
	};
	
	onStep = function()
	{
		var bMouseLeft = m_mouseLeft;
		var bMouseRight = m_mouseRight;
		var bMouseMiddle = m_mouseMiddle;
		
		with (m_editor)
		{
			if ((bMouseLeft && !bMouseRight) || (bMouseMiddle && !bMouseLeft && !bMouseRight))
			{
				cameraRotZ -= (uPosition - uPositionPrevious) * 0.2;
				cameraRotY += (vPosition - vPositionPrevious) * 0.2;
			}
			else if (bMouseRight && !bMouseLeft)
			{
				cameraX += lengthdir_x((vPosition - vPositionPrevious), cameraRotZ)
						 + lengthdir_y((uPosition - uPositionPrevious), cameraRotZ);
				 
				cameraY += lengthdir_y((vPosition - vPositionPrevious), cameraRotZ)
						 - lengthdir_x((uPosition - uPositionPrevious), cameraRotZ);
			}
			else if (bMouseLeft && bMouseRight)
			{
				//cameraZoom += (vPosition - vPositionPrevious) / 500.0;
				var cameraPos = new Vector3(cameraX, cameraY, cameraZ);
				
				// Create the forward vector
				var cameraDir = Vector3FromArray(o_Camera3D.m_viewForward);
				var cameraTop = Vector3FromArray(o_Camera3D.m_viewUp);
				var cameraSide = cameraDir.cross(cameraTop).normal();
				
				// Perform the movement
				cameraPos.addSelf(
					cameraSide
						.multiply(uPosition - uPositionPrevious)
						.add(
							cameraTop.multiply(vPosition - vPositionPrevious)
							)
					);
				
				// Save out result
				cameraX = cameraPos.x;
				cameraY = cameraPos.y;
				cameraZ = cameraPos.z;
				
				// Explicitly delete temp calc structures
				delete cameraPos;
				delete cameraDir;
				delete cameraSide;
				delete cameraTop;
			}
			
			/*if (mouse_wheel_down())
			{
				cameraZoom += 0.1;
			}
			else if (mouse_wheel_up())
			{
				cameraZoom -= 0.1;
			}*/ // Duplicate action, already hardcoded in the shortcuts.
		}
	}
	onClickWorld = function(button, buttonState, screenPosition, worldPosition)
	{
		if (buttonState == kEditorToolButtonStateMake)
		{
			if (button == mb_left)
				m_mouseLeft = true;
			else if (button == mb_right)
				m_mouseRight = true;
			else if (button = mb_middle)
				m_mouseMiddle = true;
		}
		else if (buttonState == kEditorToolButtonStateBreak)
		{	
			if (button == mb_left)
				m_mouseLeft = false;
			else if (button == mb_right)
				m_mouseRight = false;
			else if (button = mb_middle)
				m_mouseMiddle = false;
		}
	};
}