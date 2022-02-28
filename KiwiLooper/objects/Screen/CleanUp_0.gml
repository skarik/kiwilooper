/// @description Clear up used resources

if (m_initialized)
{
	surface_free_if_exists(m_outputSurface);
	surface_free_if_exists(m_gameSurface);
	surface_free_if_exists(m_uiSurface);
	surface_free_if_exists(m_outputSurfaceHistory[0]);
	surface_free_if_exists(m_gameSurfaceHistory[0]);

	ds_list_destroy(m_renderQueue_UIObject);
	ds_list_destroy(m_renderQueue_GameEffect);
	ds_list_destroy(m_renderQueue_UIEffect);
	
	camera_destroy(m_outputCamera);
	camera_destroy(m_windowCamera);
}