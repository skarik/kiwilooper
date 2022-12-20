/// @description Clean up meshes & structures

for (var i = 0; i < array_length(m_meshes); ++i)
{
	meshB_Cleanup(m_meshes[i]);
}

if (global.geometry_main == id)
{
	global.geometry_main = null;
}
