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
	vertex_format_begin();
	{
		vertex_format_add_position_3d();
		vertex_format_add_color();
		vertex_format_add_texcoord();
		vertex_format_add_normal();
	}
	return vertex_format_end();
}

/// @function meshb_Begin()
/// @desc Create a mesh instance that can now be edited from here.
/// @returns Mesh handle
function meshb_Begin()
{
	var l_mesh = vertex_create_buffer();
	meshb_BeginEdit(l_mesh);
	
	return l_mesh;
}

/// @function meshb_BeginEdit(mesh)
/// @desc Begin editing a mesh.
function meshb_BeginEdit(mesh)
{
	static m_vformat = meshb_CreateVertexFormat();
	vertex_begin(mesh, m_vformat);
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

// quad layout:
// 0 1
// 2 3
function meshb_AddQuad(mesh, quadArray)
{
	var vert0 = quadArray[0];
	var vert1 = quadArray[1];
	var vert2 = quadArray[2];
	var vert3 = quadArray[3];
	
	meshb_PushVertex(mesh, vert0);
	meshb_PushVertex(mesh, vert2);
	meshb_PushVertex(mesh, vert1);
	
	meshb_PushVertex(mesh, vert1);
	meshb_PushVertex(mesh, vert2);
	meshb_PushVertex(mesh, vert3);
}