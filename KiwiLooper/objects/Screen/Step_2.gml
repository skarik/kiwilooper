/// @description Record mode

if (Debug.recordModeEnabled)
{
	record_shot[record_shot_count] = surface_create_from_surface_params(m_gameSurfaceHistory[0]);
	surface_copy(record_shot[record_shot_count], offset_x, offset_y, m_gameSurfaceHistory[0]);
	
	record_shot_count += 1;
}