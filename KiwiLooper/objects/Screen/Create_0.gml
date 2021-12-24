/// @description Constants & render init

#macro kScreenCorner_DrawDevelopmentInfo true
#macro kScreenCorner_String "KIWILOOPER IN-DEV"

m_initialized = false;

if (singleton_this()) exit;
persistent = true;

width = 1280;
height = 720;
pixelScale = 2;

offset_x = 0;
offset_y = 0;

// Hide the cursor
window_set_cursor(cr_none);

// Disable automatic app-surface drawing.
application_surface_enable(false);
application_surface_draw_enable(false);

// Declare surfaces
m_outputSurface = null;
m_gameSurface = null;
m_uiSurface = null;
m_outputSurfaceHistory[0] = null;
m_gameSurfaceHistory[0] = null;

// Declare render lists
m_renderQueue_UIObjectDirty = true;
m_renderQueue_GameEffectDirty = true;
m_renderQueue_UIEffectDirty = true;

m_renderQueue_UIObject = ds_list_create();
m_renderQueue_GameEffect = ds_list_create();
m_renderQueue_UIEffect = ds_list_create();

// Set up output camera
m_outputCamera = camera_create_view(0, 0, Screen.width, Screen.height);

// Create screen shader effects
//inew_unique(o_replatte);
//inew_unique(o_darkness);
inew_unique(o_styledAbberation);

// Variables for keeping track of auto-screenshots
screenshot_auto_enabled = false;
screenshot_timer = 0;
screenshot_count = 0;

// Variables for keeping track of record mode
record_shot_output_count = 0;
record_shot_count = 0;
record_shot[0] = 0;

m_initialized = true;

// Local functions

///@desc Fixes window sizes
WindowOnResize = function()
{
	if (window_get_fullscreen())
	{
		// Nothing.
	}
	else
	{
		window_set_size(Screen.width, Screen.height);
	}
};