/// @description Set up everything

#macro kDoorBlockActors_None		0
#macro kDoorBlockActors_Player		1
#macro kDoorBlockActors_Everyone	2

#macro kDoorActionOnTrigger_Open	0
#macro kDoorActionOnTrigger_Unlock	1

#macro kDoorMoveDirection_Down	0
#macro kDoorMoveDirection_Side	1
#macro kDoorMoveDirection_None	2

event_inherited();

// Set up initial state
image_speed = 0;
image_index = 0;

// Set up callback
m_onActivation = function(activatedBy)
{
	if (iexists(activatedBy) && activatedBy.object_index == o_playerKiwi)
	{
		// Switch image
		image_index = !image_index;
		// Update the mesh
		m_updateMesh();
		
		// Now, actually toggle the target
		if (iexists(m_targetLively))
		{
			m_targetLively.m_onActivation(id);
			sound_play_at(x, y, z, "sound/door/button0.wav");
		}
	}
}
