/// @description Test drawing UI.

var kMargin = 4;

draw_set_color(c_white);
draw_rectangle(16, 16, 32, 32, true);

draw_set_font(f_04b03);
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);

var kToolbarTop = 20;
var kToolbarButtonSize = 10;
var kToolbarButtonSep = 2;

draw_text(kMargin, kToolbarTop + kToolbarButtonSep * 0 + kToolbarButtonSize * 0, "Select");
draw_text(kMargin, kToolbarTop + kToolbarButtonSep * 0 + kToolbarButtonSize * 1, "Zoom");
draw_text(kMargin, kToolbarTop + kToolbarButtonSep * 0 + kToolbarButtonSize * 2, "Camera");

draw_text(kMargin, kToolbarTop + kToolbarButtonSep * 1 + kToolbarButtonSize * 3, "Add/Sub");
draw_text(kMargin, kToolbarTop + kToolbarButtonSep * 1 + kToolbarButtonSize * 4, "Elevation");

draw_text(kMargin, kToolbarTop + kToolbarButtonSep * 2 + kToolbarButtonSize * 5, "Add Prop");

draw_text(kMargin, kToolbarTop + kToolbarButtonSep * 3 + kToolbarButtonSize * 6, "Texture");
draw_text(kMargin, kToolbarTop + kToolbarButtonSep * 3 + kToolbarButtonSize * 7, "Splats");