/// @function AEditorToolStateSelect() constructor
function AEditorToolStateSelect() : AEditorToolState() constructor
{
	state = kEditorToolSelect;
	
	kDragAreaThreshold = 3.0;
	m_leftClickDrag = false;
	m_leftClickStart = new Vector2(0, 0);
	m_leftClickEnd = new Vector2(0, 0);
	m_leftClickDragArea = 0;
	
	onBegin = function()
	{
		m_gizmo = m_editor.EditorGizmoGet(AEditorGizmoSelectBox);
		m_gizmo.m_visible = true;
		m_gizmo.m_enabled = true;
	};
	onEnd = function(trueEnd)
	{
		m_gizmo.m_visible = false;
		m_gizmo.m_enabled = false;
	};
	
	onStep = function()
	{
		// Set up the grad box:
		if (m_leftClickDrag)
		{
			m_leftClickDragArea = abs(m_leftClickEnd.x - m_leftClickStart.x) * abs(m_leftClickEnd.y - m_leftClickStart.y);
			if (m_leftClickDragArea >= kDragAreaThreshold)
			{
				m_gizmo.m_visible = true;
				m_gizmo.m_min.x = min(m_leftClickStart.x, m_leftClickEnd.x);
				m_gizmo.m_max.x = max(m_leftClickStart.x, m_leftClickEnd.x);
				m_gizmo.m_min.y = min(m_leftClickStart.y, m_leftClickEnd.y);
				m_gizmo.m_max.y = max(m_leftClickStart.y, m_leftClickEnd.y);
			}
		}
		else
		{
			m_gizmo.m_visible = false;
		}
		
		// Update picker visuals:
		PickerUpdateVisuals();
	};
	
	/// @function PickerUpdateVisuals()
	/// @desc Updates the picker's selection box visuals. This is done via gizmo.
	PickerUpdateVisuals = function()
	{
		m_showSelectGizmo = m_editor.EditorGizmoGet(AEditorGizmoMultiSelectBox3D);
		// Draw the box around the picker
		if (array_length(m_editor.m_selection) > 0)
		{
			m_showSelectGizmo.m_enabled = true;
			m_showSelectGizmo.m_visible = true;
			
			// TODO: Loop through all the ents in the selection and put a box around each one.
			// TODO: Selection may not be an object, and may be a struct instead. Also check for that.
			
			m_showSelectGizmo.m_mins[0] = new Vector3(m_editor.m_selection[0].x - 4, m_editor.m_selection[0].y - 4, m_editor.m_selection[0].z - 4);
			m_showSelectGizmo.m_maxes[0] = new Vector3(m_editor.m_selection[0].x + 4, m_editor.m_selection[0].y + 4, m_editor.m_selection[0].z + 4);
		}
		else
		{
			m_showSelectGizmo.m_enabled = false;
			m_showSelectGizmo.m_visible = false;
		}
	}
	
	onClickWorld = function(button, buttonState, screenPosition, worldPosition)
	{
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
				
				if (m_leftClickDragArea < kDragAreaThreshold)
				{
					PickerRun();
				}
				else
				{
					// todo
				}
			}
		}
	};
	
	/// @function PickerRun()
	/// @desc Runs the picker.
	PickerRun = function()
	{
		m_editor.m_selection = [];
		m_editor.m_selectionSingle = true;
		
		var pixelX = m_editor.uPosition - GameCamera.view_x;
		var pixelY = m_editor.vPosition - GameCamera.view_y;
		
		// Get a ray
		var rayStart = new Vector3(o_Camera3D.x, o_Camera3D.y, o_Camera3D.z);
		var rayDir = Vector3FromArray(o_Camera3D.viewToRay(pixelX, pixelY));
		
		// Run through the ent table
		var closestEnt = null;
		var closestDist = 10000 * 10000.0;
		for (var entTypeIndex = 0; entTypeIndex < array_length(m_editor.m_entList); ++entTypeIndex)
		{
			var entTypeInfo = m_editor.m_entList[entTypeIndex];
			var entType = entTypeInfo[0];
			var entHhsz = entTypeInfo[3];
			
			// Count through the ents
			var entCount = instance_number(entType);
			for (var entIndex = 0; entIndex < entCount; ++entIndex)
			{
				var ent = instance_find(entType, entIndex);
				
				if (raycast4_box(new Vector3(ent.x - entHhsz, ent.y - entHhsz, ent.z - entHhsz), new Vector3(ent.x + entHhsz, ent.y + entHhsz, ent.z + entHhsz), rayStart, rayDir))
				{
					if (raycast4_get_hit_distance() < closestDist)
					{
						closestDist = raycast4_get_hit_distance();
						closestEnt = ent;
					}
				}
			}
		}
		
		if (closestEnt != null)
		{
			m_editor.m_selection[0] = closestEnt;
		}
	}
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