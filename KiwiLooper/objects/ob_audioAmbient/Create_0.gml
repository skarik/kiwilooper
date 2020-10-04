/// @description Loop ambient

// make sound
m_audioSound = sound_play_at(
	x, y, z,
	m_sound
	);
m_audioSound.pitch = m_pitch;
m_audioSound.gain = m_gain;
m_audioSound.falloff_start = m_falloffStart;
m_audioSound.falloff_end = m_falloffEnd;
m_audioSound.falloff_factor = 1;
m_audioSound.loop = true;
m_audioSound.parent = id;