/// @description Cleanup

//audio_stop_sound(m_instance);
//audio_emitter_free(m_emitter);

faudioSourceDestroy(m_source);
faudioBufferFree(m_buffer);

//debugOut("Stopping sound \"" + string(audio_get_name(m_sound)) + "\"");

/*if (m_streamed)
{
	if (audio_is_playing(m_audio))
	{
		audio_stop_sound(m_audio);
	}
	if (m_stream != null)
	{
		audio_destroy_stream(m_stream);
	}
}*/