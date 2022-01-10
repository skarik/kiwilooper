function AEditorAnnotation() constructor
{
	m_color		= c_white;
	m_icon		= null;
	m_iconIndex	= 0;
	m_text		= null;
	m_position	= [0,0,0];
	m_is3D		= false;
	m_canClick	= false;
	
	index = 0;
	draw_position = [0, 0];
	mouse_inside = false;
	click_state = kEditorToolButtonStateNone;
}

function EditorAnnotationsSetup()
{
	m_annotations = [];
	m_nextAnnotationIndex = 0;
	
	AnnotationCreate = function()
	{
		var annotation = new AEditorAnnotation();
	
		annotation.index = m_nextAnnotationIndex;
		m_annotations[array_length(m_annotations)] = annotation;
	
		m_nextAnnotationIndex += 1;
	
		return annotation;
	}

	AnnotationDestroy = function(annotation)
	{
		for (var i = 0; i < array_length(m_annotations); ++i)
		{
			if (m_annotations[i].index == annotation.index)
			{
				array_delete(m_annotations, i, 1);
				return;
			}
		}
	}
}

function EditorAnnotationsUpdate(mouseX, mouseY)
{
	var kSize = 8;
	var l_bLeftMouseDown = mouse_check_button_pressed(mb_left);
	
	for (var i = 0; i < array_length(m_annotations); ++i)
	{
		var annotation = m_annotations[i];
		
		// Update draw position
		if (annotation.m_is3D)
		{
			var projected_position = o_Camera3D.positionToView(annotation.m_position[0], annotation.m_position[1], annotation.m_position[2]);
			annotation.draw_position[0] = projected_position[0];
			annotation.draw_position[1] = projected_position[1];
		}
		else
		{
			annotation.draw_position[0] = annotation.m_position[0];
			annotation.draw_position[1] = annotation.m_position[1];
		}
		
		annotation.mouse_inside = point_in_rectangle(
			mouseX, mouseY,
			annotation.draw_position[0] - kSize,
			annotation.draw_position[1] - kSize,
			annotation.draw_position[0] + kSize,
			annotation.draw_position[1] + kSize);
		
		// Use draw position to check click events
		annotation.click_state = kEditorToolButtonStateNone;
		if (l_bLeftMouseDown)
		{
			if (annotation.m_canClick && annotation.mouse_inside)
			{
				annotation.click_state = kEditorToolButtonStateMake;
			}
		}
	}
}

function EditorAnnotationsDraw()
{
	draw_set_font(f_04b03);
	draw_set_valign(fa_middle);
	draw_set_halign(fa_center);
	
	for (var i = 0; i < array_length(m_annotations); ++i)
	{
		var annotation = m_annotations[i];
		
		// Alpha for making solid if can click. Transparent otherwise
		draw_set_alpha((!annotation.m_canClick || annotation.mouse_inside) ? 1.00 : 0.75);
		
		// Draw icon
		if (annotation.m_icon != null)
		{
			draw_sprite_ext(annotation.m_icon, annotation.m_iconIndex, annotation.draw_position[0], annotation.draw_position[1],
							1.0, 1.0, 0.0, c_white,
							draw_get_alpha());
		}
		
		// Draw text (under icon if icon exists)
		if (is_string(annotation.m_text))
		{
			draw_set_color(annotation.m_color);
			draw_text(annotation.draw_position[0], annotation.draw_position[1] + (annotation.m_icon != null ? 16 : 0), annotation.m_text);
		}
	}
	
	draw_set_alpha(1.0);
}