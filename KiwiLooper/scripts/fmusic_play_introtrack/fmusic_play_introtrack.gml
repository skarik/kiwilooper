/// @description fmusic_play_introtrack(music_instance, track_id)
/// @param music_instance
/// @param track_id
function fmusic_play_introtrack(argument0, argument1)
{
	var music_instance = argument0;
	var track_id = argument1;

	if (music_instance.m_trackIntroToLoop[track_id] != null)
	{
		// Immediately make the track start up
		music_instance.m_trackVolume[track_id] = 1.0;
		music_instance.m_trackCurrentVolume[track_id] = 1.0;
	
		// Make it the master track
		music_instance.m_trackMasterId = track_id;
	
		// Set it to the start
		faudioSourceSetGain(music_instance.m_track[track_id], 1.0);
		faudioSourceSetPlaybackTime(music_instance.m_track[track_id], 0.0);
	}
}
