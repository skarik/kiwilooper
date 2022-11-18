/// @description Insert description here
// You can write your code in this editor

controlUpdate(false);

BMSStep();

// update m_renderer.m_mesh
// let's just start with a grid
meshb_BeginEdit(meshUIBits);
BMSMeshAddGrid(meshUIBits);
meshb_End(meshUIBits);


if (!surface_exists(surfaceMenu))
{
	surfaceMenu = surface_create(1024, 1024);
}
surface_clear_color_alpha(surfaceMenu, c_white, 0.0);

// update the menus too
meshb_BeginEdit(meshMenuBits);
//set up the surface surfaceMenu AND the mesh that goes with it
BMSMenuMeshAddTimers(meshMenuBits, surfaceMenu);
// set up menu
BMSMenuMeshAddMoveMenu(meshMenuBits, surfaceMenu);
meshb_End(meshMenuBits);