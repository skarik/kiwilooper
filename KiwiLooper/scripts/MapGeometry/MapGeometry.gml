function AMapGeometry() constructor
{
	// AMapSolidFaceTexture[]
	materials = [];
	// AMapGeometryTriangle[]
	triangles = [];
	// TODO
	polygons = [];
	polygon_tree = null;
	portals = [];
	visible_sets = [];
	
	static serializeBuffer = function(version, buffer, ioMode, io_ser)
	{
		if (version >= kMapGeometryFeature_None)
		{
			// materials[]
			var material_count = array_length(materials);
			if (ioMode == kIoRead)
			{
				material_count = buffer_read(buffer, buffer_u16);
				materials = array_create(material_count);
			}
			else if (ioMode == kIoWrite)
			{
				buffer_write(buffer, buffer_u16, material_count);
			}
			for (var materialIndex = 0; materialIndex < material_count; ++materialIndex)
			{
				if (ioMode == kIoRead) 
					materials[materialIndex] = new AMapSolidFaceTexture();
				materials[materialIndex].SerializeBuffer(buffer, ioMode, io_ser, (version&kMapGeometryFeature_TextureFix) ? kMapEditorFeature_TextureStringsFix : kMapEditorFeature_DirtyFlagsAndCamToggle);
			}
			
			// triangles[]
			var triangle_count = array_length(triangles);
			if (ioMode == kIoRead)
			{
				triangle_count = buffer_read(buffer, buffer_u32);
				triangles = array_create(triangle_count);
			}
			else if (ioMode == kIoWrite)
			{
				buffer_write(buffer, buffer_u32, triangle_count);
			}
			for (var triangleIndex = 0; triangleIndex < triangle_count; ++triangleIndex)
			{
				if (ioMode == kIoRead) 
					triangles[triangleIndex] = new AMapGeometryTriangle();
				triangles[triangleIndex].SerializeBuffer(buffer, ioMode, io_ser);
			}
		}
		
		if (version >= kMapGeometryFeature_PolygonTree)
		{
			// TODO
		}
	}
}

// Special material indicies.
// Must be positive since it's stored as a u16.
#macro kGeoMaterialIndex_Clip	(0xFFFF)
#macro kGeoMaterialIndex_None	(0xFFFF - null + 1)

function AMapGeometryTriangle() constructor
{
	// MBVertex[3]
	vertices = [MBVertexDefault(), MBVertexDefault(), MBVertexDefault()];
	// Index into the map's material array
	material = null;
	
	static SerializeBuffer = function(buffer, ioMode, io_ser)
	{
		io_ser(self, "material", buffer, buffer_u16);
		for (var i = 0; i < 3; ++i)
		{
			io_ser(vertices[i].position, "x", buffer, buffer_f64);
			io_ser(vertices[i].position, "y", buffer, buffer_f64);
			io_ser(vertices[i].position, "z", buffer, buffer_f64);
			
			io_ser(vertices[i], "color", buffer, buffer_u32);
			io_ser(vertices[i], "alpha", buffer, buffer_f32);
			
			io_ser(vertices[i].uv, "x", buffer, buffer_f64);
			io_ser(vertices[i].uv, "y", buffer, buffer_f64);
			
			io_ser(vertices[i].normal, "x", buffer, buffer_f64);
			io_ser(vertices[i].normal, "y", buffer, buffer_f64);
			io_ser(vertices[i].normal, "z", buffer, buffer_f64);
		}
	}
}