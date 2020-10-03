function duiDrawHoverRect() {
	if (hovered)
	{
		draw_set_alpha(alpha);
		draw_set_color(c_white);
		draw_rectangle(rect[0], rect[1], rect[0] + rect[2] - 1, rect[1] + rect[3] - 1, true);
	}


}
