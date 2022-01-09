/// @function AEditorStatusbar() constructor
/// @notes A toolbar for rendering a vertical selection menu.
function AEditorStatusbar(editor) constructor
{
	m_editor = editor;
	
	m_toolHelpText = "";
	
	kMargin = 2;
	kHeight = 13;
	
	x = 0;
	y = 0;
	
	static Step = function()
	{
		y = GameCamera.height;
	}
	
	static Draw = function()
	{
		draw_set_alpha(0.5);
		draw_set_color(c_black);
		DrawSpriteRectangle(x, y - kHeight,
							x + GameCamera.width, y,
							false);
		
		draw_set_color(c_white);
		DrawSpriteRectangle(x, y - kHeight,
							x + GameCamera.width, y,
							true);
		
		draw_set_alpha(1.0);
		draw_set_font(f_04b03);
		draw_set_valign(fa_bottom);
		draw_set_halign(fa_left);
		draw_text(x + kMargin, y - kMargin, m_toolHelpText);
	}
}