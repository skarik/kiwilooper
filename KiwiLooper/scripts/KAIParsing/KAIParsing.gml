/// @function KAILoadInfo(kai_filename)
/// @desc Loads up all the kai data and puts it into a useable form
function KAILoadInfo(kai_filename)
{
	var mesh_animation = undefined;
	
	var kailoader = new AFileKAILoader();
	if (kailoader.OpenFile(kai_filename))
	{
		debugLog(kLogVerbose, "Found a Kiwi Animation Info file. Loading in.");
				
		// Read in all data at once
		if (kailoader.ReadHighLevel())
		{
			kailoader.ReadSubanims(); 
			kailoader.ReadAllAttachments();
			kailoader.ReadEvents();
					
			mesh_animation = {
				frame_begin:	kailoader.m_frame_begin,
				frame_end:		kailoader.m_frame_end,
				//subanims:		kailoader.m_subanims,
				subanims:		ds_map_create(),
					// [name, frame_begin, frame_end]
				//attachments:	kailoader.m_attachments,
				attachments:	ds_map_create(),
					// [name, data[pos[], rot[], scal[]]]
				events:			ds_map_create(),
					// [frame, name, pos[], rot[], scal[]]
			};
					
			// Set up the map for fast access
			for (var i = 0; i < array_length(kailoader.m_subanims); ++i)
			{
				var subanim = kailoader.m_subanims[i];
				mesh_animation.subanims[? subanim.name] = subanim;
			}
			for (var i = 0; i < array_length(kailoader.m_attachments); ++i)
			{
				var attachment = kailoader.m_attachments[i];
				mesh_animation.attachments[? attachment.name] = attachment;
			}
			for (var i = 0; i < array_length(kailoader.m_events); ++i)
			{
				var event = kailoader.m_events[i];
				mesh_animation.events[? int64(event.frame)] = event;
			}
		}
		else
		{
			debugLog(kLogWarning, "Had an issue when loading in the KAI file.");
		}
				
		kailoader.CloseFile();
	}
			
	delete kailoader;
	
	return mesh_animation;
}