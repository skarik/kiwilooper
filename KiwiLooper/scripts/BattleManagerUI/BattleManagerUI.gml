function BMSMeshUpdate()
{
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
}


function BMSMeshAddGrid(mesh)
{
	// Find player and build floor grid around them
	
	var player = instance_find(o_playerKiwi, 0);
	var tex_uvs = sprite_get_uvs(sfx_square, 0);
	
	
	var playerPosition = new Vector3(round(player.x / 16) * 16, round(player.y / 16) * 16, player.z + 1);
	
	var gridXNormal = new Vector3(1, 0, 0);
	var gridYNormal = new Vector3(0, 1, 0);
	var kGridDist = 128;
	var kGridSpace = 16;
		
	for (var i = 0; i <= 4; ++i)
	{
		MeshbAddLine3(mesh, c_white, 0.25,
			0.5, kGridDist, gridXNormal, playerPosition.subtract(gridXNormal.multiply(kGridDist * 0.5)).add(gridYNormal.multiply(kGridSpace * i)), tex_uvs);
		MeshbAddLine3(mesh, c_white, 0.25,
			0.5, kGridDist, gridXNormal, playerPosition.subtract(gridXNormal.multiply(kGridDist * 0.5)).add(gridYNormal.multiply(kGridSpace * -i)), tex_uvs);
		
		MeshbAddLine3(mesh, c_white, 0.25,
			0.5, kGridDist, gridYNormal, playerPosition.subtract(gridYNormal.multiply(kGridDist * 0.5)).add(gridXNormal.multiply(kGridSpace * i)), tex_uvs);
		MeshbAddLine3(mesh, c_white, 0.25,
			0.5, kGridDist, gridYNormal, playerPosition.subtract(gridYNormal.multiply(kGridDist * 0.5)).add(gridXNormal.multiply(kGridSpace * -i)), tex_uvs);
	}
}


function BMSMenuMeshAddTimers(mesh, surface)
{
	var tex_w = surface_get_width(surface);
	var tex_h = surface_get_height(surface);
	
	// add all the timer UIs
	surface_set_target(surface);
	
	draw_set_color(c_yellow);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_font(f_Oxygen7);
	
	for (var iActor = 0; iActor < array_length(actors); ++iActor)
	{
		var actor = actors[iActor];
		if (!iexists(actor.m_character)) continue;
		
		draw_text(0, iActor * 16, string(max(0.00, actor.m_timeUntilNextAction)));
	}
	surface_reset_target();
	
	// add all the timer meshes
	
	var frontface_direction = Vector3FromArray(o_Camera3D.m_viewForward);
	var cross_x = frontface_direction.cross(new Vector3(0, 0, 1));
	var cross_y = frontface_direction.cross(cross_x);
	cross_x.normalize().multiplySelf(-32 * 0.6);
	cross_y.normalize().multiplySelf(16 * 0.6);
	
	for (var iActor = 0; iActor < array_length(actors); ++iActor)
	{
		var actor = actors[iActor];
		if (!iexists(actor.m_character)) continue;
		
		MeshbAddQuadUVs(
			mesh, c_white, 1.0,
			cross_x,
			cross_y,
			[
				0,
				(iActor * 16) / tex_h,
				31 / tex_w,
				(iActor * 16 + 16) / tex_h
			],
			Vector3FromTranslation(actor.m_character).add(new Vector3(0, 0, 32)).subtract(cross_x.multiply(0.5)).subtract(cross_y.multiply(0.5))
		);
			
	}
}

function BMSMenuMeshAddMoveMenu(mesh, surface)
{
	if (battleMachine.getCurrentState() != ABMSStateBattleMenu) return; // TODO
	if (is_undefined(battlePlayer) || !iexists(battlePlayer.m_character)) return; // TODO
	
	var tex_w = surface_get_width(surface);
	var tex_h = surface_get_height(surface);
	
	// build the menu ui
	surface_set_target(surface);
	
	var dx = 32;
	var dy = 0;
	draw_set_color(c_navy);
	draw_set_alpha(0.5);
	draw_rectangle(dx, dy, dx + 80, dy + 80, false);
	draw_set_color(c_blue);
	draw_set_alpha(1.0);
	draw_rectangle(dx + 1, dy + 1, dx + 80 - 2, dy + 80 - 2, true);
	
	// draw menu options
	draw_set_color(c_aqua);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_font(f_Oxygen10);
	draw_text(dx + 10, dy + 2 +  0, "[MOVE]");
	draw_text(dx + 10, dy + 2 + 20, "[BRACE]");
	draw_text(dx + 10, dy + 2 + 40, "[HURT]");
	draw_text(dx + 10, dy + 2 + 60, "[WAIT]");
	
	draw_set_color(c_white);
	draw_text(dx + 0, dy + 2 + 20 * actionMenuChoice, ">>");
	
	surface_reset_target();
	
	// draw menu mesh
	var frontface_direction = Vector3FromArray(o_Camera3D.m_viewForward);
	var cross_x = frontface_direction.cross(new Vector3(0, 0, 1));
	var cross_y = frontface_direction.cross(cross_x);
	cross_x.normalize().multiplySelf(-80 * 0.6);
	cross_y.normalize().multiplySelf(80 * 0.6);
	
	MeshbAddQuadUVs(
		mesh, c_white, 1.0,
		cross_x,
		cross_y,
		[
			(dx) / tex_w,
			(dy) / tex_h,
			(dx + 80) / tex_w,
			(dy + 80) / tex_h
		],
		Vector3FromTranslation(battlePlayer.m_character).add(new Vector3(0, 0, 32)).subtract(cross_x.multiply(0.5)).subtract(cross_y.multiply(0.5)).add(cross_x.multiply(1.0))
	);
}