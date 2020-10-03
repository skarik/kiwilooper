function fioTextOpenRead(argument0) {
	//
	var filename = argument0;

	var file = -1;
	file = file_text_open_read(filename);
	/*if (file == -1)
	{
		file = file_text_open_read(kFioDirectory0 + filename);
	}
	if (file == -1)
	{
		file = file_text_open_read(kFioDirectory1 + filename);
	}*/
	/*if (file == -1)
	{
		file = file_bin_open(kFioDirectory1 + filename, 0);
	}
	if (file == -1)
	{
		file_copy(kFioDirectory1 + filename, filename);
		file = file_text_open_read(filename);
	}*/
	/*if (file == -1)
	{
		//var buf = buffer_create(16384, buffer_fast, 64);
		//file = buffer_load_async(buf, kFioDirectory1 + filename, 0, 16384);
		//buffer_load_ext(buf, kFioDirectory1 + filename, 0);
		buf = buffer_load(kFioDirectory1 + filename);
	
		show_message(buffer_get_size(buf));
	
		buffer_save(buf, filename);
		buffer_delete(buf);
		file = file_text_open_read(filename);
	}
	*/
	return file;



}
