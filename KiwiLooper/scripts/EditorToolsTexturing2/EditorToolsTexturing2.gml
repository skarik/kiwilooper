/// @function AEditorToolStateTextureSolids() constructor
function AEditorToolStateTextureSolids() : AEditorToolState() constructor
{
	state = kEditorToolTextureSolids;
	m_gizmo = null;
	m_windowBrowser = null;
	m_windowTextureTools = null;
	m_lastSelectedTile = null;
	m_lastSelectedFace = null;
	
	onBegin = function()
	{
		if (m_windowBrowser == null)
		{
			m_windowBrowser = EditorWindowAlloc(AEditorWindowTextureBrowser);
			m_windowBrowser.InitTextureListing();
		}
		m_windowBrowser.m_toolstate = self;
		m_windowBrowser.Open();
		m_windowBrowser.SetCurrentTexture(m_editor.toolTextureInfo);
		m_windowBrowser.SetUsedTexture(m_editor.toolTextureInfo);
		
		if (m_windowTextureTools == null)
		{
			m_windowTextureTools = EditorWindowAlloc(AEditorWindowTextureTools);
		}
		m_windowTextureTools.m_toolstate = self;
		m_windowTextureTools.Open();
		
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
			
			EditorWindowFree(m_windowTextureTools);
			m_windowTextureTools = null;
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
				
				// Update the tool texture info
				{
					var mapSolid = recent_object.object.primitive;
					var face = mapSolid.faces[recent_object.object.face];
					
					m_editor.toolTextureInfo.scale.copyFrom(face.uvinfo.scale);
					m_editor.toolTextureInfo.offset.copyFrom(face.uvinfo.offset);
					m_editor.toolTextureInfo.rotation = face.uvinfo.rotation;
					
					// TODO: mapping
				}
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
				/*if (!keyboard_check(vk_control))
				{
					var selection = PickerRun(false, true);
					if (is_struct(selection) && selection.type == kEditorSelection_Primitive)
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
				}*/
				var selection = PickerRun(false, true);
				if (is_struct(selection) && selection.type == kEditorSelection_Primitive)
				{
					if (TextureApplyToSelectObject(selection) || UVApplyToSelectObject(selection))
					{
						TextureUpdateMapVisuals();
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
				
				if (is_struct(selection) && selection.type == kEditorSelection_Primitive)
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
		var bHasTextureChange = false;
		var new_texture = m_editor.toolTextureInfo;
		
		if (is_struct(selection) && selection.type == kEditorSelection_Primitive)
		{
			var face = selection.object.primitive.faces[selection.object.face];
		
			if (face.texture.type != new_texture.type
				|| face.texture.index != new_texture.index
				|| face.texture.source != new_texture.source
				//|| (face.texture.type == kTextureTypeTexture && face.texture.source != new_texture.source)
				//|| (face.texture.type != kTextureTypeTexture && face.texture.source != new_texture.source)
				)
			{
				bHasTextureChange = true;
				
				face.texture.type = new_texture.type;
				face.texture.index = new_texture.index;
				if (face.texture.type == kTextureTypeTexture)
				{	// Copy over the filename. Let resource system handle the rest.
					face.texture.source = new_texture.source; // TODO: check??
				}
				else
				{	// Pull the sprite directly
					face.texture.source = new_texture.source; // TODO: check??
				}
			}
		}
		return bHasTextureChange;
	}
	/// @function UVApplyToSelectObject(selection)
	/// @desc Apply texture changes to the given selection.
	static UVApplyToSelectObject = function(selection)
	{
		var bHasTextureChange = false;
		//var new_texture = m_editor.toolTextureInfo;
		var new_alignment = m_editor.toolTextureInfo;
		
		if (is_struct(selection) && selection.type == kEditorSelection_Primitive)
		{
			var face = selection.object.primitive.faces[selection.object.face];
			
			if ((face.uvinfo.mapping == kSolidMappingNormal && face.uvinfo.normal.equals(new_alignment.normal))
				|| face.uvinfo.mapping != new_alignment.mapping
				|| face.uvinfo.scale.x != new_alignment.scale.x || face.uvinfo.scale.y != new_alignment.scale.y
				|| face.uvinfo.offset.x != new_alignment.offset.x || face.uvinfo.offset.y != new_alignment.offset.y
				|| face.uvinfo.rotation != new_alignment.rotation)
			{
				bHasTextureChange = true;
				
				if (new_alignment.mapping == kSolidMappingWorld)
					UVAlignToWorld(selection);
				else if (new_alignment.mapping == kSolidMappingFace)
					UVAlignToFace(selection);
				else if (new_alignment.mapping == kSolidMappingNormal)
				{ 
					face.uvinfo.normal.x = new_alignment.normal.x;
					face.uvinfo.normal.y = new_alignment.normal.y;
					face.uvinfo.normal.z = new_alignment.normal.z;
				}
					
				face.uvinfo.scale.x = new_alignment.scale.x;
				face.uvinfo.scale.y = new_alignment.scale.y;
				face.uvinfo.offset.x = new_alignment.offset.x;
				face.uvinfo.offset.y = new_alignment.offset.y;
				face.uvinfo.rotation = new_alignment.rotation;
			}
		}
		return bHasTextureChange;
	}
	
	// ========================================================================
	// UV Tools
	// ========================================================================
	
	// Helper for the common iteration thru faces.
	static UV_ForEachFaceIn = function(input_selection, relevant_selection, params, task)
	{
		var solidsEdited = [];
		
		var selectionArray = is_undefined(input_selection) ? relevant_selection : input_selection;
		
		for (var iSelection = 0; iSelection < array_length(selectionArray); ++iSelection)
		{
			var selection = selectionArray[iSelection];
			if (!is_struct(selection) || selection.type != kEditorSelection_Primitive)
				continue; // Only work on prims
			if (selection.object.face == null) 
				continue; // Only work on faces
			
			var mapSolid = selection.object.primitive;
			var face = mapSolid.faces[selection.object.face];
			
			// Save solid for update
			if (!array_contains(solidsEdited, mapSolid))
				array_push(solidsEdited, mapSolid);
				
			// Run the task
			task(mapSolid, face, params);
		}
		
		// Ask for map to update visuals now
		TextureUpdateMapVisuals(solidsEdited);
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
		var solidsEdited = [];
		
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
			
			// Save solid for update
			if (!array_contains(solidsEdited, mapSolid))
				array_push(solidsEdited, mapSolid);
			
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
		TextureUpdateMapVisuals(solidsEdited);
	}
	static UVAlignToView = function(input_selection=undefined)
	{
		// TODO.
	}
	static UVAlignUnwrap = function(input_selection=undefined)
	{
		// TODO.
	}
	
	static UVApplyShift = function(shiftX=false, shiftY=false, scaleX=false, scaleY=false, rotated=false, input_selection=undefined)
	{
		var solidsEdited = [];
		var new_alignment = m_editor.toolTextureInfo;
		
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
			
			// Save solid for update
			if (!array_contains(solidsEdited, mapSolid))
				array_push(solidsEdited, mapSolid);
				
			if (scaleX) face.uvinfo.scale.x = new_alignment.scale.x;
			if (scaleY) face.uvinfo.scale.y = new_alignment.scale.y;
			if (shiftX) face.uvinfo.offset.x = new_alignment.offset.x;
			if (shiftY) face.uvinfo.offset.y = new_alignment.offset.y;
			if (rotated) face.uvinfo.rotation = new_alignment.rotation;
		}
		
		// Ask for map to update visuals now
		TextureUpdateMapVisuals(solidsEdited);
	}
	
	static UVRotate90Clockwise = function(input_selection=undefined)
	{
		var solidsEdited = [];
		
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
			
			// Save solid for update
			if (!array_contains(solidsEdited, mapSolid))
				array_push(solidsEdited, mapSolid);
				
			// Rotate UVs
			face.uvinfo.rotation += 90;
		}
		
		// Ask for map to update visuals now
		TextureUpdateMapVisuals(solidsEdited);
	}
	static UVRotate90CounterClockwise = function(input_selection=undefined)
	{
		var solidsEdited = [];
		
		for (var iSelection = 0; iSelection < array_length(m_editor.m_selection); ++iSelection)
		{
			var selection = m_editor.m_selection[iSelection];
			if (!is_struct(selection) || selection.type != kEditorSelection_Primitive)
				continue; // Only work on prims
			if (selection.object.face == null) 
				continue; // Only work on faces
			
			var mapSolid = selection.object.primitive;
			var face = mapSolid.faces[selection.object.face];
			
			// Save solid for update
			if (!array_contains(solidsEdited, mapSolid))
				array_push(solidsEdited, mapSolid);
				
			// Rotate UVs
			face.uvinfo.rotation -= 90;
		}
		
		// Ask for map to update visuals now
		TextureUpdateMapVisuals(solidsEdited);
	}
	
	
	
	static UVFit = function(repeatX, repeatY, input_selection=undefined)
	{
		var params = {repeatX: repeatX, repeatY: repeatY};
		UV_ForEachFaceIn(input_selection, m_editor.m_selection, params, function(mapSolid, face, params) 
		{
			var repeatX = params.repeatX;
			var repeatY = params.repeatY;
			
			// Get the face's current texture
			var texture_sprite = null;
			if (face.texture.type == kTextureTypeTexture)
			{
				texture_sprite = ResourceFindTexture(face.texture.source).sprite;
			}
			else
			{
				texture_sprite = face.texture.source;
			}
			// Get texture size
			var texture_size = new Vector2(sprite_get_width(texture_sprite), sprite_get_height(texture_sprite));
			if (face.texture.type == kTextureTypeSpriteTileset)
			{
				texture_size.x = 16;
				texture_size.y = 16;
			}
			
			// Create a plane for calculating UVs
			var facePlane = Plane3FromNormalOffset(face.uvinfo.normal, new Vector3(0, 0, 0));
			
			// Create an array of positions, and get them in the current face's plane
			var face_positions = array_create(array_length(face.indicies));
			for (var indexIndex = 0; indexIndex < array_length(face.indicies); ++indexIndex)
			{
				var position_3d = mapSolid.vertices[face.indicies[indexIndex]].position;
				var position_flat = facePlane.flattenPoint(position_3d);
				position_flat.rotateSelf(-face.uvinfo.rotation); // Undo rotation, it'll be "redone" in the output
				
				face_positions[indexIndex] = position_flat;
			}
			
			// TODO: combine this with justify & scale
			
			// We want to fix X and Y seperately
			if (repeatX != 0)
			{
				// Get the min & max X with face's current orientation
				var min_x = face_positions[0].x;
				var max_x = min_x;
				for (cornerIndex = 1; cornerIndex < array_length(face_positions); ++cornerIndex)
				{
					min_x = min(min_x, face_positions[cornerIndex].x);
					max_x = max(max_x, face_positions[cornerIndex].x);
				}
				
				// Calculate scale & translation we need to apply
				var x_scale = (texture_size.x / (max_x - min_x)) * repeatX;
				var x_shift = min_x * x_scale;
				
				// Apply new values
				face.uvinfo.scale.x = x_scale;
				face.uvinfo.offset.x = x_shift;
			}
			
			if (repeatY != 0)
			{
				// Get the min & max X with face's current orientation
				var min_y = face_positions[0].y;
				var max_y = min_y;
				for (cornerIndex = 1; cornerIndex < array_length(face_positions); ++cornerIndex)
				{
					min_y = min(min_y, face_positions[cornerIndex].y);
					max_y = max(max_y, face_positions[cornerIndex].y);
				}
				
				// Calculate scale & translation we need to apply
				var y_scale = (texture_size.y / (max_y - min_y)) * repeatY;
				var y_shift = min_y * y_scale;
				
				// Apply new values
				face.uvinfo.scale.y = y_scale;
				face.uvinfo.offset.y = y_shift;
			}
		});
	}
	
	// ========================================================================
	// Texturing Tools
	// ========================================================================
	
	static TextureApplyToSelection = function()
	{
		var bRequestRebuild = false;
		
		// Get current primitive:
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