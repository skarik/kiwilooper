/// @description Cleanup

if (m_streamed)
{
	if (audio_is_playing(m_audio))
	{
		audio_stop_sound(m_audio);
	}
	audio_destroy_stream(m_stream);
}
else
{
	// todo: make audio manager.
}