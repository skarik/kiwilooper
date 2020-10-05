/// @function fmusic_fade_all()
function fmusic_fade_all()
{
	if (iexists(ob_musicPlayer))
	{
		ob_musicPlayer.m_fadeOut = true;
	}
}
