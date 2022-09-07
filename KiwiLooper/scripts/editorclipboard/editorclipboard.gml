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

function EditorClipboardSelectionUpdate()
{
	EditorClipboardSelectionClear();
	var clipboard = m_clipboard[kEditorClipboard_Selection];
	clipboard = [];
	
	// We essentially need to make a copy of everything in the selection.
	var clipboardIndex = 0;
	for (var selectionIndex = 0; selectionIndex < array_length(m_selection); ++selectionIndex)
	{
		var clipboard_entry = new AEditorSelection();
		
		var selection = m_selection[selectionIndex];
		if (iexists(selection))
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
		}
		else if (is_struct(selection))
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
		else
		{
			continue;
		}
		
		
		clipboard[clipboardIndex] = clipboard_entry;
		clipboardIndex += 1;
	}
}