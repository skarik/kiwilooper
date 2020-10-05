/// @description Create game items

// Check if we're in gameplay room
m_isGameplay = true;
if (room == rm_Menu)
{
	m_isGameplay = false;
}

if (!m_isGameplay)
{
	// TODO: Disable stuff we don't need
	m_tallyCount = 5;
}
else
{
	
	if (!iexists(o_Camera3D))
	{
		inew(o_Camera3D);
	}

	o_Camera3D.clear_color = c_black;

	// Set the checkpoint if player exists
	if (iexists(o_playerKiwi))
	{
		m_checkpoint_room = room;
	}

	//o_playerSplatter
	var object_listing = m_persistent_objects[?room];
	if (!is_undefined(object_listing))
	{
		// spawn all tracked objects for the room
		for (var i = 0; i < array_length(object_listing); ++i)
		{
			var object = object_listing[i];
		
			var inst = inew(object.index);
				inst.x = object.position.x;
				inst.y = object.position.y;
				inst.z = object.position.z;
				inst.image_index = object.img.image_index;
				inst.image_xscale = object.img.image_xscale;
				inst.image_yscale = object.img.image_yscale;
				inst.image_angle = object.img.image_angle;
			
			// Do specific init
			if (object.index == o_usableCorpseKiwi)
			{
				inst.m_updateMesh();
			}
		}
	
		// clear all the tracked objects for this room
		object_listing = array_create(0);
		m_persistent_objects[?room] = object_listing;
	}
}