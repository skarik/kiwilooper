/// @description Update audio gain w/ powerstate

if (iexists(m_audioSound) && iexists(o_livelyRoomState))
{
	m_audioSound.gain = motion1d_to(m_audioSound.gain, o_livelyRoomState.powered ? m_gain : 0.0, Time.deltaTime * 2.0);
}