/// @function draw_text_outline(x,y,string,text_color,outline_color,outline_size)
/// @param x
/// @param y
/// @param string
/// @param text_color
/// @param outline_color
/// @param outline_size
function draw_text_outline(argument0, argument1, argument2, argument3, argument4, argument5) {

	var dx = argument0, dy = argument1, dt = argument2;
	var tcol = argument3, ocol = argument4, osize = argument5;

	draw_set_color(ocol);
	// Draw thin outline
	for (var i = 1; i <= osize; ++i)
	{
	    draw_text(dx-i,dy,dt);
	    draw_text(dx+i,dy,dt);
	    draw_text(dx,dy-i,dt);
	    draw_text(dx,dy+i,dt);
	}
	// Draw thick outline
	for (var i = 1; i <= osize-1; ++i)
	{
	    draw_text(dx-i,dy-i,dt);
	    draw_text(dx+i,dy-i,dt);
	    draw_text(dx-i,dy+i,dt);
	    draw_text(dx+i,dy+i,dt);
	}
	// Draw the final text
	draw_set_color(tcol);
	draw_text(dx,dy,dt);


}
