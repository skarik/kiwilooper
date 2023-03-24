/// @description Clean up models
if (!is_undefined(mesh_resource))
{
	ResourceRemoveReference(mesh_resource);
	mesh_resource = undefined;
}