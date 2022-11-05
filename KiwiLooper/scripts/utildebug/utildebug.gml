function debugMessage(msg)
{
	show_debug_message("[" + (is_struct(self) ? "struct" : object_get_name(object_index)) + "]:" + msg);
	// TODO: combine with debugOut
}