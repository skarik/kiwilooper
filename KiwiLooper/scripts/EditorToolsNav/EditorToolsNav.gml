/// @function AEditorToolStateSelect() constructor
function AEditorToolStateSelect() : AEditorToolState() constructor
{
	state = kEditorToolSelect;
	
	kDragAreaThreshold = 3.0;
	m_leftClickDrag = false;
	m_leftClickStart = new Vector2(0, 0);
	m_leftClickEnd = new Vector2(0, 0);
	m_leftClickDragArea = 0;
	
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
		if (array_length(m_editor.m_selection) > 0)
		{
			m_showSelectGizmo.SetVisible();
			m_showSelectGizmo.SetEnabled();
			
			// TODO: Loop through all the ents in the selection and put a box around each one.
			// TODO: Selection may not be an object, and may be a struct instead. Also check for that.
			
			var iSelection = 0;
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
					
					m_showSelectGizmo.m_mins[0] = propBBox.getMin();
					m_showSelectGizmo.m_maxes[0] = propBBox.getMax();
					m_showSelectGizmo.m_trses[0] = matrix_multiply(propRotation, propTranslation);
				}
				else if (selection.type == kEditorSelection_Splat)
				{
					var splat = selection.object;
					
					// get the bbox
					var splatBBox = SplatGetBBox(splat);
					var splatTranslation = matrix_build_translation(splat);
					var splatRotation = matrix_build_rotation(splat);
			
					splatBBox.extents.multiplyComponentSelf(Vector3FromScale(splat));
					
					m_showSelectGizmo.m_mins[0] = splatBBox.getMin();
					m_showSelectGizmo.m_maxes[0] = splatBBox.getMax();
					m_showSelectGizmo.m_trses[0] = matrix_multiply(splatRotation, splatTranslation);
				}
				// todo: tiles
				else if (selection.type == kEditorSelection_Tile)
				{
					var tile = selection.object;
					
					// todo
					m_showSelectGizmo.m_mins[0]  = new Vector3(tile.x * 16,		 tile.y * 16,	   -16)				.add(new Vector3(-0.5, -0.5, -0.5));
					m_showSelectGizmo.m_maxes[0] = new Vector3(tile.x * 16 + 16, tile.y * 16 + 16, tile.height * 16).add(new Vector3( 0.5,  0.5,  0.5));
					m_showSelectGizmo.m_trses[0] = matrix_build_identity();
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
				
				m_showSelectGizmo.m_mins[0] = new Vector3(entCenter.x - entHSize.x, entCenter.y - entHSize.y, entCenter.z - entHSize.z);
				m_showSelectGizmo.m_maxes[0] = new Vector3(entCenter.x + entHSize.x, entCenter.y + entHSize.y, entCenter.z + entHSize.z);
				m_showSelectGizmo.m_trses[0] = matrix_build_identity();
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
					PickerRun();
				}
				else
				{
					// todo
				}
			}
		}
	};
	
	/// @function PickerRun()
	/// @desc Runs the picker.
	static PickerRun = function()
	{
		m_editor.m_selection = [];
		m_editor.m_selectionSingle = true;
		
		var pixelX = m_editor.uPosition - GameCamera.view_x;
		var pixelY = m_editor.vPosition - GameCamera.view_y;
		
		// Get a ray
		var rayStart = new Vector3(o_Camera3D.x, o_Camera3D.y, o_Camera3D.z);
		var rayDir = Vector3FromArray(o_Camera3D.viewToRay(pixelX, pixelY));
		
		// Run through the ent table
		var closestEnt = null;
		var closestDist = 10000 * 10000.0;
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
				
				if (raycast4_box(new Vector3(entCenter.x - entHSize.x, entCenter.y - entHSize.y, entCenter.z - entHSize.z),
								 new Vector3(entCenter.x + entHSize.y, entCenter.y + entHSize.y, entCenter.z + entHSize.z),
								 rayStart, rayDir))
				{
					if (raycast4_get_hit_distance() < closestDist)
					{
						closestDist = raycast4_get_hit_distance();
						closestEnt = ent;
					}
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
			
			var propBBoxMinPushed = propBBox.getMin().transformAMatrix(propTranslation);
			var propBBoxMaxPushed = propBBox.getMax().transformAMatrix(propTranslation);
			
			// TODO: rotation. rotation needs to be passed into raycast4_box_ext, to rotate the ray in the world
			
			//if (raycast4_box(propBBoxMinPushed, propBBoxMaxPushed, rayStart, rayDir))
			if (raycast4_box_rotated(
				propBBox.center.add(Vector3FromTranslation(prop)),
				propBBox.extents.multiplyComponent(Vector3FromScale(prop)),
				propRotation,
				true,
				rayStart, rayDir))
			{
				if (raycast4_get_hit_distance() < closestDist)
				{
					closestDist = raycast4_get_hit_distance();
					closestEnt = EditorSelectionWrapProp(prop);
				}
			}
		}
		
		// Run through all splats
		for (var splatIndex = 0; splatIndex < m_editor.m_splatmap.GetSplatCount(); ++splatIndex)
		{
			var splat = m_editor.m_splatmap.GetSplat(splatIndex);
			
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
				if (raycast4_get_hit_distance() < closestDist)
				{
					closestDist = raycast4_get_hit_distance();
					closestEnt = EditorSelectionWrapSplat(splat);
				}
			}
		}
		
		// Run against the terrain
		if (raycast4_tilemap(rayStart, rayDir))
		{
			//closestDist = raycast4_get_hit_distance();
			if (raycast4_get_hit_distance() < closestDist)
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
			
				var tile_index = m_editor.m_tilemap.GetPositionIndex(blockX, blockY);
				if (tile_index != -1)
				{
					closestDist = raycast4_get_hit_distance();
					closestEnt = EditorSelectionWrapTile(m_editor.m_tilemap.tiles[tile_index]);
				}
			}
		}
		
		// If we hit something, save it
		if (is_struct(closestEnt) || closestEnt != null)
		{
			m_editor.m_selection[0] = closestEnt;
		}
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
				var cameraDir = new Vector3(
					lengthdir_x(1.0, o_Camera3D.zrotation) * lengthdir_x(1.0, o_Camera3D.yrotation), 
					lengthdir_y(1.0, o_Camera3D.zrotation) * lengthdir_x(1.0, o_Camera3D.yrotation), 
					lengthdir_y(1.0, o_Camera3D.yrotation));
				var cameraSide = cameraDir.cross(new Vector3(0, 0, 1)).normal();
				var cameraTop = cameraSide.cross(cameraDir).normal();
				
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