function AEditorGizmoBase() constructor
{
	m_editor = EditorGet(); // TODO: pass this in?

	x = 0;
	y = 0;
	z = 0;

	// Is this gizmo's render called? Toggle with SetVisible/SetInvisible.
	m_visible = true;
	// Is this gizmo's step called? Toggle with SetEnabled/SetDisabled.
	m_enabled = true;
	
	// Does this gizmo want release? If unused for a period of time, it will be freed from memory.
	wants_release = false;
	
	static SetVisible = function()
	{
		gml_pragma("forceinline");
		m_visible = true;
	};
	static SetInvisible = function()
	{
		gml_pragma("forceinline");
		m_visible = false;
	};
	static GetVisible = function()
	{
		gml_pragma("forceinline");
		return m_visible;
	};
	
	static SetEnabled = function()
	{
		gml_pragma("forceinline");
		if (!m_enabled)
		{
			m_enabled = true;
			OnEnable();
		}
	};
	static SetDisabled = function()
	{
		gml_pragma("forceinline");
		if (m_enabled)
		{
			m_enabled = false;
			OnDisable();
		}
	};
	static GetEnabled = function()
	{
		gml_pragma("forceinline");
		return m_enabled;
	};
	
	static Cleanup = function() {};
	static Step = function() {};
	static Draw = function() {};
	static OnEnable = function() {}; // TODO: Call these
	static OnDisable = function() {};
	
	GetConsumingMouse = function() { return false; }
	
	static _mouse = array_create(5, false);
	static _mousePressed = array_create(5, false);
	static _mouseReleased = array_create(5, false);
	static _mouseAvailable = true;
	static _MouseGetButtonIndex = function(button)
	{
		switch (button)
		{
		case mb_left:	return 0;
		case mb_right:	return 1;
		case mb_middle:	return 2;
		case kMouseWheelUp:	return 3;
		case kMouseWheelDown:	return 4;
		}
		return -1;
	}
	static MouseAvailable = function()
	{
		return _mouseAvailable;
	}
	static MouseCheckButton = function(button)
	{
		return _mouse[_MouseGetButtonIndex(button)];
	}
	static MouseCheckButtonPressed = function(button)
	{
		return _mousePressed[_MouseGetButtonIndex(button)];
	}
	static MouseCheckButtonReleased = function(button)
	{
		return _mouseReleased[_MouseGetButtonIndex(button)];
	}
	
	/// @function CalculateScreensizeFactor()
	/// @desc Calculates the screen scaling factor so that the item can remain roughly constant size at 360p
	CalculateScreensizeFactor = function()
	{
		var raylength = sqr(x - o_Camera3D.x) + sqr(y - o_Camera3D.y) + sqr(z - o_Camera3D.z);
		var screendelta = sqrt(raylength * (
			sqr(m_editor.viewrayTopLeft[0] - m_editor.viewrayBottomRight[0])
			+ sqr(m_editor.viewrayTopLeft[1] - m_editor.viewrayBottomRight[1])
			+ sqr(m_editor.viewrayTopLeft[2] - m_editor.viewrayBottomRight[2])));
			
		var size_factor = screendelta / 360 * Screen.windowScale;
		
		return size_factor;
	};
}
