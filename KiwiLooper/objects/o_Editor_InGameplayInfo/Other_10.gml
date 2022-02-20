/// @description Draw UI

draw_set_color(merge_color(c_white, c_ltgray, sin(Time.time * 2.0) * 0.5 + 0.5));
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(f_04b03);
draw_text(10, 10, "ESC to end testing");