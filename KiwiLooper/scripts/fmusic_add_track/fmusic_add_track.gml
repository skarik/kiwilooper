/// @description fmusic_add_track(music_instance, filename)
/// @param music_instance
/// @param filename
function fmusic_add_track(argument0, argument1)
{
	var music_player = argument0;
	var filename = argument1;

	if (is_undefined(filename))
	{
		return null;
	}

	if (!file_exists(filename))
	{
		show_error("Could not find the audio '" + filename + "' for open.", true);
	    return null;
	}

	//music_player.m_track[music_player.m_trackCount] = audio_create_stream(filename);
	//audio_play_in_sync_group(music_player.m_syncGroup, music_player.m_track[music_player.m_trackCount]);

	music_player.m_trackStream[music_player.m_trackCount] = faudioBufferLoad(filename);
	music_player.m_track[music_player.m_trackCount] = faudioSourceCreate(music_player.m_trackStream[music_player.m_trackCount]);
	faudioSourceSetLooped(music_player.m_track[music_player.m_trackCount], true);
	faudioSourceSetSpatial(music_player.m_track[music_player.m_trackCount], kAudioSpatial2D);
	faudioSourceSetGain(music_player.m_track[music_player.m_trackCount], 0.0);

	// Set up initial volume
	music_player.m_trackVolume[music_player.m_trackCount] = 0.0;
	music_player.m_trackCurrentVolume[music_player.m_trackCount] = 0.0;

	// Set up other information
	music_player.m_trackIntroToLoop[music_player.m_trackCount] = null;

	music_player.m_trackCount += 1;

	return music_player;


}
