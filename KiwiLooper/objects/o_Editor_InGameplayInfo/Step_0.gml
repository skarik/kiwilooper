/// @description Check for quit signal to return to editor

if (keyboard_check_pressed(vk_escape))
{
	Game_LoadEditor(true);
	idelete(this);
}