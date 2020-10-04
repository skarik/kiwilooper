/// @description Check door and update power based on open state

if (iexists(m_doorToCheck) && iexists(o_livelyRoomState))
{
	if (m_doorToCheck.openstate > 0.2)
	{
		o_livelyRoomState.powered = true;
	}
	else
	{
		o_livelyRoomState.powered = false;
	}
}