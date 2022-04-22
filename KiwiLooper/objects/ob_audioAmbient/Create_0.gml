/// @description Loop ambient

// make sound
playSound = function()
{
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
}
m_audioSound = null;

// play sound after level loaded
onPostLevelLoad = function()
{
	playSound();
}

// set up editor callbacks

onEditorStep = function()
{
	if (iexists(m_audioSound))
	{
		m_audioSound.pitch = m_pitch;
		m_audioSound.gain = m_gain;
		m_audioSound.falloff_start = m_falloffStart;
		m_audioSound.falloff_end = m_falloffEnd;
		m_audioSound.falloff_factor = 1;
		m_audioSound.loop = true;
		m_audioSound.parent = id;
		
		sound_update_params(m_audioSound);
	}
	
	if (!iexists(m_audioSound) || m_audioSound.m_sound != m_sound)
	{
		idelete(m_audioSound);
		
		// Verify m_sound exists
		if (is_string(fioLocalFileFindAbsoluteFilepath(m_sound)))
		{
			playSound();
		}
	}
}
onEditorDrawGizmo = function(selected)
{
	// TODO
}
