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
		str += ansi_char(buffer_read(buffer, buffer_u8));
	}
	return str;
}

/// @function buffer_read_buffer(buffer, type, length)
function buffer_read_buffer(buffer, type, length)
{
	var result = buffer_create(length, type, 1);
	buffer_copy(buffer, buffer_tell(buffer), length, result, 0);
	buffer_seek(buffer, buffer_seek_relative, length);
	return result;
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
		str += ansi_char(ch);
	}
	while (i < length)
	{
		++i;
		buffer_read(buffer, buffer_u8);
	}
	return str;
}

/// @function buffer_to_string(buffer)
/// @desc Reads the entire buffer as a byte array.
function buffer_to_string(buffer)
{
	var str = "";
	var i;
	var length = buffer_get_size(buffer);
	for (i = 0; i < length; ++i)
	{
		var ch = buffer_read(buffer, buffer_u8);
		str += ansi_char(ch);
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
					ch = buffer_peek(buffer, tell_pos + 1, buffer_u8);
					if (ch == ord("\n"))
					{
						buffer_read(buffer, buffer_u8); 
					}
				}
			}
			else
			{
				str += ansi_char(ch);
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
	
	if (buffer_get_type(srcBuffer) != buffer_grow)
		buffer_seek(srcBuffer, buffer_seek_end, 0);
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

/// @function buffer_create_from_string(str)
/// @desc Creates a buffer from a string.
function buffer_create_from_string(str)
{
	var length = string_length(str);
	var buffer = buffer_create(length, buffer_fixed, 1);
	
	for (var i = 1; i <= length; ++i)
	{
		buffer_write(buffer, buffer_u8, string_ord_at(str, i));
	}
	
	return buffer;
}