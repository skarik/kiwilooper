/// @description Constants & render init

#macro kScreenCorner_DrawDevelopmentInfo true
#macro kScreenCorner_String "KIWILOOPER IN-DEV"

m_initialized = false;

if (singleton_this()) exit;
persistent = true;

width = 1280;
height = 720;
pixelScale = 2;

#macro kScreenscalemode_Match 0		// Attempts to keep gamewidth & gameheight.
#macro kScreenscalemode_Expand 1	// Disregards gamewidth & gameheight and instead uses window.
// TODO: Mode that attempts to preserve either width or height, but boosts res up, for extra-wide support
scaleMode = kScreenscalemode_Match;

// Desired/target resolution for gameplay.
gamewidth = 1280;
gameheight = 720;

// Saved size, for tracking changes
savedwidth = width;
savedheight = height;

// Scale of the output
windowScale = 1.0;

offset_x = 0;
offset_y = 0;

// Is the mouse limited to stay within the window?
#macro kLimitMouseMode_Clamp 0
#macro kLimitMouseMode_Wrap 1
#macro kLimitMouseMode_None 2
limitMouseMode = kLimitMouseMode_None;
limitMouseWrapCallbacks = new ACallbackHelper();

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
m_windowCamera = camera_create_view(0, 0, Screen.width, Screen.height);

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
	if (window_get_fullscreen() || Screen.scaleMode == kScreenscalemode_Match)
	{
		Screen.width = Screen.gamewidth;
		Screen.height = Screen.gameheight;
	}
	else
	{
		Screen.width = window_get_width();
		Screen.height = window_get_height();
	}
	
	// Force limits in case of minimized
	Screen.width = max(Screen.pixelScale, Screen.width);
	Screen.height = max(Screen.pixelScale, Screen.height);
	
	// Save current window size for future updates
	Screen.savedwidth = window_get_width();
	Screen.savedheight = window_get_height();
	
	// Update the output view size
	//camera_set_view_size(Screen.m_outputCamera, window_get_width(), window_get_height());
	camera_set_view_size(Screen.m_outputCamera, Screen.width, Screen.height);
	camera_set_view_size(Screen.m_windowCamera, window_get_width(), window_get_height());
	
	// Update saved scale
	Screen.windowScale = sqrt(max(0, (Screen.gamewidth / Screen.width) * (Screen.gameheight / Screen.height)));
};