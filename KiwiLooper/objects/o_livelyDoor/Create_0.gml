/// @description Make mesh

event_inherited();

// Set up initial state
opening = false;
closing = false;

openstate = 0.0;
doorheight = 32;
startz = z;

door_open_sound = (room == rm_Ship5) ? "sound/door/doom_door_open0.wav" : "sound/door/door_open0.wav";

// Set up persistence
PersistentState("opening", kValueTypeBoolean);
PersistentState("closing", kValueTypeBoolean);
PersistentState("openstate", kValueTypeFloat);

// Reset the startz on post-level-load
onPostLevelLoad = function()
{
	startz = z;
	
	// Update collision sizes, as sprite is used for collision check
	if (xscale != 1.0 || yscale != 1.0 || zscale != 1.0)
	{
		image_xscale = xscale;
		image_yscale = yscale;
	}
	
	// hack to fix.
	xscale = 1;
	yscale = 1;
	
	m_updateMesh();
};

// Set up callback
m_onActivation = function(activatedBy)
{
	// first check if something in the way...
	var blocking_character = collision_rectangle(
		bbox_left + 1, bbox_top + 1, bbox_right - 1, bbox_bottom - 1,
		ob_character,
		true, true);
	if (iexists(blocking_character))
	{
		// Do nothing
	}
	// is open?
	else if (opening || (!closing && openstate > 0.5))
	{
		opening = false;
		closing = true;
		
		var sfx = sound_play_at(x + sprite_width / 2, y + sprite_height / 2, z + doorheight / 2, door_open_sound);
			sfx.gain = 0.2;
	}
	// is closed?
	else if (closing || openstate < 0.5)
	{
		closing = false;
		opening = true;
		
		var sfx = sound_play_at(x + sprite_width / 2, y + sprite_height / 2, z + doorheight / 2, door_open_sound);
			sfx.gain = 0.2;
	}
	// default to open up
	else
	{
		closing = false;
		opening = true;
		
		var sfx = sound_play_at(x + sprite_width / 2, y + sprite_height / 2, z + doorheight / 2, door_open_sound);
			sfx.gain = 0.2;
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
	var height = doorheight;
	
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
			(new Vector2((sprite_width > sprite_height) ? 1.0 : 0.0, (sprite_width > sprite_height) ? 0.0 : 0.5)).biasUVSelf(uvs),
			new Vector3(0, 0, 1)),
		new MBVertex(
			new Vector3(left,	bottom,	0 + height),
			c_white, 1.0,
			(new Vector2((sprite_width > sprite_height) ? 0.0 : 1.0, (sprite_width > sprite_height) ? 0.5 : 0.0)).biasUVSelf(uvs),
			new Vector3(0, 0, 1)),
		new MBVertex(
			new Vector3(right,	bottom,	0 + height),
			c_white, 1.0,
			(new Vector2(1.0, 0.5)).biasUVSelf(uvs),
			new Vector3(0, 0, 1)),
		]);
		
	meshb_End(m_mesh);
}
m_updateMesh();

m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(ssy_power, 0));
}

