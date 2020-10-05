/// @description Set up track & play

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