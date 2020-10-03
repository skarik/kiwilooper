// Update mouse position
uiMouseX = window_mouse_get_x();
uiMouseY = window_mouse_get_y();

// Fade in and out
image_alpha = clamp(image_alpha + Time.unscaledDeltaTime * (Debug.on ? 8.0 : -8.0), 0.0, 1.0);

// Destroy if not needed
if (!Debug.on && image_alpha <= 0.0)
{
	idelete(this);
}