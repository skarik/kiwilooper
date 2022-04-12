/// @description Effects, upscale, push

view_set_camera(1, m_outputCamera);
view_set_visible(0, false);
view_set_visible(1, true);

// Game output is currently drawn to m_gameSurface
// We want to also fill in m_uiSurface
surface_set_target(m_uiSurface);
{
	draw_clear_alpha(c_black, 0.0);
	
	// render UI objects
	{
		// Create the priority queue of all UI objects
		if (m_renderQueue_UIObjectDirty)
		{
			var ui_queue = ds_priority_create();
			// Add in all objects
			with (ob_userInterfaceElement)
			{
				ds_priority_add(ui_queue, id, depth);
			}
			// Generate rendering order
			ds_list_clear(m_renderQueue_UIObject);
			while (!ds_priority_empty(ui_queue))
			{
				ds_list_add(m_renderQueue_UIObject, ds_priority_delete_max(ui_queue));
			}
			// Done with queue
			ds_priority_destroy(ui_queue);
			m_renderQueue_UIObjectDirty = false;
		}
		
		// Draw all the UI objects in order
		var object_count = ds_list_size(m_renderQueue_UIObject);
		for (var i = 0; i < object_count; ++i)
		{
			with (m_renderQueue_UIObject[|i])
			{
				event_user(kEvent_UIElementOnDraw0);
			}
		}
		
	}
	
	// And we're done here
}	
surface_reset_target();

// update effects (UI)
{
	// Create priority queue of all effect objects
	if (m_renderQueue_UIEffectDirty)
	{
		var effect_queue = ds_priority_create();
		// Add in all objects
		with (ob_screenEffect)
		{
			if (m_applyToUI)
			{
				ds_priority_add(effect_queue, id, m_depth);
			}
		}
		// Generate rendering order
		ds_list_clear(m_renderQueue_UIEffect);
		while (!ds_priority_empty(effect_queue))
		{
			ds_list_add(m_renderQueue_UIEffect, ds_priority_delete_min(effect_queue));
		}
		// Done with queue
		ds_priority_destroy(effect_queue);
		m_renderQueue_UIEffectDirty = false;
	}
	
	// Execute all effects in order
	var object_count = ds_list_size(m_renderQueue_UIEffect);
	for (var i = 0; i < object_count; ++i)
	{
		with (m_renderQueue_UIEffect[|i])
		{
			event_user(kEvent_ScreenEffectOnUI1);
		}
	}
}

// update effects (Game)
{
	// Create priority queue of all effect objects
	if (m_renderQueue_GameEffectDirty)
	{
		var effect_queue = ds_priority_create();
		// Add in all objects
		with (ob_screenEffect)
		{
			if (m_applyToGame)
			{
				ds_priority_add(effect_queue, id, m_depth);
			}
		}
		// Generate rendering order
		ds_list_clear(m_renderQueue_GameEffect);
		while (!ds_priority_empty(effect_queue))
		{
			ds_list_add(m_renderQueue_GameEffect, ds_priority_delete_min(effect_queue));
		}
		// Done with queue
		ds_priority_destroy(effect_queue);
		m_renderQueue_GameEffectDirty = false;
	}
	
	// Execute all effects in order
	var object_count = ds_list_size(m_renderQueue_GameEffect);
	for (var i = 0; i < object_count; ++i)
	{
		with (m_renderQueue_GameEffect[|i])
		{
			event_user(kEvent_ScreenEffectOnGame0);
		}
	}
}

// composite both game & UI in post
var l_bufferGameAndUiComposite = surface_create_from_surface_params(m_gameSurface);
surface_set_target(l_bufferGameAndUiComposite);
{
	gpu_set_blendenable(false);
	gpu_set_blendmode_ext(bm_one, bm_zero);
	draw_surface(m_gameSurface, 0, 0);
	
	gpu_set_blendenable(true);
	gpu_set_blendmode(bm_normal);
	draw_surface(m_uiSurface, 0, 0);
}
surface_reset_target();

// Upscale to the screen
surface_set_target(m_outputSurface);
camera_apply(m_outputCamera);
{
	gpu_set_blendenable(false);
	gpu_set_blendmode_ext(bm_one, bm_zero);
	
	// Clear the screen
	draw_clear(c_black);
	
	// Debug blue to show which area is actually renderable
	if (Debug.visible)
	{
		draw_set_color(c_blue);
		draw_rectangle(0, 0, Screen.width * 0.9, Screen.height * 0.9, false); // Debug blue.
	}
	
	// Draw the screen
	draw_set_color(c_white);
	draw_surface_stretched(l_bufferGameAndUiComposite, offset_x * pixelScale, offset_y * pixelScale, Screen.width, Screen.height);
}
surface_reset_target();

// Copy to the backbuffer
camera_apply(m_windowCamera);
gpu_set_blendenable(false);
gpu_set_blendmode_ext(bm_one, bm_zero);
draw_set_color(c_white);
draw_clear_alpha(c_blue, 1.0);
if (!window_get_fullscreen())
{
	draw_surface_stretched(m_outputSurface, 0, 0, window_get_width(), window_get_height());
}
else
{
	var scale_x = Screen.width / display_get_width();
	var scale_y = Screen.height / display_get_height();
	draw_surface_stretched(m_outputSurface, 0, 0, display_get_width() * scale_x, display_get_height() * scale_y);
}

// Draw debug info in the top left corner
if (kScreenCorner_DrawDevelopmentInfo)
{
	draw_set_alpha(0.25);
	draw_set_color(c_white);
	gpu_set_blendenable(true);
	gpu_set_blendmode(bm_normal);
	draw_set_font(f_04b03);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text(2, 2, kScreenCorner_String);
	draw_text(2, 2+8, Settings.startup_command);
	draw_set_alpha(1.0);
}

// Release the temp buffers
surface_free(l_bufferGameAndUiComposite);

// Release the used buffers
//surface_free_if_exists(m_outputSurface);
surface_free_if_exists(m_uiSurface);
// Store history of game surface sans-UI
surface_free_if_exists(m_gameSurfaceHistory[0]);
m_gameSurfaceHistory[0] = m_gameSurface;
m_gameSurface = null;

// Store history of our final output
surface_free_if_exists(m_outputSurfaceHistory[0]);
m_outputSurfaceHistory[0] = m_outputSurface;
m_outputSurface = null;