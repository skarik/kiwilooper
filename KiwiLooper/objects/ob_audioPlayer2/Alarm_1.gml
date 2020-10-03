/// @description Check for destruction

if (m_streamed)
{
	if (!audio_is_playing(m_audio))
	{
		idelete(this);
	}
}

alarm[1] = 20;