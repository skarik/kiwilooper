/// @description Draw the menu

var blendin_value = saturate(image_alpha);
var blendin_value_delayed = saturate(image_alpha - 1.0);
var stepped_alpha = saturate(floor(image_alpha * 4) / 4);
var pulsing_alpha = stepped_alpha * (round(sin(Time.time * 2.5) * 1.4) * 0.2 + 0.8);

// near-black BG
draw_set_color(make_color_rgb(26, 29, 31));
draw_rectangle(-1000, -1000, 1000, 1000, false);
// draw stars in BG
draw_sprite_ext(sui_starbackground, 0,
	0,
	60 * (1.0 - power(blendin_value, 0.4)),
	1, 1, 0, c_white, pulsing_alpha);

// draw cloud layer
draw_sprite_ext(sui_starclouds, 0, 0, 0, 1, 1, 0, c_white, stepped_alpha * 0.5);
// horizon layer
draw_sprite_ext(sui_starhorizon, 0, 0, 5 * (1.0 - power(blendin_value, 0.4)), 1, 1, 0, c_white, 1.0);

// debris layer
draw_sprite_ext(sui_stardebris1, 0,
	round(sin(Time.time * 1.7) * 1.4),
	-50 * (1.0 - power(blendin_value, 0.4)) + round(cos(Time.time * 2.2) * 1.4),
	1, 1, 0, c_white, 1.0);
draw_sprite_ext(sui_stardebris2, 0,
	round(cos(Time.time * 1.9) * 2.4),
	-110 * (1.0 - power(blendin_value, 0.4)) + round(sin(Time.time * 1.4) * 2.4),
	1, 1, 0, c_white, 1.0);

// draw the title over it
draw_sprite_ext(sui_title, 0, 0, -100 * expoInOut(blendin_value_delayed), 1, 1, 0, c_white, stepped_alpha);

// draw menu options
var dy = 0;
for (var i = 0; i < array_length(m_menuOptions); ++i)
{
	// Skip the "continue" option for now
	if (m_menuOptions[i] == kMainMenuOptionContinue)
		continue;
		
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_set_font(f_Oxygen12);
	draw_set_alpha(blendin_value_delayed * ((m_menuSelection == i) ? 1.0 : 0.3));
	draw_set_color(c_white);
	draw_text(0, dy, m_menuOptionStrings[i]);
		
	dy += 40;
}

draw_set_alpha(1.0);

// draw mouse
draw_set_color(c_white);
draw_line(uPosition - 10, vPosition, uPosition + 10, vPosition);
draw_line(uPosition, vPosition - 10, uPosition, vPosition + 10);
