/// @function fmusic_fade_all(music_instance, filename)
function fmusic_fade_all()
{
	if (iexists(ob_musicPlayer))
	{
		ob_musicPlayer.m_fadeOut = true;
	}
}
