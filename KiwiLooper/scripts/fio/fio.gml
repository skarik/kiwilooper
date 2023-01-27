/// @function fioInit()
/// @description Initializes common fio information.
function fioInit()
{
	var build_filename = working_directory + "../build.bff";
	if (file_exists(build_filename))
	{
		var buf = buffer_load(build_filename);
		var buf_size = buffer_get_size(buf);
		var str = "";
		for (var byteIndex = 0; byteIndex < buf_size; ++byteIndex)
		{
			str += chr(buffer_read(buf, buffer_u8));
		}
		buffer_delete(buf);
	
		var json = json_parse(str);
	
		global.fio_development = true;
		global.fio_projectDir = json.projectDir;
	}
	else
	{
		global.fio_development = false;
		global.fio_projectDir = working_directory;
	}
}
gml_pragma("global", "fioInit()");

/// @function fioLocalFileFindAbsoluteFilepath(localPath)
/// @param localPath : path to the local file
function fioLocalFileFindAbsoluteFilepath(localPath)
{
	var filename_attempts;
	if (global.fio_development)
	{
		filename_attempts = [
			global.fio_projectDir + "/datafiles/" + localPath,
			working_directory + localPath,
			temp_directory + localPath,
			localPath,
		];
	}
	else
	{
		filename_attempts = [
			localPath,
			working_directory + localPath,
			temp_directory + localPath,
		];
	}
	for (var i = 0; i < array_length(filename_attempts); ++i)
	{
		if (file_exists(filename_attempts[i]))
		{
			return filename_attempts[i];
		}
	}
	
	return noone;
}

/// @function fioGetProjectDirectory()
/// @description Returns the current project path.
function fioGetProjectDirectory()
{
	return global.fio_projectDir;
}

/// @function fioGetDatafileDirectory()
/// @description Returns the current datafile path.
function fioGetDatafileDirectory()
{
	if (global.fio_development)
	{
		return global.fio_projectDir + "\\datafiles\\";
	}
	else
	{
		return global.fio_projectDir;
	}
}

/// @function fioLocalPathFindAbsoluteFilepath(localPath)
/// @param localPath : path to the local folder
function fioLocalPathFindAbsoluteFilepath(localPath)
{
	var filename_attempts;
	if (global.fio_development)
	{
		filename_attempts = [
			global.fio_projectDir + "\\datafiles\\" + localPath,
			working_directory + localPath,
			temp_directory + localPath,
			localPath,
		];
	}
	else
	{
		filename_attempts = [
			localPath,
			working_directory + localPath,
			temp_directory + localPath,
		];
	}
	for (var i = 0; i < array_length(filename_attempts); ++i)
	{
		if (directory_exists(filename_attempts[i]))
		{
			return filename_attempts[i] + "\\";
		}
	}
	
	return noone;
}