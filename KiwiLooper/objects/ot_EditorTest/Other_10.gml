/// @description Test drawing UI.
/*
var kMargin = 4;

draw_set_color(c_white);
draw_rectangle(16, 16, 32, 32, true);
draw_rectangle(32, 32, 48, 48, true);

draw_rectangle(16, 16, 256, 256, true);
draw_rectangle(256, 256, 272, 272, true);

draw_rectangle(128, 128, 128, 128, true);
draw_rectangle(128, 160, 128-1, 160-1, true);

draw_rectangle(160, 128, 160, 128, false);
draw_rectangle(160, 160, 160+2, 160+2, false);

draw_set_font(f_04b03);
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
*/
EditorUIBitsDraw();

// Draw an arrow for the mouse cursor.
draw_set_color(c_white);
draw_arrow(10 + uPosition - GameCamera.view_x, 10 + vPosition - GameCamera.view_y,
		        uPosition - GameCamera.view_x,      vPosition - GameCamera.view_y,
		   10);
/*
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
*/