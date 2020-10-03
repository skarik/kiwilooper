function settingsAudioSave() {
	with (Settings)
	{
	    ini_open("settings.ini");
    
		ini_write_real("audio", "total_volume", audio_total_volume);
		ini_write_real("audio", "sfx_volume", audio_sfx_volume);
		ini_write_real("audio", "music_volume", audio_music_volume);
		ini_write_real("audio", "speech_volume", audio_speech_volume);

	    ini_close();
	}




}
