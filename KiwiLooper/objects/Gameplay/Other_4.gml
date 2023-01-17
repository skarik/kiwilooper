/// @description Create game items

// Check if we're in gameplay room
m_isGameplay = true;
if (room == rm_Menu || room == rm_Credits)
{
	m_isGameplay = false;
}

if (!m_isGameplay)
{
	m_tallyCount = 5;
	
	// Clear off the camera
	m_camera_x = 0;
	
	// Clear off the saved states - except for bloody footsteps
	var size = ds_map_size(m_persistent_objects);
	var key = ds_map_find_first(m_persistent_objects);
	for (var k = 0; k < size; ++k)
	{
		var old_savestate = m_persistent_objects[?key];
		
		// Generate new, lean savestate:
		var new_savestate = array_create(0);
		for (var i = 0; i < array_length(old_savestate); ++i)
		{
			var object = old_savestate[i];
			// Only save footstep states. The rest is discarded
			if (object.index == o_playerFootstepSplatter)
			{
				new_savestate[array_length(new_savestate)] = object;
			}
		}
		// Save back new state
		m_persistent_objects[?key] = new_savestate;
		
		// Go to next room savestate
		key = ds_map_find_next(m_persistent_objects, key);
	}
}
else
{
	if (!iexists(o_Camera3D))
	{
		inew(o_Camera3D);
	}

	o_Camera3D.clear_color = c_black;
	
	// Update camera position
	if (m_camera_x != 0)
	{
		o_Camera3D.x = m_camera_x;
		o_Camera3D.y = m_camera_y;
		o_Camera3D.z = m_camera_z;
		o_Camera3D.xrotation = m_camera_rotation_x;
		o_Camera3D.yrotation = m_camera_rotation_y;
		o_Camera3D.zrotation = m_camera_rotation_z;
		if (iexists(o_playerKiwi))
		{
			o_playerKiwi.cameraRotZ = m_camera_rotation_z;
			o_playerKiwi.cameraRotY = m_camera_rotation_y;
		}
	}

	// Set the checkpoint if player exists
	if (iexists(o_playerKiwi))
	{
		if (room != m_checkpoint_room)
		{
			m_roomRepeatCount = 0;
		}
		m_checkpoint_room = room;
	}
	
	m_roomRepeatCount++;

	// Abberate on start
	effectAbberate(-0.02, 0.05, false);
	effectAbberate(0.01, 0.08, false);
	effectAbberate(-0.02, 0.4, false);
	effectAbberate(0.05, 0.5, true);
	
	// Play glitch sound
	sound_play("sound/element/glitch" + choose("1", "2", "3", "4") + ".wav");
	
	// Spawn listing
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
	
	// Do tutorials
	if (room == rm_Ship1)
	{
		if (m_tallyCount == 5)
		{
			var tutorial = inew(o_uisPlayerTutorial);
				tutorial.text = "Movement\n[W][A][S][D]";
		}
		else if (m_tallyCount == 6)
		{
			var tutorial = inew(o_uisPlayerTutorial);
				tutorial.text = "Swing Wrench\n[Ctrl]";
		}
	}
	else if (room == rm_Ship2)
	{
		if (m_roomRepeatCount == 1)
		{
			var tutorial = inew(o_uisPlayerTutorial);
				tutorial.text = "Camera\n[Arrow Keys]";
		}
	}
}