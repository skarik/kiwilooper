/// @function MapGeometry_CreateVertexFormat()
function MapGeometry_CreateVertexFormat()
{
	static format = null;
	if (format == null)
	{
		vertex_format_begin();
		{
			vertex_format_add_position_3d();
			vertex_format_add_color();
			vertex_format_add_texcoord();
			vertex_format_add_normal();
			vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord); // per-prim Atlas Info
		}
		format = vertex_format_end();
	}
	return format;
}

/// @function MapGeometry_PushVertex(mesh, vertex)
/// @desc Appends a vertex to the given mesh. Must be under edit.
/// @param {Handle} Mesh to edit
/// @param {MBVertex} Data to add
function MapGeometry_PushVertex(mesh, vertex)
{
	vertex_position_3d(mesh, vertex.position.x, vertex.position.y, vertex.position.z);
	vertex_color(mesh, vertex.color, vertex.alpha);
	vertex_texcoord(mesh, vertex.uv.x, vertex.uv.y);
	vertex_normal(mesh, vertex.normal.x, vertex.normal.y, vertex.normal.z);
	vertex_float4(mesh, vertex.atlas[0], vertex.atlas[1], vertex.atlas[2], vertex.atlas[3]);
}