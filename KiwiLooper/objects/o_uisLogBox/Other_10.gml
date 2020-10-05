/// @description Draw textbox

var dx = GameCamera.width / 2 - 90;
//var dy = GameCamera.height - 66 + 200 * (1.0 - power(saturate(m_displayFade), 0.2));
var dy = GameCamera.height - 66 + 300 * (1.0 - power(saturate(m_displayFade * 2.0), 0.5));

draw_sprite_ext(
	sui_textbox, 0,
	dx, dy,
	1.0, 1.0,
	0.0,
	c_white,
	saturate(m_displayFade * 3.0));
	
var blinkParametrics = saturate(
	saturate(sin(Time.time) * 2.0 - 1.0)
	+ saturate(cos(Time.time * 1.1 + 1.5) * 2.0 - 1.0)
	);
	blinkParametrics = saturate(blinkParametrics * 6.0 - 5.0);
draw_sprite_ext(
	sui_portraitKiwi, power(blinkParametrics, 6) * 3.9,
	dx, dy + 57,
	1, 1,
	0.0,
	c_white,
	saturate(m_displayFade * 3.0));
	
draw_set_color(c_black);
draw_set_alpha(saturate(m_displayFade * 3.0));
draw_line(dx - 84, dy + 57, dx, dy + 57);
	
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(f_Oxygen7);
draw_set_color(c_white);
draw_set_alpha(saturate(m_displayFade * 2.0 - 1.0));
draw_text_ext(dx, dy, m_displayString, 12, 193 - 14);

if (m_displayNext)
{
	draw_arrow(GameCamera.width / 2, dy + 46, GameCamera.width / 2, dy + 53, 8);
}

draw_set_alpha(1.0);