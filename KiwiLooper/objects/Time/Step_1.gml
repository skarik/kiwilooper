// Set up max framerate
room_speed = Debug.captureModeEnabled ? 50 : 300; // Just at the cusp for certain chipsets to scream and burn up.

// Update delta time (limit of 100ms for 10FPS)
unscaled_dt = min(delta_time / 1000000, Debug.recordModeEnabled ? 0.020 : 0.100);
dt = unscaled_dt * scale;

// Update aliases
deltaTime = dt;
unscaledDeltaTime = unscaled_dt;

// Update time
time += Time.deltaTime;

// Update the window caption for display
window_set_caption(
	game_display_name
	+ " : " + string(fps) + " FPS"
	+ (Debug.captureModeEnabled ? " Capture Mode Enabled" : "") );