/// @description Clean up mesh & main tileset lookup
meshB_Cleanup(m_mesh);

idelete(o_effectPowerOverlay); // Remove ALL power overlays.


if (global.tiles_main == id)
{
	global.tiles_main = null;
}
