/// @description Set up track & play

m_player = null;

// Hack to get around an obscure OGG crash
if (instance_number(o_musicEngine) > 1 || instance_exists(o_musicStop) || room != rm_Ship5)
{
	instance_destroy();
	exit;
}

m_player = fmusic_create();
fmusic_add_track(m_player, "music/engines_startup0.ogg");
fmusic_add_track(m_player, "music/engines_startup1.ogg");
fmusic_add_track(m_player, "music/engines_startup2.ogg");
fmusic_start(m_player);

m_player.m_trackVolume[0] = 0.0;
m_player.m_trackVolume[1] = 0.0;
m_player.m_trackVolume[2] = 0.0;

// Current music state
m_state = 0;