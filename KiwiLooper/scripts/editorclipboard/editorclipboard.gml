#macro kEditorClipboard_Selection	0
#macro kEditorClipboard_Property	1
#macro kEditorClipboard_Text		2
#macro kEditorClipboard_MAX			3

function EditorClipboardSetup()
{
	// Create empty clipboards for each type of object.
	m_clipboard = array_create(kEditorClipboard_MAX);
	for (var clipboardIndex = 0; clipboardIndex < kEditorClipboard_MAX; ++clipboardIndex)
	{
		m_clipboard[clipboardIndex] = [];
	}
}

function EditorClipboardSelectionClear()
{
	// TODO
}

/// @function EditorClipboardSelectionUpdate()
/// @desc Updates selection clipboard with the current selection.
function EditorClipboardSelectionUpdate()
{
	if (array_length(m_selection) > 0)
	{
		EditorClipboardSelectionClear();
		var clipboard = [];
	
		// We essentially need to make a copy of everything in the selection.
		var clipboardIndex = 0;
		for (var selectionIndex = 0; selectionIndex < array_length(m_selection); ++selectionIndex)
		{
			var clipboard_entry = new AEditorSelection();
		
			var selection = m_selection[selectionIndex];
			if (is_struct(selection))
			{
				if (selection.type == kEditorSelection_Prop)
				{
					clipboard_entry.type = kEditorSelection_Prop;
					clipboard_entry.object = new APropEntry();
					clipboard_entry.object.copyFrom(selection.object);
				}
				else
				{
					continue;
				}
			}
			else if (iexists(selection))
			{
				clipboard_entry.type = kEditorSelection_None;
				clipboard_entry.object = {
					ent:		selection.entity,
					position:	Vector3FromTranslation(selection),
					};
				// Save extra transform information.
				if (entPropertyExists(selection.entity, "", kValueTypeRotation))
				{
					clipboard_entry.object.rotation = new Vector3(selection.xrotation, selection.yrotation, selection.zrotation);
				}
				if (entPropertyExists(selection.entity, "", kValueTypeScale))
				{
					clipboard_entry.object.scale = Vector3FromScale(selection);
				}
				// Save property information:
				clipboard_entry.object.properties = {};
				for (var propertyIndex = 0; propertyIndex < array_length(selection.entity.properties); ++propertyIndex)
				{
					var property = selection.entity.properties[propertyIndex];
					if (!entpropIsSpecialTransform(property))
					{
						variable_struct_set(clipboard_entry.object.properties, property[0], variable_instance_get(selection, property[0]));
					}
				}
			}
			else
			{
				continue;
			}
		
			clipboard[clipboardIndex] = clipboard_entry;
			clipboardIndex += 1;
		}
		
		// Save new clipboard
		 m_clipboard[kEditorClipboard_Selection] = clipboard;
	}
}

function EditorClipboardSelectionPaste()
{
	var clipboard = m_clipboard[kEditorClipboard_Selection];
	
	// Reset the selection.
	EditorGlobalClearSelection();
	
	// Check that there's even anything to paste...
	if (array_length(clipboard) > 0)
	{
		debugMessage("Beginning pasting " + string(array_length(clipboard)) + " objects");
		
		// Generate the center position first for offset
		var clipboardCenter = new Vector3(0, 0, 0);
		for (var clipboardIndex = 0; clipboardIndex < array_length(clipboard); ++clipboardIndex)
		{
			var clipboard_entry = clipboard[clipboardIndex];
			if (clipboard_entry.type == kEditorSelection_None)
			{
				clipboardCenter.addSelf(clipboard_entry.object.position);
			}
			else if (clipboard_entry.type == kEditorSelection_Prop)
			{
				clipboardCenter.addSelf(Vector3FromTranslation(clipboard_entry.object));
			}
		}
		clipboardCenter.divideSelf(array_length(clipboard));
		// Generate a center position for the camera
		var offsetPosition = new Vector3(cameraX, cameraY, cameraZ);
		offsetPosition.subtractSelf(clipboardCenter);
		// Ensure the offset position is aligned to grid
		if (toolGrid)
		{
			offsetPosition.divideSelf(toolGridSize);
			offsetPosition.x = round(offsetPosition.x);
			offsetPosition.y = round(offsetPosition.y);
			offsetPosition.z = round(offsetPosition.z);
			offsetPosition.multiplySelf(toolGridSize);
		}
		
		var bHasPropChange = false;
		
		// Now place everything
		for (var clipboardIndex = 0; clipboardIndex < array_length(clipboard); ++clipboardIndex)
		{
			var clipboard_entry = clipboard[clipboardIndex];
			if (clipboard_entry.type == kEditorSelection_None)
			{
				var ent;
				if (clipboard_entry.object.ent.proxy == kProxyTypeNone)
				{
					ent = inew(clipboard_entry.object.ent.objectIndex);
				}
				else
				{
					ent = inew(OProxyClass);
				}
				
				ent.x = clipboard_entry.object.position.x + offsetPosition.x;
				ent.y = clipboard_entry.object.position.y + offsetPosition.y;
				ent.z = clipboard_entry.object.position.z + offsetPosition.z;
				if (entPropertyExists(clipboard_entry.object.ent, "", kValueTypeRotation))
				{
					ent.xrotation = clipboard_entry.object.position.xrotation;
					ent.yrotation = clipboard_entry.object.position.yrotation;
					ent.zrotation = clipboard_entry.object.position.zrotation;
				}
				if (entPropertyExists(clipboard_entry.object.ent, "", kValueTypeScale))
				{
					ent.xscale = clipboard_entry.object.position.xscale;
					ent.yscale = clipboard_entry.object.position.yscale;
					ent.zscale = clipboard_entry.object.position.zscale;
				}
				// fill in missing transformation values (even if they're unused)
				variable_instance_set_if_not_exists(ent, "xscale", 1.0);
				variable_instance_set_if_not_exists(ent, "yscale", 1.0);
				variable_instance_set_if_not_exists(ent, "zscale", 1.0);
				variable_instance_set_if_not_exists(ent, "xrotation", 0.0);
				variable_instance_set_if_not_exists(ent, "yrotation", 0.0);
				variable_instance_set_if_not_exists(ent, "zrotation", 0.0);
				ent.entity = clipboard_entry.object.ent;
				
				for (var propertyIndex = 0; propertyIndex < array_length(clipboard_entry.object.ent.properties); ++propertyIndex)
				{
					var property = clipboard_entry.object.ent.properties[propertyIndex];
					if (!entpropIsSpecialTransform(property))
					{
						variable_instance_set(ent, property[0], variable_struct_get(clipboard_entry.object.properties, property[0]));
					}
				}
				
				// set up editor callbacks
				EditorEntity_SetupCallback(ent);
					
				// Add ent to editor
				m_entityInstList.Add(ent);
				
				array_push(m_selection, EditorSelectionWrap(ent, kEditorSelection_None));
			}
			else if (clipboard_entry.type == kEditorSelection_Prop)
			{
				var prop;
				prop = new APropEntry();
				prop.copyFrom(clipboard_entry.object);
				prop.x += offsetPosition.x;
				prop.y += offsetPosition.y;
				prop.z += offsetPosition.z;
				
				// Add prop to editor
				m_propmap.AddProp(prop);
				
				array_push(m_selection, EditorSelectionWrap(prop, kEditorSelection_Prop));
				
				bHasPropChange = true;
			}
		}
		
		// Update selection flags
		m_selectionSingle = array_length(m_selection) <= 1;
		
		// Request prop change if needed
		if (bHasPropChange)
		{
			m_editor.MapRebuilPropsOnly();
		}
	}
}