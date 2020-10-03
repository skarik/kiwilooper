function settingsAudioLoad() {
	with (Settings)
	{
	    ini_open("settings.ini");
    
		audio_total_volume	= ini_read_real("audio", "total_volume", audio_total_volume);
		audio_sfx_volume	= ini_read_real("audio", "sfx_volume", audio_sfx_volume);
		audio_music_volume	= ini_read_real("audio", "music_volume", audio_music_volume);
		audio_speech_volume	= ini_read_real("audio", "speech_volume", audio_speech_volume);

	    ini_close();
	}




}
