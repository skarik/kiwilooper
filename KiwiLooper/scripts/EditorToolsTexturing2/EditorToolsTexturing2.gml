/// @function AEditorToolStateTextureSolids() constructor
function AEditorToolStateTextureSolids() : AEditorToolState() constructor
{
	state = kEditorToolTextureSolids;
	m_gizmo = null;
	m_windowBrowser = null;
	m_lastSelectedTile = null;
	m_lastSelectedFace = null;
	
	onBegin = function()
	{
		if (m_windowBrowser == null)
		{
			m_windowBrowser = EditorWindowAlloc(AEditorWindowTextureBrowser);
			m_windowBrowser.InitTextureListing();
		}
		m_windowBrowser.Open();
		EditorWindowSetFocus(m_windowBrowser);
		
		m_editor.m_statusbar.m_toolHelpText = "Click to select faces to edit. Right click to apply selected texture. Ctrl+Action to multi-action.";
		
		// set up minimenu
		m_editor.m_minimenu.Initialize();
		m_editor.m_minimenu.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 3, "Align To World", null, method(self, UVAlignToWorld), null));
		m_editor.m_minimenu.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 4, "Align To Face", null, method(self, UVAlignToFace), null));
		//m_editor.m_minimenu.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 5, "Align To View", null, method(self, UVAlignToView), null));
		//m_editor.m_minimenu.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 6, "Align Unwrap", null, method(self, UVAlignUnwrap), null));
		m_editor.m_minimenu.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 0, "Rotate", null, function(){
				for (var iSelection = 0; iSelection < array_length(m_editor.m_selection); ++iSelection)
				{
					var selection = m_editor.m_selection[iSelection];
					if (!is_struct(selection) || selection.type != kEditorSelection_Primitive || selection.object.face == null)
						continue;
						
					selection.object.primitive.faces[selection.object.face].uvinfo.rotation += 90;
				}
				TextureUpdateMapVisuals(); // TODO: only update the selected solids
				}, null));
		m_editor.m_minimenu.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 2, "Flip X", null, function(){
				for (var iSelection = 0; iSelection < array_length(m_editor.m_selection); ++iSelection)
				{
					var selection = m_editor.m_selection[iSelection];
					if (!is_struct(selection) || selection.type != kEditorSelection_Primitive || selection.object.face == null)
						continue;
					
					var scale = selection.object.primitive.faces[selection.object.face].uvinfo.scale;
					scale.x = -scale.x;
				}
				TextureUpdateMapVisuals(); // TODO: only update the selected solids
				}, null));
		m_editor.m_minimenu.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 1, "Flip Y", null, function(){
				for (var iSelection = 0; iSelection < array_length(m_editor.m_selection); ++iSelection)
				{
					var selection = m_editor.m_selection[iSelection];
					if (!is_struct(selection) || selection.type != kEditorSelection_Primitive || selection.object.face == null)
						continue;
					
					var scale = selection.object.primitive.faces[selection.object.face].uvinfo.scale;
					scale.y = -scale.y;
				}
				TextureUpdateMapVisuals(); // TODO: only update the selected solids
				}, null));
		m_editor.m_minimenu.Show();
	};
	onEnd = function(trueEnd)
	{
		if (trueEnd)
		{
			//m_gizmo.SetDisabled();
			//m_gizmo.SetInvisible();
			
			//m_editor.EditorWindowFree(m_window);
			//m_window = null;
			EditorWindowFree(m_windowBrowser);
			m_windowBrowser = null;
		}
		m_editor.m_minimenu.Hide();
		
		m_lastSelectedTile = null;
	};
	
	onStep = function()
	{
		// Update picker visuals:
		PickerUpdateVisuals();
		
		// On selection, update the button position
		if (array_length(m_editor.m_selection) > 0)
		{
			var recent_object = m_editor.m_selection[array_length(m_editor.m_selection)-1];
			/*if (is_struct(recent_object) && recent_object.type == kEditorSelection_TileFace)
			{
				// Update the window position (TODO: save status elswhere & hide when nonselected)
				m_editor.m_minimenu.SetCenterPosition3D(
					recent_object.object.tile.x * 16 + 8 + 8 * recent_object.object.normal.x,
					recent_object.object.tile.y * 16 + 8 + 8 * recent_object.object.normal.y,
					recent_object.object.tile.height * 16 - 8 + 8 * recent_object.object.normal.z);
			}
			else*/
			if (is_struct(recent_object) && recent_object.type == kEditorSelection_Primitive)
			{
				// Update the window position
				var bbox;
				if (recent_object.object.face == null)
					bbox = recent_object.object.primitive.GetBBox();
				else
					bbox = recent_object.object.primitive.GetFaceBBox(recent_object.object.face);
					
				// Get bbox min & max positions in 2D
				var pos = array_create(8);
				pos[0] = o_Camera3D.positionToView(bbox.center.x - bbox.extents.x, bbox.center.y - bbox.extents.y, bbox.center.z - bbox.extents.z);
				pos[1] = o_Camera3D.positionToView(bbox.center.x + bbox.extents.x, bbox.center.y - bbox.extents.y, bbox.center.z - bbox.extents.z);
				pos[2] = o_Camera3D.positionToView(bbox.center.x - bbox.extents.x, bbox.center.y + bbox.extents.y, bbox.center.z - bbox.extents.z);
				pos[3] = o_Camera3D.positionToView(bbox.center.x + bbox.extents.x, bbox.center.y + bbox.extents.y, bbox.center.z - bbox.extents.z);
				pos[4] = o_Camera3D.positionToView(bbox.center.x - bbox.extents.x, bbox.center.y - bbox.extents.y, bbox.center.z + bbox.extents.z);
				pos[5] = o_Camera3D.positionToView(bbox.center.x + bbox.extents.x, bbox.center.y - bbox.extents.y, bbox.center.z + bbox.extents.z);
				pos[6] = o_Camera3D.positionToView(bbox.center.x - bbox.extents.x, bbox.center.y + bbox.extents.y, bbox.center.z + bbox.extents.z);
				pos[7] = o_Camera3D.positionToView(bbox.center.x + bbox.extents.x, bbox.center.y + bbox.extents.y, bbox.center.z + bbox.extents.z);
				
				var min_x = pos[0][0];
				var min_y = pos[0][1];
				var max_x = min_x;
				var max_y = min_y;
				
				for (var i = 1; i < 8; ++i)
				{
					if (pos[i][2] > 0.0)
					{
						min_x = min(pos[i][0], min_x);
						min_y = min(pos[i][1], min_y);
						max_x = max(pos[i][0], max_x);
						max_y = max(pos[i][1], max_y);
					}
				}
				
				// Set minimenu below the face
				m_editor.m_minimenu.SetCenterPosition((min_x + max_x) * 0.5, max_y);
			}
			else
			{
				m_editor.m_minimenu.Hide();
			}
		}
		else
		{
			m_editor.m_minimenu.Hide();
		}
	};
	
	onClickWorld = function(button, buttonState, screenPosition, worldPosition)
	{
		if (buttonState == kEditorToolButtonStateMake)
		{
			// Left click select.
			if (button == mb_left)
			{
				PickerRun(keyboard_check(vk_control), false);

				// Reset last selected tile
				m_lastSelectedTile = null;

				// On selection, update the browser to select the correct texture
				if (array_length(m_editor.m_selection) > 0)
				{
					/*var recent_object = m_editor.m_selection[array_length(m_editor.m_selection)-1];
					if (is_struct(recent_object) && recent_object.type == kEditorSelection_TileFace)
					{
						m_windowBrowser.SetUsedTile(
							(abs(recent_object.object.normal.z) > 0.707)
							? recent_object.object.tile.floorType
							: recent_object.object.tile.wallType);
							
						// (Also save the selected tile)
						m_lastSelectedTile = recent_object.object.tile;
					}*/
					var recent_object = m_editor.m_selection[array_length(m_editor.m_selection)-1];
					if (is_struct(recent_object) && recent_object.type == kEditorSelection_Primitive)
					{
						// TODO
						m_lastSelectedFace = recent_object.object.primitive.faces[recent_object.object.face];
					}
				}
			}
			
			// Right click apply texture.
			if (button == mb_right)
			{
				if (!keyboard_check(vk_control))
				{
					var selection = PickerRun(false, true);
					/*if (is_struct(selection) && selection.type == kEditorSelection_TileFace)
					{
						if (TextureApplyToSelectObject(selection))
						{
							TextureUpdateMapVisuals();
						}
					}
					else */if (is_struct(selection) && selection.type == kEditorSelection_Primitive)
					{
						if (TextureApplyToSelectObject(selection))
						{
							TextureUpdateMapVisuals();
						}
					}
				}
				else
				{
					TextureApplyToSelection();
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
			
			if (array_length(m_showSelectGizmo.m_mins) != array_length(m_editor.m_selection))
			{
				m_showSelectGizmo.m_mins = [];
				m_showSelectGizmo.m_maxes = [];
				m_showSelectGizmo.m_trses = [];
			}
			
			var gizmoIndex = 0;
			for (var iSelection = 0; iSelection < array_length(m_editor.m_selection); ++iSelection)
			{
				var selection = m_editor.m_selection[iSelection];
			
				/*if (is_struct(selection) && selection.type == kEditorSelection_TileFace)
				{
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
				else*/ if (is_struct(selection) && selection.type == kEditorSelection_Primitive)
				{
					if (selection.object.face != null)
					{
						// Get the face bbox
						var faceBBox = selection.object.primitive.GetFaceBBox(selection.object.face);
						faceBBox.extents.x += 1;
						faceBBox.extents.y += 1;
						faceBBox.extents.z += 1;
					
						m_showSelectGizmo.m_mins[gizmoIndex]  = faceBBox.getMin();
						m_showSelectGizmo.m_maxes[gizmoIndex] = faceBBox.getMax();
						m_showSelectGizmo.m_trses[gizmoIndex] = undefined;
						gizmoIndex++;
					}
				}
			}
		}
		else
		{
			m_showSelectGizmo.SetInvisible();
			m_showSelectGizmo.SetDisabled();
		}
	};
	
	/// @function PickerRun(additive, transitive_check)
	/// @desc Runs the picker.
	static PickerRun = function(bAdditive, bTransitiveCheck)
	{
		if (!bAdditive && !bTransitiveCheck)
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
		var hitObjects = [];
		var hitDists = [];
		var hitCount = EditorPickerCast2(rayStart, rayDir, hitObjects, hitDists, kPickerHitMaskTilemap, true);
		if (hitCount > 0)
		{
			if (!bTransitiveCheck)
			{
				// Update selection!
				m_editor.m_selection[array_length(m_editor.m_selection)] = hitObjects[0];//EditorSelectionWrapTileFace(m_editor.m_tilemap.tiles[tile_index], hitNormal);
				m_editor.m_selectionSingle = array_length(m_editor.m_selection) <= 1;
			}
			else
			{
				return hitObjects[0];//EditorSelectionWrapTileFace(m_editor.m_tilemap.tiles[tile_index], hitNormal);
			}
		}
		
		return null;
	};
	
	/// @function TextureApplyToSelectObject(selection)
	/// @desc Apply texture changes to the given selection.
	/// @returns True when texture has changed. False otherwise.
	static TextureApplyToSelectObject = function(selection)
	{
		var bHasAlignmentChange = false;
		
		// Pull the selected texture from the browser and apply it (if valid)
		//var new_tile = m_windowBrowser.GetCurrentTile();
		var new_texture = m_windowBrowser.GetCurrentTexture();
		
		// Apply the texture now
		/*if (is_struct(selection) && selection.type == kEditorSelection_TileFace)
		{
			// Apply the turns
			if (is_struct(m_lastSelectedTile))
			{
				if (m_lastSelectedTile.floorRotate90 != selection.object.tile.floorRotate90
					|| m_lastSelectedTile.floorFlipX != selection.object.tile.floorFlipX
					|| m_lastSelectedTile.floorFlipY != selection.object.tile.floorFlipY
					)
					{
						selection.object.tile.floorRotate90 = m_lastSelectedTile.floorRotate90;
						selection.object.tile.floorFlipX = m_lastSelectedTile.floorFlipX;
						selection.object.tile.floorFlipY = m_lastSelectedTile.floorFlipY;
						
						bHasAlignmentChange = true;
					}
			}
			
			// Apply texture changes
			if (abs(selection.object.normal.z) > 0.707)
			{
				var old_tile = selection.object.tile.floorType;
				if (old_tile != new_tile)
				{
					selection.object.tile.floorType = new_tile;0
					return true;
				}
			}
			else
			{
				var old_tile = selection.object.tile.wallType;
				if (old_tile != new_tile)
				{
					selection.object.tile.wallType = new_tile;
					return true;
				}
			}
		}
		else */
		if (is_struct(selection) && selection.type == kEditorSelection_Primitive)
		{
			// Apply texture changes
			var face = selection.object.primitive.faces[selection.object.face];
		
			face.texture.type = new_texture.type;
			face.texture.index = new_texture.index;
			if (face.texture.type == kTextureTypeTexture)
			{	// Copy over the filename. Let resource system handle the rest.
				face.texture.source = new_texture.filename;
			}
			else
			{	// Pull the sprite directly
				face.texture.source = new_texture.resource.sprite;
			}
			
			
			// TOOD: normally these would be pulled from the tool's current UV settings but since we dont have that yet, we just copy
			if (is_struct(m_lastSelectedFace))
			{
				//face.uvinfo.
				if (m_lastSelectedFace.uvinfo.mapping == kSolidMappingWorld)
					UVAlignToWorld(selection);
				else if (m_lastSelectedFace.uvinfo.mapping == kSolidMappingFace)
					UVAlignToFace(selection);
					
				face.uvinfo.scale.x = m_lastSelectedFace.uvinfo.scale.x;
				face.uvinfo.scale.y = m_lastSelectedFace.uvinfo.scale.y;
				face.uvinfo.offset.x = m_lastSelectedFace.uvinfo.offset.x;
				face.uvinfo.offset.y = m_lastSelectedFace.uvinfo.offset.y;
				face.uvinfo.rotation = m_lastSelectedFace.uvinfo.rotation;
			}
			
			return true;
		}
		return bHasAlignmentChange;
	}
	
	static UVAlignToWorld = function(input_selection=undefined)
	{
		for (var iSelection = 0; iSelection < array_length(m_editor.m_selection); ++iSelection)
		{
			var selection = m_editor.m_selection[iSelection];
			if (!is_struct(selection) || selection.type != kEditorSelection_Primitive)
				continue;
			
			// Only work on faces
			if (selection.object.face == null)
				continue;
			
			var mapSolid = selection.object.primitive;
			var face = mapSolid.faces[selection.object.face];
			
			// Create an array of positions
			var face_positions = array_create(array_length(face.indicies));
			for (var indexIndex = 0; indexIndex < array_length(face.indicies); ++indexIndex)
			{
				face_positions[indexIndex] = mapSolid.vertices[face.indicies[indexIndex]].position;
			}
			// Generate normals based on the edges' relation
			// We can cheat and just do two spokes:
			var edge0 = face_positions[1].subtract(face_positions[0]);
			var edge1 = face_positions[2].subtract(face_positions[0]);
			var normal = edge0.cross(edge1);
			var longest_axis = 
				(abs(normal.x) > abs(normal.y)) 
					? ((abs(normal.x) > abs(normal.z)) ? kAxisX : kAxisZ)
					: ((abs(normal.y) > abs(normal.z)) ? kAxisY : kAxisZ);
			
			// Now, fulfill the normal used for the texcoords
			face.uvinfo.normal.x = (longest_axis == kAxisX) ? 1.0 : 0.0;
			face.uvinfo.normal.y = (longest_axis == kAxisY) ? 1.0 : 0.0;
			face.uvinfo.normal.z = (longest_axis == kAxisZ) ? 1.0 : 0.0;
			face.uvinfo.mapping = kSolidMappingWorld;
		}
		
		// Ask for map to update visuals now
		TextureUpdateMapVisuals(); // TODO: only update the selected solids
	}
	static UVAlignToFace = function(input_selection=undefined)
	{
		for (var iSelection = 0; iSelection < array_length(m_editor.m_selection); ++iSelection)
		{
			var selection = m_editor.m_selection[iSelection];
			if (!is_struct(selection) || selection.type != kEditorSelection_Primitive)
				continue;
			
			// Only work on faces
			if (selection.object.face == null)
				continue;
			
			var mapSolid = selection.object.primitive;
			var face = mapSolid.faces[selection.object.face];
			
			// Create an array of positions
			var face_positions = array_create(array_length(face.indicies));
			for (var indexIndex = 0; indexIndex < array_length(face.indicies); ++indexIndex)
			{
				face_positions[indexIndex] = mapSolid.vertices[face.indicies[indexIndex]].position;
			}
			// Generate normals based on the edges' relation
			// We can cheat and just do two spokes:
			var edge0 = face_positions[1].subtract(face_positions[0]);
			var edge1 = face_positions[2].subtract(face_positions[0]);
			var normal = edge0.cross(edge1);
			normal.normalize(); // And we're not aligned to world, so we just use this normal as our basis.
			
			// Now, fulfill the normal used for the texcoords
			face.uvinfo.normal.copyFrom(normal);
			face.uvinfo.mapping = kSolidMappingFace;
		}
		
		// Ask for map to update visuals now
		TextureUpdateMapVisuals(); // TODO: only update the selected solids
	}
	static UVAlignToView = function(input_selection=undefined)
	{
		// TODO.
	}
	static UVAlignUnwrap = function(input_selection=undefined)
	{
		// TODO.
	}
	
	static TextureApplyToSelection = function()
	{
		var bRequestRebuild = false;
		
		// Get current tile:
		for (var i = 0; i < array_length(m_editor.m_selection); ++i)
		{
			var selection = m_editor.m_selection[i];
			if (TextureApplyToSelectObject(selection))
			{
				bRequestRebuild = true;
			}
		}
		
		// rebuild if changes have occurred
		if (bRequestRebuild)
		{
			TextureUpdateMapVisuals();
		}
	}
	
	static TextureUpdateMapVisuals = function(solid_list = undefined)
	{
		// Mark geometry as changed.
		EditorGlobalMarkDirtyGeometry();
		
		with (m_editor)
		{
			if (is_undefined(solid_list))
			{
				//MapRebuildGraphics();
				MapRebuildSolidsOnly();
			}
			else
			{
				for (var i = 0; i < array_length(solid_list); ++i)
				{
					//MapRebuildSolidsOnly(solid_list[i]);
					EditorGlobalSignalTransformChange(solid_list[i], kEditorSelection_Primitive, kValueTypeString, true); // Defer to later in the frame.
				}
			}
		}
	}
}