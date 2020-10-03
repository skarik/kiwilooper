/// @function draw_quad(x1,y1,x2,y2,x3,y3,x4,y4,outline)
/// @param x1
/// @param y1
/// @param x2
/// @param y2
/// @param x3
/// @param y3
/// @param x4
/// @param y4
/// @param outline
function draw_quad(argument0, argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8) {

	var x1,y1,x2,y2,x3,y3,x4,y4,outline,precision;
	x1 = argument0;
	y1 = argument1;
	x2 = argument2;
	y2 = argument3;
	x3 = argument4;
	y3 = argument5;
	x4 = argument6;
	y4 = argument7;
	outline = argument8;

	if (!outline)
	{
		draw_triangle(x1, y1, x2, y2, x3, y3, false);
		draw_triangle(x3, y3, x2, y2, x4, y4, false);
	}
	else
	{
		draw_line(x1, y1, x2, y2);
		draw_line(x2, y2, x4, y4);
		draw_line(x4, y4, x3, y3);
		draw_line(x3, y3, x1, y1);
	}


}
