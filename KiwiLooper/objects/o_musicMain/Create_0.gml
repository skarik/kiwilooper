/// @description Set up track & play

m_player = null;

// Hack to get around an obscure OGG crash
if (instance_number(o_musicMain) > 1 || instance_exists(o_musicStop) || instance_exists(o_musicEngine) || room == rm_Menu)
{
	instance_destroy();
	exit;
}

m_player = fmusic_create();
fmusic_add_track(m_player, "music/idle_folk.ogg");
fmusic_start(m_player);

m_player.m_trackVolume[0] = 1.0;