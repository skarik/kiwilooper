/// @description Draw button common

// Draw background
draw_set_alpha(alpha * (focused ? 0.75 : 0.5));
draw_set_color(focused ? c_dkgray : c_black);
draw_rectangle(rect[0], rect[1], rect[0] + rect[2], rect[1] + rect[3], false);
duiDrawHoverRect();

// Draw text
draw_set_font(f_04b03);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_alpha(alpha);
draw_set_color(focused ? c_white : c_ltgray);

draw_text(rect[0] + floor(min(rect[2] * 0.2, 10)), rect[1] + rect[3] * 0.5, label_text);

draw_set_alpha(1.0);