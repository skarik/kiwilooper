// scripts to assist making meshes in a SENSIBLE way

function MBVertexDefault()
{
	return new MBVertex(
		{x: 0, y: 0, z: 0},
		c_white, 1.0,
		{x: 0, y: 0},
		{x: 0, y: 0, z: 1});
}

function MBVertex(n_position, n_color, n_alpha, n_uv, n_normal) constructor
{
	position = n_position;
	color = n_color;
	alpha = n_alpha;
	uv = n_uv;
	normal = n_normal;
}

function meshb_CreateVertexFormat()
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
		}
		format = vertex_format_end();
	}
	return format;
}

/// @function meshb_Begin(vertex_format)
/// @desc Create a mesh instance that can now be edited from here.
/// @returns Mesh handle
function meshb_Begin(vertex_format=null)
{
	var l_mesh = vertex_create_buffer();
	meshb_BeginEdit(l_mesh, vertex_format);
	
	return l_mesh;
}

/// @function meshb_BeginEdit(mesh, vertex_format)
/// @desc Begin editing a mesh.
function meshb_BeginEdit(mesh, vertex_format=null)
{
	static m_vformat = meshb_CreateVertexFormat();
	vertex_begin(mesh, vertex_format == null ? m_vformat : vertex_format);
}

/// @function meshb_End(mesh)
/// @desc Finish editing a mesh. Submits mesh to the GPU.
function meshb_End(mesh)
{
	vertex_end(mesh);
}

/// @function meshb_PushVertex(mesh, vertex)
/// @desc Appends a vertex to the given mesh. Must be under edit.
/// @param {Handle} Mesh to edit
/// @param {MBVertex} Data to add
function meshb_PushVertex(mesh, vertex)
{
	vertex_position_3d(mesh, vertex.position.x, vertex.position.y, vertex.position.z);
	vertex_color(mesh, vertex.color, vertex.alpha);
	vertex_texcoord(mesh, vertex.uv.x, vertex.uv.y);
	vertex_normal(mesh, vertex.normal.x, vertex.normal.y, vertex.normal.z);
}

/// @function meshB_Cleanup(mesh)
/// @desc Deletes the given mesh and associated data.
function meshB_Cleanup(mesh)
{
	vertex_delete_buffer(mesh);
}

/// @desc
///		Layout		Flipped
///		0 1			1 0
///		2 3			3 2
function meshb_AddQuad(mesh, quadArray, bFlip=false)
{
	var vert0 = quadArray[bFlip ? 1 : 0];
	var vert1 = quadArray[bFlip ? 0 : 1];
	var vert2 = quadArray[bFlip ? 3 : 2];
	var vert3 = quadArray[bFlip ? 2 : 3];
	
	meshb_PushVertex(mesh, vert0);
	meshb_PushVertex(mesh, vert2);
	meshb_PushVertex(mesh, vert1);
	
	meshb_PushVertex(mesh, vert1);
	meshb_PushVertex(mesh, vert2);
	meshb_PushVertex(mesh, vert3);
}

function meshb_AddTri(mesh, triArray)
{
	meshb_PushVertex(mesh, triArray[0]);
	meshb_PushVertex(mesh, triArray[1]);
	meshb_PushVertex(mesh, triArray[2]);
}

function meshb_AddTris(mesh, triArray)
{
	var vert_count = array_length(triArray);
	for (var i = 0; i < vert_count; i += 3)
	{
		meshb_PushVertex(mesh, triArray[i + 0]);
		meshb_PushVertex(mesh, triArray[i + 1]);
		meshb_PushVertex(mesh, triArray[i + 2]);
	}
}

function meshb_CreateEmptyMesh()
{
	var mesh = meshb_Begin();
	meshb_AddQuad(mesh, [MBVertexDefault(), MBVertexDefault(), MBVertexDefault(), MBVertexDefault()]);
	meshb_End(mesh);
	return mesh;
}