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