#macro kMapEditorFeature_None					0x0001
#macro kMapEditorFeature_CameraFirstPerson		0x0002
#macro kMapEditorFeature_Solids					0x0004
#macro kMapEditorFeature_DirtyFlagsAndCamToggle	0x0005
#macro kMapEditorFeature_ViewModeInfo			0x0007
#macro kMapEditorFeature_EntityNumbering		0x0008

#macro kMapEditorFeature_Current	kMapEditorFeature_DirtyFlagsAndCamToggle

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
		editorSavedState.serializeBuffer(featureset, buffer, kIoRead, SerializeReadDefault);
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
	
	editorSavedState.serializeBuffer(kMapEditorFeature_Current, buffer, kIoWrite, SerializeWriteDefault);
		
	// Save the buffer we just created to the filedata.
	filedata.blob_editor = buffer;
}