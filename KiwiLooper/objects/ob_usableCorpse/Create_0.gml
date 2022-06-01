/// @description Set up lower priority

event_inherited();

m_priority = 3; // Lowest priority of all usable
m_useText = "GRAB";
m_pickedUp = false;
m_pickedUpBy = noone;
height = 3;

m_electrifiedBottom = false;

onGround = false;
xspeed = 0.0;
yspeed = 0.0;
zspeed = 0.0;

// Set up state
image_speed = 0;
image_index = 0;

m_glowOutline = null;
UpdateGlowOutline = function()
{
	if (m_electrifiedBottom && m_glowOutline == null)
	{
		m_glowOutline = inew(ob_3DObject);
		m_glowOutline.m_renderInstance = id;
		m_glowOutline.lit = false;
		m_glowOutline.m_renderEvent = method(m_glowOutline, function()
		{
			var last_shader = drawShaderGet();
			
			drawShaderSet(sh_unlitColormask);
			shader_set_uniform_f(global.su_unlitColormask.uColor, 0.4, 1.0, 1.0, 1.0);
			vertex_submit(m_renderInstance.m_mesh, pr_trianglelist, sprite_get_texture(m_renderInstance.sprite_index, m_renderInstance.image_index));
			
			drawShaderSet(last_shader);
		});
	}
	else if (m_electrifiedBottom && m_glowOutline != null)
	{
		// Copy transformation, but offset downward
		m_glowOutline.x = x;
		m_glowOutline.y = y;
		m_glowOutline.z = z - 0.2;
		m_glowOutline.xrotation = xrotation;
		m_glowOutline.yrotation = yrotation;
		m_glowOutline.zrotation = zrotation;
		m_glowOutline.xscale = xscale * (17/16);
		m_glowOutline.yscale = yscale * (17/16);
		m_glowOutline.zscale = zscale * (17/16);
	}
	else if (!m_electrifiedBottom && m_glowOutline != null)
	{
		idelete(m_glowOutline);
		m_glowOutline = null;
	}
}

// Set up callback
m_onActivation = function(activatedBy)
{
	if (iexists(activatedBy) && activatedBy.object_index == o_playerKiwi)
	{
		// Pick the item up
		if (!m_pickedUp)
		{
			// Save interaction lock on caller
			activatedBy.interactionLock = id;
			// Mark as picked up
			m_pickedUp = true;
			m_pickedUpBy = activatedBy;
			// Set new text
			m_useText = "THROW";
		}
		else
		{
			// Clear state & disable interaction lock
			m_pickedUp = false;
			activatedBy.interactionLock = noone;
			// Update to flat mesh
			m_updateMesh();
			// Set new text
			m_useText = "GRAB";
			
			// And throw
			xspeed = lengthdir_x(100, activatedBy.facingDirection);
			yspeed = lengthdir_y(100, activatedBy.facingDirection);
			zspeed = 70;
		}
	}
}
m_onVaporize = function(vaporizedBy)
{
	instance_destroy();
}
m_onHitGround = function()
{
	var prev = m_electrifiedBottom;
	m_electrifiedBottom = World_ShockAtPosition(x, y, z, kWorldSideFloor);
	if (prev != m_electrifiedBottom)
	{
	}
}
m_onSlideGround = function()
{
	m_electrifiedBottom = World_ShockAtPosition(x, y, z, kWorldSideFloor);
}

// Create empty mesh
m_mesh = meshb_Begin();
meshb_AddQuad(m_mesh, [MBVertexDefault(), MBVertexDefault(), MBVertexDefault(), MBVertexDefault()]);
meshb_End(m_mesh);

// Define the sprite update function
m_updateMesh = function()
{
	if (!m_pickedUp)
	{
		var uvs = sprite_get_uvs(sprite_index, image_index);
		meshb_BeginEdit(m_mesh);
		meshb_AddQuad(m_mesh, [
			new MBVertex(new Vector3(-0.5, -0.5, 1), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
			new MBVertex(new Vector3( 0.5, -0.5, 1), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
			new MBVertex(new Vector3(-0.5,  0.5, 1), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
			new MBVertex(new Vector3( 0.5,  0.5, 1), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0))
			]);
		meshb_End(m_mesh);
	
		xscale = image_xscale * sprite_width;
		yscale = image_yscale * sprite_height;
		zscale = 1.0;
		zrotation = image_angle;
	}
	else
	{
		// Vertical sprite matching who is holding us
		var uvs = sprite_get_uvs(sprite_index, image_index);
		var top = 1.0;
		var bot = 0.0;
		meshb_BeginEdit(m_mesh);
		meshb_AddQuad(m_mesh, [
			new MBVertex(new Vector3(0, -0.5, top), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
			new MBVertex(new Vector3(0,  0.5, top), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
			new MBVertex(new Vector3(0, -0.5, bot), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
			new MBVertex(new Vector3(0,  0.5, bot), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0))
			]);
		meshb_End(m_mesh);
	
		if (iexists(o_Camera3D))
		{
			xscale = 1.0;
			yscale = image_xscale * sprite_width;
			zscale = image_yscale * sprite_height / lerp(lengthdir_x(1, o_Camera3D.yrotation), 1.0, 0.1);
			zrotation = o_Camera3D.zrotation;
		}
	}
}
m_updateMesh(); // Update mesh now!

// Define the rendering function
m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sprite_index, image_index));
}