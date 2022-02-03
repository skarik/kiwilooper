/// @function fioReadToBuffer(localPath)
/// @param localPath : path to the local file
function fioReadToBuffer(localPath)
{
	var filename = fioLocalFileFindAbsoluteFilepath(localPath);
	if (is_string(filename))
	{
		var buf = buffer_load(filename);
		return buf;
	}
	return null;
}

/// @function fioReadToString(localPath)
/// @param localPath : path to the local file
function fioReadToString(localPath)
{
	var buf = fioReadToBuffer(localPath);
	if (buf != null)
	{
		// Add null terminator
		buffer_seek(buf, buffer_seek_end, 0);
		buffer_write(buf, buffer_u8, 0);
		
		// Read buffer as a string.
		buffer_seek(buf, buffer_seek_start, 0);
		str = buffer_read(buf, buffer_text);
		buffer_delete(buf);
		
		return str;
	}
	return null;
}