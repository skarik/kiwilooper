/// @function sound_play(audio)
/// @param audio
/// @notes loop, priority, falloff_start, falloff_end, falloff_factor, gain, pitch, parent
function sound_play(sound_to_play)
{
	var sound = sound_play_at(0, 0, 0, sound_to_play);
	sound.spatial = kAudioSpatial2D;
	return sound;
}

/// @function sound_play_channel(audio, channel)
/// @param audio
/// @param channel
/// @notes loop, priority, falloff_start, falloff_end, falloff_factor, gain, pitch, parent
function sound_play_channel(sound_to_play, channel_to_play_on)
{
	var sound = sound_play_at(0, 0, 0, sound_to_play);
	sound.spatial = kAudioSpatial2D;
	sound.channel = channel_to_play_on;
	return sound;
}

/// @function sound_play_at(x, y, z, audio)
/// @param x
/// @param y
/// @param z
/// @param audio
/// @notes loop, priority, falloff_start, falloff_end, falloff_factor, gain, pitch, parent
function sound_play_at(at_x, at_y, at_z, sound_to_play)
{
	if (!is_string(sound_to_play))
	{
		//sound_to_play = faudio_create_stream(sound_to_play);
		show_error("invalid input to sound_play_at()", true);
	}

	//if (sound_to_play != null && audio_exists(sound_to_play))
	if (sound_to_play != null)
	{
		var player = inew(ob_audioPlayer);
			player.x = at_x;
			player.y = at_y;
			player.z = at_z;
			player.m_sound = sound_to_play;
			//player.m_streamed = audio_get_type(sound_to_play) == 1;
			// Streamed doesn't matter anymore!
		
		return player;
	}

	return null;
}

/// @function sound_update_params(instance_to_update)
/// @param instance_to_update
function sound_update_params(sound)
{
	with (sound)
	{
		/*audio_falloff_set_model(audio_falloff_exponent_distance_clamped);
		audio_emitter_falloff(m_emitter, falloff_start, falloff_end, falloff_factor);
		audio_emitter_pitch(m_emitter, pitch);
		audio_emitter_gain(m_emitter, gain * Settings.audio_sfx_volume * Settings.audio_total_volume);
		audio_emitter_position(m_emitter, x, y, 0);*/
		if (m_source != nullptr)
		{
			faudioSourceSetFalloff(m_source, falloff_start, falloff_end);
			faudioSourceSetPitch(m_source, pitch);
			faudioSourceSetGain(m_source, gain);
			faudioSourceSetPosition(m_source, x, y, 0);
		}
	}
}
