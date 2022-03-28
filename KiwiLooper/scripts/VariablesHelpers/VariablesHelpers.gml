/// @function variable_instance_set_if_not_exists( entity, variable, value )
function variable_instance_set_if_not_exists( entity, variable, value )
{
	gml_pragma("forceinline");
	if (!variable_instance_exists(entity, variable))
	{
		variable_instance_set(entity, variable, value);
	}
}