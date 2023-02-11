/// @description Set up rendering

m_uiComponents = [];
{
	//array_push(m_uiComponents, AKUi_HelloWorld);
	//array_push(m_uiComponents, AKUi_StatusRectangles);
	array_push(m_uiComponents, AKUi_ObjectInteraction);
	array_push(m_uiComponents, AKUi_BeeInventory);
}

// Convert components to instance
for (var i = 0; i < array_length(m_uiComponents); ++i)
{
	m_uiComponents[i] = new m_uiComponents[i]();
}

// Set up main rendering
BuildUi = function(build_mode)
{
	var pl = instance_find(o_playerKiwi, 0);
	var screen_z = Vector3FromArray(o_Camera3D.m_viewForward);
	var screen_x = screen_z.cross(Vector3FromArray(o_Camera3D.m_viewUp));
	var screen_y = screen_z.cross(screen_x);
	
	var ctx, tex;
	ctx = Ui3Begin(build_mode);
	{
		var scale = Ui3PosScale(pl.x, pl.y, pl.z);
		
		static kHudColor = c_electricity;
		
		var uiParams= new AKiwiUIParams();
		uiParams.color = kHudColor;
		uiParams.player = pl;
		uiParams.scale = scale;
		uiParams.screen_x = screen_x;
		uiParams.screen_y = screen_y;
		uiParams.screen_z = screen_z;
		
		// Run through all of the params
		for (var i = 0; i < array_length(m_uiComponents); ++i)
		{
			if (m_uiComponents[i].visible)
			{
				m_uiComponents[i].Build(uiParams, ctx);
			}
		}
		
		delete uiParams;
	}
	Ui3End(ctx);
}

// Create renderer
m_renderer = new Ui3Renderer(BuildUi);

// Set up final draw
m_renderEvent = function()
{
	gpu_push_state();
	gpu_set_ztestenable(false);
	gpu_set_zwriteenable(false); // TODO???
	gpu_set_blendmode_ext(bm_src_alpha, bm_src_color);
	//gpu_set_blendmode(bm_add);
	m_renderer.Draw();
	gpu_pop_state();
}