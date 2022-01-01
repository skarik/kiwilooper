/// @function AEditorToolStateSelect() constructor
function AEditorToolStateSelect() : AEditorToolState() constructor
{
	state = kEditorToolSelect;
	
	//m_mouseLeft = false;
	//m_mouseRight = false;
	//m_mouseMiddle = false;
	m_leftClickDrag = false;
	m_leftClickStart = new Vector2(0, 0);
	m_leftClickEnd = new Vector2(0, 0);
	
	onStep = function()
	{
		if (m_leftClickDrag)
		{
			m_editor.m_gizmoObject.m_select.m_visible = true;
			
			m_editor.m_gizmoObject.m_select.m_min.x = min(m_leftClickStart.x, m_leftClickEnd.x);
			m_editor.m_gizmoObject.m_select.m_max.x = max(m_leftClickStart.x, m_leftClickEnd.x);
			m_editor.m_gizmoObject.m_select.m_min.y = min(m_leftClickStart.y, m_leftClickEnd.y);
			m_editor.m_gizmoObject.m_select.m_max.y = max(m_leftClickStart.y, m_leftClickEnd.y);
		}
		else
		{
			m_editor.m_gizmoObject.m_select.m_visible = false;
		}
	}
	
	onClickWorld = function(button, buttonState, screenPosition, worldPosition)
	{
		/*if (buttonState == kEditorToolButtonStateMake)
		{
			if (button == mb_left)
				m_mouseLeft = true;
			else if (button == mb_right)
				m_mouseRight = true;
			else if (button = mb_middle)
				m_mouseMiddle = true;
		}
		else if (buttonState == kEditorToolButtonStateBreak)
		{	
			if (button == mb_left)
				m_mouseLeft = false;
			else if (button == mb_right)
				m_mouseRight = false;
			else if (button = mb_middle)
				m_mouseMiddle = false;
		}*/
		
		if (buttonState == kEditorToolButtonStateMake)
		{
			if (button == mb_left)
			{
				m_leftClickDrag = true;
				m_leftClickStart.x = m_editor.toolFlatX;
				m_leftClickStart.y = m_editor.toolFlatY;
			}
		}
		if (buttonState == kEditorToolButtonStateHeld)
		{
			if (button == mb_left)
			{
				m_leftClickEnd.x = m_editor.toolFlatX;
				m_leftClickEnd.y = m_editor.toolFlatY;
			}
		}
		if (buttonState == kEditorToolButtonStateBreak)
		{
			if (button == mb_left)
			{
				m_leftClickDrag = false;
			}
		}
	};
}


/// @function AEditorToolStateCamera() constructor
function AEditorToolStateCamera() : AEditorToolState() constructor
{
	state = kEditorToolCamera;
	
	m_mouseLeft = false;
	m_mouseRight = false;
	m_mouseMiddle = false;
	
	onStep = function()
	{
		var bMouseLeft = m_mouseLeft;
		var bMouseRight = m_mouseRight;
		with (m_editor)
		{
			if (bMouseLeft && !bMouseRight)
			{
				cameraRotZ -= (uPosition - uPositionPrevious) * 0.2;
				cameraRotY += (vPosition - vPositionPrevious) * 0.2;
			}
			else if (bMouseRight && !bMouseLeft)
			{
				cameraX += lengthdir_x((vPosition - vPositionPrevious), cameraRotZ)
						 + lengthdir_y((uPosition - uPositionPrevious), cameraRotZ);
				 
				cameraY += lengthdir_y((vPosition - vPositionPrevious), cameraRotZ)
						 - lengthdir_x((uPosition - uPositionPrevious), cameraRotZ);
			}
		}
	}
	onClickWorld = function(button, buttonState, screenPosition, worldPosition)
	{
		if (buttonState == kEditorToolButtonStateMake)
		{
			if (button == mb_left)
				m_mouseLeft = true;
			else if (button == mb_right)
				m_mouseRight = true;
			else if (button = mb_middle)
				m_mouseMiddle = true;
		}
		else if (buttonState == kEditorToolButtonStateBreak)
		{	
			if (button == mb_left)
				m_mouseLeft = false;
			else if (button == mb_right)
				m_mouseRight = false;
			else if (button = mb_middle)
				m_mouseMiddle = false;
		}
	};
}