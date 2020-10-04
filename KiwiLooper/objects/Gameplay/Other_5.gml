/// @description Find all objects to track, make sure they're in the list

if (m_isGameplay)
{
	// track all needed objects for this room
	var tracker_listing = array_create(0);

	var object_types = [o_playerSplatter, o_usableCorpseKiwi];

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