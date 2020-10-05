/// @description faudio_create_music()
function fmusic_create() {

	if (iexists(ob_musicPlayer))
	{
		ob_musicPlayer.m_fadeOut = true;
	}

	var music_player = inew(ob_musicPlayer);
		//music_player.m_syncGroup = audio_create_sync_group(true);
		//music_player.music_caller = ob_CtsTalker;
		music_player.music_caller = noone;

	return music_player;


}
