/// @description Set up rendering

xscale = 0.5;
yscale = 0.5;
zscale = 0.0;
zrotation = image_angle;

m_renderEvent = function()
{
	draw_set_font(f_DeValencia40);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_set_color(c_white);
	draw_set_alpha(1.0);
	draw_text(0, -2, "EXIT");
}