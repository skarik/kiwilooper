/// @description Clean up meshes & structures

meshB_Cleanup(m_mesh);

if (global.geometry_main == id)
{
	global.geometry_main = null;
}
