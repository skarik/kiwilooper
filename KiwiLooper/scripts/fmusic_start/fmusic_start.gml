/// @description fmusic_start(music_instance)
/// @param music_instance
function fmusic_start(argument0) {

	var music_player = argument0;

	/*var longest_length = audio_sound_length(music_player.m_track[0]);
	music_player.m_trackMasterId = 0;

	for (var i = 0; i < music_player.m_trackCount; ++i)
	{
		audio_sound_set_track_position(music_player.m_track[i], 0.0);
	
		// find the longest track (so everything can sync to it)
		var length = audio_sound_length(music_player.m_track[i]);
		if (length > longest_length)
		{
			music_player.m_trackMasterId = i;
			longest_length = length;
		}
	}*/

	// Update which is longest track, for synchro master
	with (music_player) event_user(1);

	
	for (var i = 0; i < music_player.m_trackCount; ++i)
	{
		//audio_resume_sound(music_player.m_track[i]);
		faudioSourcePlay(music_player.m_track[i], false);
	}
	
	return music_player;


}
