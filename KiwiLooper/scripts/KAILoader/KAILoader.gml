/// @function AFileKaiLoader() constructor
/// @desc Loader for the Kiwi Animation Info files, which stores animation info not directly in the MD2.
function AFileKAILoader() constructor
{
	m_stringBlob = null;
	
	m_frame_begin	= 0;
	m_frame_end		= 0;
	m_subanims		= [];
	m_attachments	= [];
	m_events		= [];
	
	m_offset_subanims		= null;
	m_offset_attachments	= [];
	m_offset_events			= null;
	
	static OpenFile = function(path)
	{
		m_stringBlob = buffer_load(path);
		return m_stringBlob != -1;
	}
	static CloseFile = function()
	{
		buffer_delete(m_stringBlob);
		m_stringBlob = null;
	}
	
	static ReadHighLevel = function()
	{
		buffer_seek(m_stringBlob, buffer_seek_start, 0);
		
		m_offset_attachments = [];
		
		while (!buffer_at_eof(m_stringBlob))
		{
			var read_pos = buffer_tell(m_stringBlob);
			var line = buffer_read_string_line(m_stringBlob);
			
			// Split line on whitespace
			var line_tokens = string_split(line, " \t,;", true);
			
			// If there's no data, then we skip the line and move on
			if (array_length(line_tokens) == 0)
				continue;
			// Read in begin frame
			else if (line_tokens[0] == "begin")
			{
				m_frame_begin = real(line_tokens[1]);
			}
			// Read in end frame
			else if (line_tokens[0] == "end")
			{
				m_frame_end = real(line_tokens[1]);
			}
			// Save subanim block position
			else if (line_tokens[0] == "subanims")
			{
				m_offset_subanims = read_pos;
			}
			// Save subanim block position
			else if (line_tokens[0] == "events")
			{
				m_offset_events = read_pos;
			}
			// Read in attachment name & save start position
			else if (string_pos("attachment", line_tokens[0]) == 1)
			{
				array_push( m_offset_attachments,
							[read_pos, line_tokens[1]]
							);
			}
			else if (string_pos("//", line_tokens[0]) == 1)
			{	// Skip comments
				continue;
			}
			else
			{
				//debugLog(kLogWarning, "Unidentified KAI line \"" + line + "\"");
				// TODO, skip between { and }
			}
		}
		
		return true;
	}
	
	static _bufferReadUntil = function(buffer, value, per_line_callback=null, param=undefined)
	{
		while (!buffer_at_eof(buffer))
		{
			var line = buffer_read_string_line(buffer);
			
			// Split line on whitespace
			var line_tokens = string_split(line, " \t,;", true);
			
			if (array_length(line_tokens) == 0)
				continue;
			if (string_pos(value, line_tokens[0]) == 1)
			{
				break;
			}
			else if (per_line_callback != null)
			{
				per_line_callback(line_tokens, param);
			}
		}
	}
	
	static ReadSubanims = function()
	{
		if (m_offset_subanims != null)
		{
			buffer_seek(m_stringBlob, buffer_seek_start, m_offset_subanims);
		
			// Read in to the {
			_bufferReadUntil(m_stringBlob, "{");
			// Read until our line is }
			_bufferReadUntil(m_stringBlob, "}", function(line_tokens)
				{
					if (array_length(line_tokens) == 0)
					{
						return;
					}
					else
					{
						array_push(m_subanims,
							{
								name:	line_tokens[0],
								frame_begin:	real(line_tokens[1]),
								frame_end:		real(line_tokens[2]),
							});
					}
				});
			
			return true;
		}
		return false;
	}
	
	static ReadAttachment = function(attachmentIndex)
	{
		if (array_length(m_offset_attachments) < attachmentIndex && m_offset_attachments[attachmentIndex][0] != null)
		{
			var attachment = {
				name: m_offset_attachments[attachmentIndex][1],
				data: [],
			}
			
			// Read in to the {
			_bufferReadUntil(m_stringBlob, "{");
			// Read until our line is }
			_bufferReadUntil(m_stringBlob, "}", function(line_tokens, attachment)
				{
					if (array_length(line_tokens) == 0)
					{
						return;
					}
					else
					{
						var frame = real(line_tokens[0]);
						attachment.data[frame] =
							{
								position:	[real(line_tokens[1]), real(line_tokens[2]), real(line_tokens[3])],
								rotation:	[real(line_tokens[4]), real(line_tokens[5]), real(line_tokens[6])],
								scale:		[real(line_tokens[7]), real(line_tokens[8]), real(line_tokens[9])],
							};
					}
				}, attachment);
			
			m_attachments[attachmentIndex] = attachment;
			return true;
		}
		return false;
	}
	
	static ReadAllAttachments = function()
	{
		for (var i = 0; i < array_length(m_offset_attachments); ++i)
		{
			ReadAttachment(i);
		}
		return true;
	}
	
	static ReadEvents = function()
	{
		if (m_offset_events != null)
		{
			buffer_seek(m_stringBlob, buffer_seek_start, m_offset_events);
		
			// Read in to the {
			_bufferReadUntil(m_stringBlob, "{");
			// Read until our line is }
			_bufferReadUntil(m_stringBlob, "}", function(line_tokens)
				{
					if (array_length(line_tokens) == 0)
					{
						return;
					}
					// Read in the transform only if we have all the tokens for it
					else if (array_length(line_tokens) < 10)
					{
						array_push(m_events,
							{
								frame:	real(line_tokens[0]),
								name:	line_tokens[1],
								position:	undefined,
								rotation:	undefined,
								scale:		undefined,
							});
					}
					// Read in transform data if we have ALL the tokens for it
					else
					{
						array_push(m_events,
							{
								frame:	real(line_tokens[0]),
								name:	line_tokens[1],
								position:	[real(line_tokens[2]), real(line_tokens[3]), real(line_tokens[4])],
								rotation:	[real(line_tokens[5]), real(line_tokens[6]), real(line_tokens[7])],
								scale:		[real(line_tokens[8]), real(line_tokens[9]), real(line_tokens[10])],
							});
					}
				});
			
			return true;
		}
		return false;
	}
}