/// @description Draw command line

// Draw background
draw_set_alpha(alpha * (focused ? 0.75 : 0.5));
draw_set_color(focused ? c_dkgray : c_black);
draw_rectangle(rect[0], rect[1], rect[0] + rect[2], rect[1] + rect[3], false);
duiDrawHoverRect();

// Draw text
draw_set_font(f_04b03);
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
draw_set_alpha(alpha);
draw_set_color(focused ? c_white : c_ltgray);

var l_prefix = "debug>";
draw_text(rect[0] + 10, rect[1] + rect[3] - 8, l_prefix);
draw_text(rect[0] + 10 + string_width(l_prefix), rect[1] + rect[3] - 8, command);

draw_set_alpha(1.0);