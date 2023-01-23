/// @function buffer_write_byte_array(buffer, source_str, length)
/// @desc Writes a byte array. Has no concept of encoding
function buffer_write_byte_array(buffer, source_str, length)
{
	var strlen = string_byte_length(source_str);
	for (var i = 0; i < min(strlen, length); ++i)
	{
		buffer_write(buffer, buffer_u8, string_byte_at(source_str, i+1));
	}
	for (var i = strlen; i < length; ++i)
	{
		buffer_write(buffer, buffer_u8, 0);
	}
}

/// @function buffer_read_byte_array(buffer, length)
/// @desc Reads a byte array. Will not ensure encoding sticks.
function buffer_read_byte_array(buffer, length)
{
	var str = "";
	for (var i = 0; i < length; ++i)
	{
		str += chr(buffer_read(buffer, buffer_u8));
	}
	return str;
}

/// @function buffer_read_byte_array_as_terminated_string(buffer, length)
/// @desc Reads a byte array. Will not ensure encoding sticks.
function buffer_read_byte_array_as_terminated_string(buffer, length)
{
	var str = "";
	var i;
	for (i = 0; i < length; ++i)
	{
		var ch = buffer_read(buffer, buffer_u8);
		if (ch == 0) {
			++i
			break;
		}
		str += chr(ch);
	}
	while (i < length)
	{
		++i;
		buffer_read(buffer, buffer_u8);
	}
	return str;
}

/// @function buffer_read_string_line(buffer)
/// @desc Reads a byte array until hitting a null character or endline. Will not ensure encoding sticks.
function buffer_read_string_line(buffer)
{
	var max_len = buffer_get_size(buffer);
	
	var str = "";
	
	var bRead = true;
	while (bRead)
	{
		// Check for EoF
		var tell_pos = buffer_tell(buffer);
		if (tell_pos >= max_len)
		{
			bRead = false;
		}
		else
		{
			var ch = buffer_read(buffer, buffer_u8);
			// Check for EoL
			if (ch == ord("\n") || ch == ord("\r") || ch == 0)
			{
				bRead = false;
				// Check if this is possibly a windows newline
				if (ch == ord("\r"))
				{
					// Peak ahead for \r\n and go past it
					ch = buffer_peek(buffer, buffer_tell(buffer), buffer_u8);
					if (ch == ord("\n"))
					{
						buffer_read(buffer, buffer_u8); 
					}
				}
			}
			else
			{
				str += chr(ch);
			}
		}
	}
	
	return str;
}

/// @function buffer_at_eof(buffer)
function buffer_at_eof(buffer)
{
	return buffer_tell(buffer) >= buffer_get_size(buffer);
}

/// @function buffer_write_buffer(destBuffer, srcBuffer)
/// @desc Writes a buffer into a buffer.
function buffer_write_buffer(destBuffer, srcBuffer)
{
	var old_dest_start = buffer_tell(destBuffer);
	var src_size = buffer_tell(srcBuffer);
	
	// Allocate data in the destination
	var dest_start = buffer_tell(destBuffer);
	for (var i = 0; i < src_size; ++i)
	{
		buffer_write(destBuffer, buffer_u8, 0);
	}
	
	// Copy into allocated area
	buffer_copy(srcBuffer, 0, src_size, destBuffer, dest_start);
	
	// TODO: verify this
	var new_dest_start = buffer_tell(destBuffer);
	assert(old_dest_start + src_size == new_dest_start);
}