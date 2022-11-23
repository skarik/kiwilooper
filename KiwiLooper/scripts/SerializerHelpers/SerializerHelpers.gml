#macro kIoRead	0x01
#macro kIoWrite	0x02

function SerializeReadDefault(scope, variable, buffer, type)
{
	variable_struct_set(scope, variable, buffer_read(buffer, type));
}

function SerializeWriteDefault(scope, variable, buffer, type)
{
	buffer_write(buffer, type, variable_struct_get(scope, variable));
}
