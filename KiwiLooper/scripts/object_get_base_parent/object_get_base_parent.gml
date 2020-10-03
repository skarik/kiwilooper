/// @function object_get_base_parent(object_index)
/// @description Finds the most senior parent of the object index.
/// @param {resource} object_index
function object_get_base_parent(argument0) {

	var obj = argument0;
	var next_parent = obj;

	do
	{
		obj = next_parent;
		next_parent = object_get_parent(obj);
	}
	until (!object_exists(next_parent));

	return obj;


}
