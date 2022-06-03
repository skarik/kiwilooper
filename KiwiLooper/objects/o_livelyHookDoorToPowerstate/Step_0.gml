/// @description Check door and update power based on open state

if (iexists(m_doorToCheck) && iexists(o_livelyRoomState))
{
	switch (m_doorToCheck.object_index)
	{
	case o_livelyDoor:
	case o_livelyDoorPlatform:
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
		break;
	case o_livelyExplodingWires:
		{
			o_livelyRoomState.powered = m_doorToCheck.conducting;
		}
		break;
	}
}