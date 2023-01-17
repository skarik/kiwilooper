/// @description Set up tracking map

m_persistent_objects = ds_map_create();
m_checkpoint_room = rm_Ship1;
m_isGameplay = true;

m_tallyCount = 5;
m_roomRepeatCount = 0;

m_camera_x = 0;
m_camera_y = 0;
m_camera_z = 0;
m_camera_rotation_x = 0;
m_camera_rotation_y = 0;
m_camera_rotation_z = 0;

PersistentStateGameInit(); // eugh

// Update the screen mode
if (!iexists(EditorGet()))
{
	Screen.scaleMode = kScreenscalemode_Match;
	Screen.pixelScale = 2.0;
}