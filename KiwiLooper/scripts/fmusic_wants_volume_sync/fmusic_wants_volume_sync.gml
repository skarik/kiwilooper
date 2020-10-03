/// @description fmusic_play_introtrack(music_instance)
/// @param music_instance
function fmusic_wants_volume_sync(argument0)
{
	var music_instance = argument0;
	return music_instance.m_introEnded;
}
