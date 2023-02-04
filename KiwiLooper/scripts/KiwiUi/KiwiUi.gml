function AKiwiUIParams() constructor
{
	color = c_electricity;
	player = null;
	scale = 1.0;
}

function AKiwiUiComponent() constructor
{
	visible = true;
	
	static PrePlayerStep = function(params){}
	static PostPlayerStep = function(params){}
	static Build = function(params, ctx){}
}

//=============================================================================

function AKUi_HelloWorld() : AKiwiUiComponent() constructor
{
	static Build = function(params, ctx)
	{
		var pl = params.player;
		var scale = params.scale;
		var tex;
		
		draw_set_color(params.color);
		
		// Start with debug hello world
		draw_set_font(f_Oxygen10);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		tex = Ui3Tex_Text(ctx, "hello");
		Ui3Shape_Billboard(ctx, tex, pl.x, pl.y, pl.z, 0.5 * scale, 0.5 * scale);
		tex = Ui3Tex_Text(ctx, "world");
		Ui3Shape_Billboard(ctx, tex, pl.x, pl.y, pl.z - 40.0, 0.5 * scale, 0.5 * scale);
	}
}