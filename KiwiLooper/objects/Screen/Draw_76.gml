/// @description Generate & set RTs

// Force enable depth
/*surface_depth_disable(false);
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_zfunc(cmpfunc_always);*/

// Create the surfaces for render output
/*if (!surface_exists(m_outputSurface))
	m_outputSurface = surface_create(Screen.width, Screen.height);
if (!surface_exists(m_gameSurface))
	m_gameSurface = surface_create(Screen.width / Screen.pixelScale, Screen.height / Screen.pixelScale);*/
m_outputSurface	= surface_create(Screen.width, Screen.height);
m_gameSurface	= surface_create(Screen.width / Screen.pixelScale, Screen.height / Screen.pixelScale);
m_uiSurface		= surface_create(Screen.width / Screen.pixelScale, Screen.height / Screen.pixelScale);

// Set the game surface as the main RT
//application_surface = m_gameSurface;
//surface_set_target(m_gameSurface);
view_set_surface_id(0, m_gameSurface);

// Apply the game camera
with (GameCamera)
{
	event_user(0);
}
camera_apply(GameCamera.index);
view_set_camera(0, GameCamera.index);
view_set_visible(1, false);
view_set_visible(0, true);

// Set up default blending
gpu_set_blendenable(true);
gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_alpha);