/// @function AEditorGizmoFlatEditBox() constructor
/// @desc Editor gizmo for the selection box.
function AEditorGizmoFlatEditBox() : AEditorGizmoFlatGridCursorBox() constructor
{
	m_hasAnnotations = false;
	m_editAnnotations = [];
	
	parent_Step = Step;
	/// @function Step()
	/// @desc Builds the mesh for the rendering.
	Step = function()
	{
		if (m_visible)
		{
			if (!m_hasAnnotations)
			{
				m_hasAnnotations = true;
				
				for (var i = 0; i < 4; ++i)
				{
					m_editAnnotations[i] = m_editor.AnnotationCreate();
					m_editAnnotations[i].m_icon = suie_annoteEdit;
					m_editAnnotations[i].m_iconIndex = 0;
					m_editAnnotations[i].m_canClick = true;
					m_editAnnotations[i].m_is3D = true;
					m_editAnnotations[i].m_text = "Hey"
				}
				
				m_editAnnotations[0].m_text = "Apple";
				m_editAnnotations[1].m_text = "bottom";
				m_editAnnotations[2].m_text = "jeans";
				m_editAnnotations[3].m_text = "boots";
			}
		}
		else
		{
			if (m_hasAnnotations)
			{
				m_hasAnnotations = false;
				
				for (var i = 0; i < array_length(m_editAnnotations); ++i)
				{
					m_editor.AnnotationDestroy(m_editAnnotations[i]);
				}
				m_editAnnotations = [];
			}
		}
		
		if (m_hasAnnotations)
		{
			var kEdgeMargin = 4;
			
			m_editAnnotations[0].m_position = [m_min.x - kEdgeMargin,
												(m_min.y + m_max.y) * 0.5,
												(m_min.z + m_max.z) * 0.5];
			m_editAnnotations[1].m_position = [m_max.x + kEdgeMargin,
												(m_min.y + m_max.y) * 0.5,
												(m_min.z + m_max.z) * 0.5];
			m_editAnnotations[2].m_position = [(m_min.x + m_max.x) * 0.5,
												m_min.y - kEdgeMargin,
												(m_min.z + m_max.z) * 0.5];
			m_editAnnotations[3].m_position = [(m_min.x + m_max.x) * 0.5,
												m_max.y + kEdgeMargin,
												(m_min.z + m_max.z) * 0.5];
		}
		
		parent_Step();
	}
	
}