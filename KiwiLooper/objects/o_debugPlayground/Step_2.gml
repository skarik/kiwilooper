/// @description Update camera

// Apply the rounded position
GameCamera.x = round(x);
GameCamera.y = round(y);
// Apply the game camera position
with (GameCamera)
{
	event_user(1);
}