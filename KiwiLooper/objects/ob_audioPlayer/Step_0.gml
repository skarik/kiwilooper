/// @description move audio to parent position
if (m_source != nullptr)
{
	if (iexists(parent))
	{
		x = parent.x;
		y = parent.y;
		//audio_emitter_position(m_emitter, x, y, 0);
		faudioSourceSetPosition(m_source, x, y, 0);
	}

	// update gain
	faudioSourceSetGain(m_source, gain);
	/*if (channel == kSoundChannelWorld || channel == kSoundChannelKey)
		audio_emitter_gain(m_emitter, gain * Settings.audio_sfx_volume * Settings.audio_total_volume);
	else if (channel == kSoundChannelMusic)
		audio_emitter_gain(m_emitter, gain * Settings.audio_music_volume * Settings.audio_total_volume);
	else if (channel == kSoundChannelSpeech)
		audio_emitter_gain(m_emitter, gain * Settings.audio_speech_volume * Settings.audio_total_volume);*/
	
	// update destroy timer
	if (m_despawnTimerEnabled)
	{
		if (m_despawnTimer == 0.0)
		{
			var sound_length = faudioSourceGetSoundLength(m_source);
			if (sound_length != 0.0)
			{
				m_despawnTimer = sound_length + 1.0;
			}
		}
		else
		{
			if (m_despawnTimerCounter >= m_despawnTimer)
			{
				idelete(this);
				exit;
			}
			m_despawnTimerCounter += Time.deltaTime;
		}
	}
}
else
{	// Lost track of source, somehow. We'll just delyeet it.
	idelete(this);
	exit;
}