#macro kMapAiFeature_None					0x0001

#macro kMapAiFeature_Current	kMapAiFeature_None

function MapLoadAi(filedata, aiMap)
{
	var buffer = filedata.blob_ai;
	if (buffer == null) return;
	buffer_seek(buffer, buffer_seek_start, 0);
	
	// Entity format:
	//	u32			feature set
	//	struct		savedState
	
	var featureset = buffer_read(buffer, buffer_u32);

	//if (featureset <= kMapAiFeature_None) // TODO: Later
	{
		aiMap.loadFromBuffer(featureset, buffer);
	}
}

function MapSaveAi(filedata, aiMap)
{
	if (filedata.blob_ai != null)
	{
		buffer_delete(filedata.blob_ai);
	}
	
	var buffer = buffer_create(0, buffer_grow, 1);
	
	// Entity format:
	//	u32			feature set
	//	struct		savedState
	
	buffer_write(buffer, buffer_u32, kMapAiFeature_Current);
	
	aiMap.saveToBuffer(kMapAiFeature_Current, buffer);
		
	// Save the buffer we just created to the filedata.
	filedata.blob_ai = buffer;
}