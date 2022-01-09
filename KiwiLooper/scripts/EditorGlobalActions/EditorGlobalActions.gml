function EditorGlobalDeleteSelection()
{
	// TODO:
	for (var i = 0; i < array_length(m_selection); ++i)
	{
		var currentSelection = m_selection[i];
		
		// Is it a struct selection?
		if (is_struct(currentSelection))
		{
			switch (currentSelection.type)
			{
			case kEditorObjectTypeTile:
				// TODO: Remove the given tile mentioned in XYZ.
				break;
			}
		}
		// Is it an object selection?
		else if (iexists(currentSelection))
		{
			idelete(currentSelection);
		}
	}
	
	m_selection = [];
}