/// @function AEditorToolStateTexturing() constructor
function AEditorToolStateTexturing() : AEditorToolState() constructor
{
	state = kEditorToolTexture;
	m_gizmo = null;
	//m_window = null;
	m_windowBrowser = null;
	
	onBegin = function()
	{
		//m_gizmo = m_editor.EditorGizmoGet(AEditorGizmoFlatGridCursorBox);
		/*m_gizmo = m_editor.EditorGizmoGet(AEditorGizmo3DEditBox);
		m_gizmo.SetVisible();
		m_gizmo.SetEnabled();
		m_gizmo.m_color = c_gold;
		m_gizmo.m_alpha = 0.75;*/
		
		/*if (m_window == null)
		{
			m_window = m_editor.EditorWindowAlloc(AEditorWindowTextureApplier); // TODO: No window. use the tiny menu!
		}*/
		if (m_windowBrowser == null)
		{
			m_windowBrowser = m_editor.EditorWindowAlloc(AEditorWindowTileBrowser);
		}
		m_windowBrowser.InitTileListing();
		m_editor.EditorWindowSetFocus(m_windowBrowser);
		
		m_editor.m_statusbar.m_toolHelpText = "Click to select faces to edit. Right click to apply selected texture.";
	};
	onEnd = function(trueEnd)
	{
		if (trueEnd)
		{
			//m_gizmo.SetDisabled();
			//m_gizmo.SetInvisible();
			
			//m_editor.EditorWindowFree(m_window);
			//m_window = null;
			m_editor.EditorWindowFree(m_windowBrowser);
			m_windowBrowser = null;
		}
	};
	
	onStep = function()
	{
		// Update picker visuals:
		PickerUpdateVisuals();
	};
	
	onClickWorld = function(button, buttonState, screenPosition, worldPosition)
	{
		/*if (buttonState == kEditorToolButtonStateMake)
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
		}*/
		if (buttonState == kEditorToolButtonStateMake)
		{
			if (button == mb_left)
			{
				PickerRun(false);

				// On selection, update the browser to select the correct texture
				if (array_length(m_editor.m_selection) > 0)
				{
					var recent_object = m_editor.m_selection[array_length(m_editor.m_selection)-1];
					if (is_struct(recent_object) && recent_object.type == kEditorSelection_TileFace)
					{
						m_windowBrowser.SetCurrentTile(
							(abs(recent_object.object.normal.z) > 0.707)
							? recent_object.object.tile.floorType
							: recent_object.object.tile.wallType);
					}
				}
			}
		}
	};
	
	/// @function PickerUpdateVisuals()
	/// @desc Updates the picker's selection box visuals. This is done via gizmo.
	static PickerUpdateVisuals = function()
	{
		m_showSelectGizmo = m_editor.EditorGizmoGet(AEditorGizmoMultiSelectBox3D);
		// Draw the box around the picker
		if (array_length(m_editor.m_selection) > 0)
		{
			m_showSelectGizmo.SetVisible();
			m_showSelectGizmo.SetEnabled();
			
			var gizmoIndex = 0;
			for (var iSelection = 0; iSelection < array_length(m_editor.m_selection); ++iSelection)
			{
				var selection = m_editor.m_selection[iSelection];
			
				if (is_struct(selection) && selection.type == kEditorSelection_TileFace)
				{
					var prop = selection.object;
					
					// get the center of the tile
					var tile = selection.object.tile;
					var tileCenter = new Vector3(tile.x * 16 + 8, tile.y * 16 + 8, tile.height * 16 - 8);
					// get center of the face
					var faceNormal = selection.object.normal;
					var faceCenter = tileCenter.add(faceNormal.multiply(9.0));
					
					// get the left & right ways to expand the selection box
					var faceTangent = faceNormal.cross(new Vector3(1, 0, 0));
					if (faceTangent.sqrMagnitude() <= KINDA_SMALL_NUMBER)
					{
						faceTangent = faceNormal.cross(new Vector3(0, 0, 1));
					}
					var faceBinormal = faceTangent.cross(faceNormal);
					
					// create the bbbox
					var tileBBox = new BBox3(faceCenter, faceNormal.add(faceTangent.multiply(9.0).add(faceBinormal.multiply(9.0))));
					tileBBox.extents.x = abs(tileBBox.extents.x);
					tileBBox.extents.y = abs(tileBBox.extents.y);
					tileBBox.extents.z = abs(tileBBox.extents.z);
					
					m_showSelectGizmo.m_mins[gizmoIndex]  = tileBBox.getMin();
					m_showSelectGizmo.m_maxes[gizmoIndex] = tileBBox.getMax();
					m_showSelectGizmo.m_trses[gizmoIndex] = undefined;
					gizmoIndex++;
				}
			}
		}
		else
		{
			m_showSelectGizmo.SetInvisible();
			m_showSelectGizmo.SetDisabled();
		}
	};
	
	/// @function PickerRun(additive)
	/// @desc Runs the picker.
	static PickerRun = function(bAdditive)
	{
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
		
		// Do picker collision with the map
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
			
			var tile_index = m_editor.m_tilemap.GetPositionIndex(blockX, blockY);
			if (tile_index != -1)
			{
				// Update selection!
				m_editor.m_selection[array_length(m_editor.m_selection)] = EditorSelectionWrapTileFace(m_editor.m_tilemap.tiles[tile_index], hitNormal);
				m_editor.m_selectionSingle = array_length(m_editor.m_selection) <= 1;
			}
		}
	};
	
	
	static TextureApplyToSelection = function()
	{
		var bRequestRebuild = false;
		
		// Pull the selected texture from the browser and apply it (if valid)
		var new_tile = m_windowBrowser.GetCurrentTile();
		
		// Get current tile:
		for (var i = 0; i < array_length(m_editor.m_selection); ++i)
		{
			var selection = m_editor.m_selection[i];
			if (is_struct(selection) && selection.type == kEditorSelection_TileFace)
			{
				if (abs(selection.object.normal.z) > 0.707)
				{
					var old_tile = selection.object.tile.floorType;
					if (old_tile != new_tile)
					{
						bRequestRebuild = true;
						selection.object.tile.floorType = new_tile;
					}
				}
				else
				{
					var old_tile = selection.object.tile.wallType;
					if (old_tile != new_tile)
					{
						bRequestRebuild = true;
						selection.object.tile.wallType = new_tile;
					}
				}
			}
		}
		
		// rebuild if changes have occurred
		if (bRequestRebuild)
		{
			with (m_editor)
			{
				MapRebuildGraphics();
			}
		}
	}
}