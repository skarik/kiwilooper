#macro kMapEditorFeature_None				0x0001
#macro kMapEditorFeature_CameraFirstPerson	0x0002

#macro kMapEditorFeature_Current	kMapEditorFeature_CameraFirstPerson

function MapLoadEditor(filedata, editorSavedState)
{
	var buffer = filedata.blob_editor;
	if (buffer == null) return;
	buffer_seek(buffer, buffer_seek_start, 0);
	
	// Entity format:
	//	u32			feature set
	//	struct		savedState
	
	var featureset = buffer_read(buffer, buffer_u32);

	//if (featureset <= kMapEditorFeature_None) // TODO: Later
	{
		editorSavedState.serializeBuffer(featureset, buffer, function(scope, variable, buffer, type)
			{
				variable_struct_set(scope, variable, buffer_read(buffer, type));
			});
	}
}

function MapSaveEditor(filedata, editorSavedState)
{
	if (filedata.blob_editor != null)
	{
		buffer_delete(filedata.blob_editor);
	}
	
	var buffer = buffer_create(0, buffer_grow, 1);
	
	// Entity format:
	//	u32			feature set
	//	struct		savedState
	
	buffer_write(buffer, buffer_u32, kMapEditorFeature_Current);
	
	editorSavedState.serializeBuffer(kMapEditorFeature_Current, buffer, function(scope, variable, buffer, type)
		{
			buffer_write(buffer, type, variable_struct_get(scope, variable));
		});
		
	// Save the buffer we just created to the filedata.
	filedata.blob_editor = buffer;
}