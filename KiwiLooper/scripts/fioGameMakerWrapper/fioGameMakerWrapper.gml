function fioTextOpenRead(localPath)
{
	var filename = fioLocalFileFindAbsoluteFilepath(localPath);
	if (is_string(filename))
	{
		var file = file_text_open_read(filename);
		if (file == -1)
		{
			return null;
		}
		return file;
	}
	return null;
}

function fioTextOpenWrite(localPath)
{
	var filename = fioLocalFileFindAbsoluteFilepath(localPath);
	if (is_string(filename))
	{
		var file = file_text_open_write(filename);
		if (file == -1)
		{
			return null;
		}
		return file;
	}
	return null;
}