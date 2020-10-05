/// @description renders w/ palette to Game

m_repaletteBuffer = surface_create_from_surface_params(Screen.m_gameSurface);

surface_set_target(m_repaletteBuffer);
{
	gpu_set_blendenable(false);
	gpu_set_blendmode_ext(bm_one, bm_zero);
	
	// Clear the screen
	draw_clear(c_black);
	
	// Set up the shader
	shader_set(sh_stylizedAbberation);
	shader_set_uniform_f(m_uStrength, m_strength);
	
	// Draw the screen
	draw_set_color(c_white);
	draw_surface(Screen.m_gameSurface, 0, 0);
	
	// Reset drawing status
	shader_reset();
}
surface_reset_target();

// "copy" back
var l_old_surface = Screen.m_gameSurface;
Screen.m_gameSurface = m_repaletteBuffer;
m_repaletteBuffer = l_old_surface;
surface_free_if_exists(m_repaletteBuffer);