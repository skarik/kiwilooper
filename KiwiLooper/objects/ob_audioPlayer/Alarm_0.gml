/// @description begin playing sound

m_buffer = faudioBufferLoad(m_sound);
if (m_buffer == nullptr)
{
	debugLog(kLogError, "Could not load sound: \"" + m_sound + "\"");
	idelete_delay(this);
	exit;
}

m_source = faudioSourceCreate(m_buffer);
if (m_source == nullptr)
{
	debugLog(kLogError, "Could not create source for sound: \"" + m_sound + "\"");
	idelete_delay(this);
	exit;
}

faudioSourceSetLooped(m_source, loop);

faudioSourceSetFalloffModel(
	m_source,
	(falloff_model == kAudioFalloffModelExponential)
		? kFAFalloffExponential
		: kFAFalloffLinear,
	falloff_factor);
faudioSourceSetFalloff(m_source, falloff_start, falloff_end);
faudioSourceSetPitch(m_source, pitch);

/*audio_falloff_set_model((falloff_model == kAudioFalloffModelExponential)
	? audio_falloff_exponent_distance_clamped
	: audio_falloff_linear_distance_clamped);
audio_emitter_falloff(m_emitter, falloff_start, falloff_end, falloff_factor);
audio_emitter_pitch(m_emitter, pitch);*/

faudioSourceSetGain(m_source, gain);
faudioSourceSetChannel(m_source, channel);

faudioSourceSetPosition(m_source, x, y, z);
faudioSourceSetSpatial(m_source, spatial);
	
// update gain
/*if (channel == kSoundChannelWorld || channel == kSoundChannelKey)
	audio_emitter_gain(m_emitter, gain * Settings.audio_sfx_volume * Settings.audio_total_volume);
else if (channel == kSoundChannelMusic)
	audio_emitter_gain(m_emitter, gain * Settings.audio_music_volume * Settings.audio_total_volume);
else if (channel == kSoundChannelSpeech)
	audio_emitter_gain(m_emitter, gain * Settings.audio_speech_volume * Settings.audio_total_volume);

audio_emitter_position(m_emitter, x, y, 0);*/

//m_instance = audio_play_sound_on(m_emitter, m_sound, loop, priority);

//debugOut("Playing sound \"" + string(audio_get_name(m_sound)) + "\"");

if (!loop)
{
	m_despawnTimerEnabled = true;
	m_despawnTimer = 0.0;
	var sound_length = faudioSourceGetSoundLength(m_source);
	if (sound_length != 0.0)
	{
		m_despawnTimer = sound_length + 1.0;
	}
}

faudioSourcePlay(m_source, true);
