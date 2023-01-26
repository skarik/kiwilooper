/// @description Set up rendering

// Set up main rendering
BuildUi = function(build_mode)
{
	var pl = instance_find(o_playerKiwi, 0);
	
	var ctx, tex;
	ctx = Ui3Begin(build_mode);
	{
		// Start with debug hello world
		draw_set_font(f_Oxygen12);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(c_white);
		tex = Ui3Tex_Text(ctx, "hello");
		Ui3Shape_Billboard(ctx, tex, pl.x, pl.y, pl.z);
		
		// TODO: Other stuff
	}
	Ui3End(ctx);
}

// Create renderer
m_renderer = new Ui3Renderer(BuildUi);

// Set up final draw
m_renderEvent = function()
{
	gpu_push_state();
	gpu_set_ztestenable(false);
	gpu_set_zwriteenable(false); // TODO???
	m_renderer.Draw();
	gpu_pop_state();
}