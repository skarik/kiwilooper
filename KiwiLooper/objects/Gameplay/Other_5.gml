/// @description Find all objects to track, make sure they're in the list

if (m_isGameplay)
{
	// save the camera
	if (iexists(o_Camera3D))
	{
		m_camera_x = o_Camera3D.x;
		m_camera_y = o_Camera3D.y;
		m_camera_z = o_Camera3D.z;
		m_camera_rotation_x = o_Camera3D.xrotation;
		m_camera_rotation_y = o_Camera3D.yrotation;
		m_camera_rotation_z = o_Camera3D.zrotation;
	}
	
	// track all needed objects for this room
	var tracker_listing = array_create(0);

	var object_types = [o_playerSplatter, o_playerFootstepSplatter, o_usableCorpseKiwi];

	for (var iobjtype = 0; iobjtype < array_length(object_types); ++iobjtype)
	{
		var object_type = object_types[iobjtype];
		var object_count = instance_number(object_type);
	
		for (var i = 0; i < object_count; ++i)
		{
			var object = instance_find(object_type, i);
		
			tracker_listing[array_length(tracker_listing)] = {
				index: object_type,
				position: {
					x: object.x,
					y: object.y,
					z: object.z
				},
				img: {
					image_index: object.image_index,
					image_xscale: object.image_xscale,
					image_yscale: object.image_yscale,
					image_angle: object.image_angle,
				},
			};
		}
	}

	// save the objects into the global persistent list
	m_persistent_objects[?room] = tracker_listing;
}