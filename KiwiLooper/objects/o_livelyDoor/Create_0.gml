/// @description Make mesh

event_inherited();

// Set up initial state
opening = false;
closing = false;

openstate = 0.0;
doorheight = 32;
startz = z;

// Set up callback
m_onActivation = function(activatedBy)
{
	// is open?
	if (opening || (!closing && openstate > 0.5))
	{
		opening = false;
		closing = true;
	}
	// is closed?
	else if (closing || openstate < 0.5)
	{
		closing = false;
		opening = true;
	}
	// default to open up
	else
	{
		closing = false;
		opening = true;
	}
}

// Create empty mesh
m_mesh = meshb_Begin();
meshb_AddQuad(m_mesh, [MBVertexDefault(), MBVertexDefault(), MBVertexDefault(), MBVertexDefault()]);
meshb_AddQuad(m_mesh, [MBVertexDefault(), MBVertexDefault(), MBVertexDefault(), MBVertexDefault()]);
meshb_AddQuad(m_mesh, [MBVertexDefault(), MBVertexDefault(), MBVertexDefault(), MBVertexDefault()]);
meshb_AddQuad(m_mesh, [MBVertexDefault(), MBVertexDefault(), MBVertexDefault(), MBVertexDefault()]);
meshb_AddQuad(m_mesh, [MBVertexDefault(), MBVertexDefault(), MBVertexDefault(), MBVertexDefault()]);
meshb_End(m_mesh);

// Define the door sprite update function
m_updateMesh = function()
{
	var uvs;
	
	var left = 0;
	var top = 0;
	var right = sprite_width;
	var bottom = sprite_height;
	var height = 32;
	
	meshb_BeginEdit(m_mesh);
	
	uvs = sprite_get_uvs(sprite_index, image_index);
	meshb_AddQuad(m_mesh, [
		new MBVertex(
			new Vector3(left,	top,	0 + height),
			c_white, 1.0,
			(new Vector2(0.0, 0.0)).biasUVSelf(uvs),
			new Vector3(0, -1, 0)),
		new MBVertex(
			new Vector3(right,	top,	0 + height),
			c_white, 1.0,
			(new Vector2(1.0, 0.0)).biasUVSelf(uvs),
			new Vector3(0, -1, 0)),
		new MBVertex(
			new Vector3(left,	top,	0),
			c_white, 1.0,
			(new Vector2(0.0, 1.0)).biasUVSelf(uvs),
			new Vector3(0, -1, 0)),
		new MBVertex(
			new Vector3(right,	top,	0),
			c_white, 1.0,
			(new Vector2(1.0, 1.0)).biasUVSelf(uvs),
			new Vector3(0, -1, 0))
		]);
		
	meshb_AddQuad(m_mesh, [
		new MBVertex(
			new Vector3(left,	bottom,	0 + height),
			c_white, 1.0,
			(new Vector2(0.0, 0.0)).biasUVSelf(uvs),
			new Vector3(0, 1, 0)),
		new MBVertex(
			new Vector3(right,	bottom,	0 + height),
			c_white, 1.0,
			(new Vector2(1.0, 0.0)).biasUVSelf(uvs),
			new Vector3(0, 1, 0)),
		new MBVertex(
			new Vector3(left,	bottom,	0),
			c_white, 1.0,
			(new Vector2(0.0, 1.0)).biasUVSelf(uvs),
			new Vector3(0, 1, 0)),
		new MBVertex(
			new Vector3(right,	bottom,	0),
			c_white, 1.0,
			(new Vector2(1.0, 1.0)).biasUVSelf(uvs),
			new Vector3(0, 1, 0))
		]);
		
	meshb_AddQuad(m_mesh, [
		new MBVertex(
			new Vector3(left,	top,	0 + height),
			c_white, 1.0,
			(new Vector2(0.0, 0.0)).biasUVSelf(uvs),
			new Vector3(-1, 0, 0)),
		new MBVertex(
			new Vector3(left,	bottom,	0 + height),
			c_white, 1.0,
			(new Vector2(1.0, 0.0)).biasUVSelf(uvs),
			new Vector3(-1, 0, 0)),
		new MBVertex(
			new Vector3(left,	top,	0),
			c_white, 1.0,
			(new Vector2(0.0, 1.0)).biasUVSelf(uvs),
			new Vector3(-1, 0, 0)),
		new MBVertex(
			new Vector3(left,	bottom,	0),
			c_white, 1.0,
			(new Vector2(1.0, 1.0)).biasUVSelf(uvs),
			new Vector3(-1, 0, 0))
		]);
		
	meshb_AddQuad(m_mesh, [
		new MBVertex(
			new Vector3(right,	top,	0 + height),
			c_white, 1.0,
			(new Vector2(0.0, 0.0)).biasUVSelf(uvs),
			new Vector3(1, 0, 0)),
		new MBVertex(
			new Vector3(right,	bottom,	0 + height),
			c_white, 1.0,
			(new Vector2(1.0, 0.0)).biasUVSelf(uvs),
			new Vector3(1, 0, 0)),
		new MBVertex(
			new Vector3(right,	top,	0),
			c_white, 1.0,
			(new Vector2(0.0, 1.0)).biasUVSelf(uvs),
			new Vector3(1, 0, 0)),
		new MBVertex(
			new Vector3(right,	bottom,	0),
			c_white, 1.0,
			(new Vector2(1.0, 1.0)).biasUVSelf(uvs),
			new Vector3(1, 0, 0))
		]);
		
	uvs = sprite_get_uvs(sprite_index, 2);
	meshb_AddQuad(m_mesh, [
		new MBVertex(
			new Vector3(left,	top,	0 + height),
			c_white, 1.0,
			(new Vector2(0.0, 0.0)).biasUVSelf(uvs),
			new Vector3(0, 0, 1)),
		new MBVertex(
			new Vector3(right,	top,	0 + height),
			c_white, 1.0,
			(new Vector2((sprite_width > sprite_height) ? 1.0 : 0.0, (sprite_width > sprite_height) ? 0.0 : 1.0)).biasUVSelf(uvs),
			new Vector3(0, 0, 1)),
		new MBVertex(
			new Vector3(left,	bottom,	0 + height),
			c_white, 1.0,
			(new Vector2((sprite_width > sprite_height) ? 0.0 : 1.0, (sprite_width > sprite_height) ? 1.0 : 0.0)).biasUVSelf(uvs),
			new Vector3(0, 0, 1)),
		new MBVertex(
			new Vector3(right,	bottom,	0 + height),
			c_white, 1.0,
			(new Vector2(1.0, 1.0)).biasUVSelf(uvs),
			new Vector3(0, 0, 1)),
		]);
		
	meshb_End(m_mesh);
}
m_updateMesh();

m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(ssy_power, 0));
}