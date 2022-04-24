/// @description Set up rendering & render modes

#macro kBillboardOrientFaceCamera	0
#macro kBillboardOrientStandingFace	1
#macro kBillboardOrientFloorFace	2

#macro kBillboardSpriteModeNormal	0
#macro kBillboardSpriteModeNoZ		1

// Set up base intensity for animation
intensity = 1.0;

// Inherit the parent event
event_inherited();

// New orientation with additional scripting
m_updateOrientation = function()
{
	if (iexists(o_Camera3D))
	{
		d_xscale = -image_xscale * sprite_width * scale;
		d_yscale = image_yscale * sprite_height * scale;
		
		if (orientation == kBillboardOrientFaceCamera)
		{
			zrotation = o_Camera3D.zrotation;
			yrotation = -o_Camera3D.yrotation;
		}
		else if (orientation == kBillboardOrientStandingFace)
		{
			zrotation = o_Camera3D.zrotation;
			yrotation = 0;
		}
		else if (orientation == kBillboardOrientFloorFace)
		{
			zrotation = o_Camera3D.zrotation;
			yrotation = 90;
		}
	}
	
	// Update lightmode now
	m_lightStepper();
};

// New render event with additional scripting
m_renderEvent = function()
{
	var p_zfunc = gpu_get_zfunc();
	var p_ztestenable = gpu_get_ztestenable();
	var p_zwriteenable = gpu_get_zwriteenable();
	var p_blendmode = gpu_get_blendmode_ext_sepalpha();
	
	if (spritemode == kBillboardSpriteModeNoZ)
	{
		gpu_set_zfunc(cmpfunc_always);
	}
	if (blendmode != bm_normal)
	{
		gpu_set_blendmode(blendmode);
	}
	
	var current_shader = drawShaderGet();
	
	static uBlendColor = shader_get_uniform(sh_unlitBillboard, "uBlendColor");
	drawShaderSet(sh_unlitBillboard);
	shader_set_uniform_f(uBlendColor,
		intensity * brightness * (color_get_red(color) / 255.0),
		intensity * brightness * (color_get_green(color) / 255.0),
		intensity * brightness * (color_get_blue(color) / 255.0),
		1.0);
		vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sprite_index, m_lastFrame));
	drawShaderSet(current_shader);
	
	gpu_set_zfunc(p_zfunc);
	gpu_set_ztestenable(p_ztestenable);
	gpu_set_zwriteenable(p_zwriteenable);
	gpu_set_blendmode_ext_sepalpha(p_blendmode[0], p_blendmode[1], p_blendmode[2], p_blendmode[3]);
};

// Sprite setup:

m_currentSpriteindex = null;
m_lightStepper = method(id, Lighting_GetModeList()[0].step);

UpdateSpriteOptions = function()
{
	var bUpdateMesh = false;
	
	// Set new animation settings
	if (animSpeed != animationSpeed)
	{
		animationSpeed = animSpeed;
		animationIndex = 0;
		m_lastFrame = null;
		bUpdateMesh = true;
	}
	
	// Set new sprite settings
	if (m_currentSpriteindex != spriteindex)
	{
		m_currentSpriteindex = spriteindex;
		if (spriteindex == 0)
		{
			sprite_index = sfx_glare0;
			bUpdateMesh = true;
		}
		else if (spriteindex == 1)
		{
			sprite_index = sfx_glare1;
			bUpdateMesh = true;
		}
	}
	
	// Set up light stepper
	m_lightStepper = method(id, Lighting_GetModeList()[lightmode].step);
	
	if (bUpdateMesh)
	{
		m_updateMesh();
	}
}

// Callbacks for setting up:
onPostLevelLoad = function()
{
	UpdateSpriteOptions();
}
onEditorStep = function()
{
	UpdateSpriteOptions();
}
