#macro kMapGeometryFeature_None				0x0001
#macro kMapGeometryFeature_PolygonTree		0x0002
#macro kMapGeometryFeature_Portals			0x0004
#macro kMapGeometryFeature_PVSGroups		0x0008

#macro kMapGeometryFeature_Current	kMapGeometryFeature_None

function MapLoadGeometry(filedata, mapGeometry)
{
	var buffer = filedata.blob_geometry;
	if (buffer == null) return;
	buffer_seek(buffer, buffer_seek_start, 0);
	
	// Geo format:
	//	u32			feature set
	//	struct		geometry
	
	var featureset = buffer_read(buffer, buffer_u32);

	mapGeometry.serializeBuffer(featureset, buffer, kIoRead, SerializeReadDefault);
}

function MapSaveGeometry(filedata, mapGeometry)
{
	if (filedata.blob_geometry != null)
	{
		buffer_delete(filedata.blob_geometry);
	}
	
	var buffer = buffer_create(0, buffer_grow, 1);
	
	// Geo format:
	//	u32			feature set
	//	struct		geometry
	
	buffer_write(buffer, buffer_u32, kMapGeometryFeature_Current);
	
	mapGeometry.serializeBuffer(kMapGeometryFeature_Current, buffer, kIoWrite, SerializeWriteDefault);
		
	// Save the buffer we just created to the filedata.
	filedata.blob_geometry = buffer;
}