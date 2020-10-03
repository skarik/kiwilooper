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

function meshb_Begin()
{
	vertex_format_begin();
	{
		vertex_format_add_position_3d();
		vertex_format_add_color();
		vertex_format_add_texcoord();
		vertex_format_add_normal();
	}
	m_vformat = vertex_format_end();
	
	var l_mesh = vertex_create_buffer();
	meshb_BeginEdit(l_mesh);
	
	return l_mesh;
}

function meshb_BeginEdit(mesh)
{
	vertex_begin(mesh, m_vformat);
}

function meshb_End(mesh)
{
	vertex_end(mesh);
}

function meshB_Cleanup(mesh)
{
	vertex_delete_buffer(mesh);
}

function meshb_PushVertex(mesh, vertex)
{
	vertex_position_3d(mesh, vertex.position.x, vertex.position.y, vertex.position.z);
	vertex_color(mesh, vertex.color, vertex.alpha);
	vertex_texcoord(mesh, vertex.uv.x, vertex.uv.y);
	vertex_normal(mesh, vertex.normal.x, vertex.normal.y, vertex.normal.z);
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