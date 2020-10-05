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
		// todo: play audio on open full
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
		// todo: play audio on close full
	}
}

// Update position
z = startz - (1.0 - openstate) * (doorheight - 1);