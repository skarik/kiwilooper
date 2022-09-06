/// @description Set up

event_inherited();

// Delay before the level-start explosion
//explosionDelay = 1.0;
// Current conducting object, used to track effects
conductor = null;
// Current conducting state
conducting = false;

#region Local Functions
	// Conductor updating
	UpdateConductor = function(in_conductor)
	{
		/*if (conductor == null || !iexists(conductor))
		{
			conductor = in_conductor;
		}
		if (iexists(conductor))
		{
			conductor.m_electrifiedBottom = true;
		}*/
	}
	ClearConductor = function()
	{
		/*if (conductor != null && iexists(conductor))
		{
			conductor.m_electrifiedBottom = false;
		}
		conductor = null;*/
	}
#endregion

#region Mesh & Visuals

	var uvs = sprite_get_uvs(sprite_index, image_index);

	var width = sprite_width * image_xscale * 0.5;
	var height = sprite_height * image_yscale * 0.5;
	m_mesh = meshb_Begin();
	meshb_AddQuad(m_mesh, [
		new MBVertex(new Vector3(-width, -height, 0.7), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3( width, -height, 0.7), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3(-width,  height, 0.7), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3( width,  height, 0.7), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1))
		]);
	meshb_End(m_mesh);

	zrotation = image_angle;

	m_renderEvent = function()
	{
		vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sprite_index, image_index));
	}

#endregion
