gpu_set_blendmode(bm_normal);
draw_set_alpha(image_alpha);
draw_set_color(c_white);
draw_set_halign( fa_left );
draw_set_valign( fa_bottom );

draw_set_font(f_04b03);

// Draw helper 
draw_set_halign( fa_left );
draw_set_valign( fa_top );
draw_text( 10,10, "Press tilde (`) to toggle this menu.");

// draw more helpers
draw_text( 10, 24, "(F5) Screenshot");
draw_text( 10, 32, "(F11) Capture GIF");
draw_text( 10, 40, "(F10) Frame limiter");
draw_text( 10, 48, "(F3) Reset (temporary freeze)");
//draw_text( 10, 56, "(Num8) Day--");
//draw_text( 10, 64, "(Num9) Day++");
//draw_text( 10, 72, "(Num5) Hour--");
//draw_text( 10, 80, "(Num6) Hour++");
draw_text( 10, 88, "(F2) Reset room");

// Draw the debugging log:
draw_set_color( c_black );
draw_set_alpha(image_alpha * 0.5);
for (var i = 0; i < Debug.debug_line_count; ++i)
{
	var dx = 60;
	var dy = 720-60 - (Debug.debug_line_count-i)*10;
	draw_rectangle(dx - 1, dy - 1, dx + string_width(Debug.debug_line[i][0]), dy + string_height("Mg"), false);
}

draw_set_alpha(image_alpha);
draw_set_halign( fa_left );
draw_set_valign( fa_top );
var logDrawColor = c_electricity;
draw_set_color( c_electricity );
for (var i = 0; i < Debug.debug_line_count; ++i)
{
	var nextColor = logDrawColor;
	switch (Debug.debug_line[i][1])
	{
		case kLogOutput:	nextColor = c_electricity; break;
		case kLogVerbose:	nextColor = c_ltgray; break;
		case kLogWarning:	nextColor = c_yellow; break;
		case kLogError:		nextColor = c_red; break;
	}
	if (nextColor != logDrawColor)
	{
		draw_set_color(nextColor);
		logDrawColor = nextColor;
	}
    draw_text( 60, 720-60 - (Debug.debug_line_count-i)*10, Debug.debug_line[i][0] ); // TODO: use line colors
}

// Draw the current audio
{
	draw_set_color(c_white);
	draw_set_halign( fa_left );
	draw_set_valign( fa_top );
	
	var audio_counts = instance_number(ob_audioPlayer);
	for (var i = 0; i < audio_counts; ++i)
	{
		var audio = instance_find(ob_audioPlayer, i);
		//draw_text(500, 30 + 8 * i, audio_get_name(audio.m_sound));
		draw_text(500, 30 + 8 * i, audio.m_sound); // Draw filename out
	}
}
//

// draw the quest flags
//questDebugDisplayFlags();
//weatherDebugDisplay();

// Draw the mouse position
draw_set_color( c_white );
draw_arrow( uiMouseX+16, uiMouseY+16, uiMouseX, uiMouseY, 16 );

draw_set_alpha(1.0);

