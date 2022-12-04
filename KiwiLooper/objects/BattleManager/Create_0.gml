/// @description Take control, Create UI

controlInit();

meshUIBits = meshb_CreateEmptyMesh();
meshMenuBits = meshb_CreateEmptyMesh();
surfaceMenu = null;

m_renderer = inew(ob_3DObject);
m_renderer.m_renderEvent = function()
{
	vertex_submit(meshUIBits, pr_trianglelist, sprite_get_texture(sfx_square, 0));
}

m_rendererMenu = inew(ob_3DObject);
m_rendererMenu.m_renderEvent = function()
{
	if (surfaceMenu != null && surface_exists(surfaceMenu))
	{
		vertex_submit(meshMenuBits, pr_trianglelist, surface_get_texture(surfaceMenu));
	}
}

/// set up times for everynyan too
actors = array_create(0);
array_push(actors, new ABMSCharacter(instance_find(o_playerKiwi, 0)));
for (var i = 0; i < instance_number(o_charaRobot); ++i)
{
	array_push(actors, new ABMSCharacter(instance_find(o_charaRobot, i)));
}

// we have actors, let's init
BMSInit();