/// @description Update states

if (opening)
{
	if (image_index != 1)
	{
		image_index = 1;
		m_updateMesh();
	}
	
	openstate += Time.deltaTime;
	if (openstate >= 1.0)
	{
		openstate = 1.0;
		opening = false;
		
		// Play audio on open full
		var sfx = sound_play_at(x + sprite_width / 2, y + sprite_height / 2, z + doorheight / 2, "sound/door/door_open1.wav");
			sfx.gain = 0.6;
	}
}
else if (closing)
{
	if (image_index != 0)
	{
		image_index = 0;
		m_updateMesh();
	}
	
	openstate -= Time.deltaTime;
	if (openstate <= 0.0)
	{
		openstate = 0.0;
		closing = false;
		
		// Play audio on close full
		var sfx = sound_play_at(x + sprite_width / 2, y + sprite_height / 2, z + doorheight / 2, "sound/door/door_open1.wav");
			sfx.gain = 0.6;
	}
}

// Update position
z = startz - openstate * (doorheight - 1);