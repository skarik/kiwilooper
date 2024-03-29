#macro kTextureUIElementTypeLabel 0
#macro kTextureUIElementTypeToolbar 1

/// @function AEditorWindowTextureTools() constructor
/// @desc Entity selection. Draws all available entities for creation.
function AEditorWindowTextureTools() : AEditorWindow() constructor
{
	static kElementPadding = 2;
	
	m_title = "UV Edit";
	
	m_position.x = 20;
	m_position.y = 360;
	
	m_size.x = 300;
	m_size.y = 300;
	
	m_toolstate = undefined;
	
	m_spinner_scale_x = null;
	m_spinner_scale_y = null;
	m_spinner_shift_x = null;
	m_spinner_shift_y = null;
	m_spinner_rotation = null;
	
	m_spinner_fit_x = null;
	m_spinner_fit_y = null;
	
	{
		// Set up UI
		m_elements = [];
		
		array_push(m_elements, {type: kTextureUIElementTypeLabel, label: "Texture Transform"});
		{
			var toolbar;
			
			// Header row
			toolbar = new AToolbar();
			toolbar.kBarDirection = kDirRight;
			toolbar.kButtonSize = 12;
			toolbar.kButtonMargin = 2;
			toolbar.AddElement(AToolbarElementAsLabel(null, 0, null, "Scale", 20));
			toolbar.AddElement(AToolbarElementAsLabel(null, 0, null, "Shift", 20));
			toolbar.AddElement(AToolbarElementAsLabel(null, 0, null, "Rotation", 20));
			array_push(m_elements, {type: kTextureUIElementTypeToolbar, object: toolbar});
			
			// First row
			toolbar = new AToolbar();
			toolbar.kBarDirection = kDirRight;
			toolbar.kButtonSize = 12;
			toolbar.kButtonMargin = 2;
			m_spinner_scale_x = toolbar.AddElement(AToolbarElementAsSpinner("Texture scale", "Scale X", function(value){ m_editor.toolTextureInfo.scale.x = value; m_toolstate.UVApplyShift(0,0,1,0,0); }, 0.0));
			m_spinner_scale_x.valueType = kValueTypeFloat;
			m_spinner_scale_x.valueIncrements = 0.01;
			m_spinner_shift_x = toolbar.AddElement(AToolbarElementAsSpinner("Texture shift on their local plane", "Shift X", function(value){ m_editor.toolTextureInfo.offset.x = value; m_toolstate.UVApplyShift(1,0,0,0,0); }, 0.0));
			m_spinner_rotation = toolbar.AddElement(AToolbarElementAsSpinner("Texture rotation", "Rotation", function(value){ m_editor.toolTextureInfo.rotation = value; m_toolstate.UVApplyShift(0,0,0,0,1); }, 0.0));
			m_spinner_rotation.valueType = kValueTypeFloat;
			m_spinner_rotation.valueIncrements = 0.5;
			array_push(m_elements, {type: kTextureUIElementTypeToolbar, object: toolbar});
			
			// Second row
			toolbar = new AToolbar();
			toolbar.kBarDirection = kDirRight;
			toolbar.kButtonSize = 12;
			toolbar.kButtonMargin = 2;
			m_spinner_scale_y = toolbar.AddElement(AToolbarElementAsSpinner("Texture scale", "Scale Y", function(value){ m_editor.toolTextureInfo.scale.y = value; m_toolstate.UVApplyShift(0,0,0,1,0); }, 0.0));
			m_spinner_scale_y.valueType = kValueTypeFloat;
			m_spinner_scale_y.valueIncrements = 0.01;
			m_spinner_shift_y = toolbar.AddElement(AToolbarElementAsSpinner("Texture shift on their local plane", "Shift Y", function(value){ m_editor.toolTextureInfo.offset.y = value; m_toolstate.UVApplyShift(0,1,0,0,0); }, 0.0));
			array_push(m_elements, {type: kTextureUIElementTypeToolbar, object: toolbar});
		}
		
		array_push(m_elements, {type: kTextureUIElementTypeLabel, label: "Modify Texture"});
		{	// Options toolbar
			var toolbar = new AToolbar();
			toolbar.kBarDirection = kDirRight;
			toolbar.kButtonSize = 16;
			toolbar.kButtonPadding = 2;
			toolbar.kButtonMargin = 2;
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 7, "Do fit & alignment treating all selected faces as one face?", "Treat as one",
				function(){ m_editor.toolTextureInfo.treatAsOne = !m_editor.toolTextureInfo.treatAsOne; },
				function(){ return m_editor.toolTextureInfo.treatAsOne; }));
			array_push(m_elements, {type: kTextureUIElementTypeToolbar, object: toolbar});
		}
		{	// Alignment toolbar
			var toolbar = new AToolbar();
			toolbar.kBarDirection = kDirRight;
			toolbar.kButtonSize = 16;
			toolbar.kButtonPadding = 2;
			toolbar.kButtonMargin = 2;
			toolbar.AddElement(AToolbarElementAsLabel(null, 0, null, "Align", 20));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 3, "Align texture to closest world XYZ plane",	null, function(){ m_toolstate.UVAlignToWorld() }, null));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 4, "Align texture to face's plane",				null, function(){ m_toolstate.UVAlignToFace() }, null));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 5, "Align texture to the current view's plane",	null, function(){ m_toolstate.UVAlignToView() }, null));
			array_push(m_elements, {type: kTextureUIElementTypeToolbar, object: toolbar});
		}
		{	// Scale toolbar
			var toolbar = new AToolbar();
			toolbar.kBarDirection = kDirRight;
			toolbar.kButtonSize = 16;
			toolbar.kButtonPadding = 2;
			toolbar.kButtonMargin = 2;
			toolbar.AddElement(AToolbarElementAsLabel(null, 0, null, "Scale", 20));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 8, "Scale X to fit", null, function(){ m_toolstate.UVJustifyAndFit(kAlignUnchanged, kAlignUnchanged, 1, 0); }, null));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 9, "Scale X to 1:1", null, function(){ m_editor.toolTextureInfo.scale.x = 1.0; m_toolstate.UVApplyShift(0,0,1,0,0); }, null));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 10, "Scale Y to fit", null, function(){ m_toolstate.UVJustifyAndFit(kAlignUnchanged, kAlignUnchanged, 0, 1); }, null));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 11, "Scale Y to 1:1", null, function(){ m_editor.toolTextureInfo.scale.y = 1.0; m_toolstate.UVApplyShift(0,0,0,1,0); }, null));
			array_push(m_elements, {type: kTextureUIElementTypeToolbar, object: toolbar});
		}
		{	// Rotate toolbar
			var toolbar = new AToolbar();
			toolbar.kBarDirection = kDirRight;
			toolbar.kButtonSize = 16;
			toolbar.kButtonPadding = 2;
			toolbar.kButtonMargin = 2;
			toolbar.AddElement(AToolbarElementAsLabel(null, 0, null, "Rotate", 20));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 12, "Rotate 90 degrees clockwise",		 null, function() { m_toolstate.UVRotate(90); }, null));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 13, "Rotate 90 degrees counterclockwise", null, function() { m_toolstate.UVRotate(-90); }, null));
			array_push(m_elements, {type: kTextureUIElementTypeToolbar, object: toolbar});
		}
		{	// Fit toolbar
			var toolbar = new AToolbar();
			toolbar.kBarDirection = kDirRight;
			toolbar.kButtonSize = 16;
			toolbar.kButtonPadding = 2;
			toolbar.kButtonMargin = 2;
			toolbar.AddElement(AToolbarElementAsLabel(null, 0, null, "Fit", 20));
			toolbar.AddElement(AToolbarElementAsLabel(null, 0, null, "X", -10));
			m_spinner_fit_x = toolbar.AddElement(AToolbarElementAsSpinner("X repeat", "X", null, 1));
			toolbar.AddElement(AToolbarElementAsLabel(null, 0, null, "Y", -10));
			m_spinner_fit_y = toolbar.AddElement(AToolbarElementAsSpinner("Y repeat", "Y", null, 1));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 14, "Fit all", null, function(){ m_toolstate.UVFit(m_spinner_fit_x.PropertyEndEditAndGet(), m_spinner_fit_y.PropertyEndEditAndGet()); }, null));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 15, "Fit X", null, function(){ m_toolstate.UVFit(m_spinner_fit_x.PropertyEndEditAndGet(), 0); }, null));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 16, "Fit y", null, function(){ m_toolstate.UVFit(0, m_spinner_fit_y.PropertyEndEditAndGet()); }, null));
			array_push(m_elements, {type: kTextureUIElementTypeToolbar, object: toolbar});
		}
		{	// Justify toolbar
			var toolbar = new AToolbar();
			toolbar.kBarDirection = kDirRight;
			toolbar.kButtonSize = 16;
			toolbar.kButtonPadding = 2;
			toolbar.kButtonMargin = 2;
			toolbar.AddElement(AToolbarElementAsLabel(null, 0, null, "Justify", 20));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 17, "Align left edge (min x)",	null, function(){ m_toolstate.UVJustifyAndFit(kAlignMin, kAlignUnchanged, 0, 0); }, null));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 18, "Align left edge (max x)",	null, function(){ m_toolstate.UVJustifyAndFit(kAlignMax, kAlignUnchanged, 0, 0); }, null));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 19, "Align top edge (min y)",	null, function(){ m_toolstate.UVJustifyAndFit(kAlignUnchanged, kAlignMin, 0, 0); }, null));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 20, "Align bottom edge (max y)",null, function(){ m_toolstate.UVJustifyAndFit(kAlignUnchanged, kAlignMax, 0, 0); }, null));
			toolbar.AddElement(AToolbarElementAsButtonInfo2(suie_actionsetTextures, 21, "Align to center",			null, function(){ m_toolstate.UVJustifyAndFit(kAlignCenter, kAlignCenter, 0, 0); }, null));
			array_push(m_elements, {type: kTextureUIElementTypeToolbar, object: toolbar});
		}
		
		// Set up initial layout information
		for (var i = 0; i < array_length(m_elements); ++i)
		{
			var element = m_elements[i];
			element.rect = new Rect2(new Vector2(0, 0), new Vector2(0, 0));
		}
	}
	static onCleanup = function()
	{
		for (var i = 0; i < array_length(m_elements); ++i)
		{
			var element = m_elements[i];
			// And clear off the ref to the object
			if (element.type == kTextureUIElementTypeToolbar)
			{
				delete element.object;
			}
		}
		m_elements = [];
	}
	
	l_mouseX = 0;
	l_mouseY = 0;
	static onMouseMove = function(mouseX, mouseY)
	{
		l_mouseX = mouseX;
		l_mouseY = mouseY;
	}
	static Step = function()
	{
		draw_set_font(EditorGetUIFont());
		var ui_scale = EditorGetUIScale();
		
		var topLeft = new Vector2(m_position.x + kElementPadding, m_position.y);
		
		for (var i = 0; i < array_length(m_elements); ++i)
		{
			var element = m_elements[i];
			
			topLeft.floorSelf();
			
			if (element.type == kTextureUIElementTypeToolbar)
			{
				// Set up the position based on the window
				element.object.x = topLeft.x;
				element.object.y = topLeft.y;
				
				element.object.Step(l_mouseX, l_mouseY, true); // Forward mouse position to the toolbar.
				
				// Set up the rest of the positions based on the current toolbar result
				element.rect.m_min.copyFrom(topLeft);
				element.rect.m_max.x = topLeft.x + element.object.GetWidth();
				element.rect.m_max.y = topLeft.y + element.object.GetHeight();
			}
			else if (element.type == kTextureUIElementTypeLabel)
			{
				// Set up the rect based on string
				element.rect.m_min.copyFrom(topLeft);
				element.rect.m_max.x = topLeft.x + string_length(element.label);
				element.rect.m_max.y = topLeft.y + string_height(element.label) * 1.5;
			}
			
			topLeft.y = element.rect.m_max.y + kElementPadding * ui_scale;
		}
		
		// Update the spinner values
		m_spinner_scale_x.PropertySetIfNotEditing(m_editor.toolTextureInfo.scale.x);
		m_spinner_scale_y.PropertySetIfNotEditing(m_editor.toolTextureInfo.scale.y);
		m_spinner_shift_x.PropertySetIfNotEditing(m_editor.toolTextureInfo.offset.x);
		m_spinner_shift_y.PropertySetIfNotEditing(m_editor.toolTextureInfo.offset.y);
		m_spinner_rotation.PropertySetIfNotEditing(m_editor.toolTextureInfo.rotation);
	}
	
	static Draw = function()
	{
		drawWindow();
		
		var topLeft = new Vector2(0, 0);
		
		// Draw the elements
		for (var i = 0; i < array_length(m_elements); ++i)
		{
			var element = m_elements[i];
			
			topLeft.copyFrom(element.rect.m_min);
			
			if (element.type == kTextureUIElementTypeToolbar)
			{
				element.object.Draw();
			}
			else if (element.type == kTextureUIElementTypeLabel)
			{
				draw_set_font(EditorGetUIFont());
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				draw_set_color(c_white);
				draw_text(topLeft.x + 1, topLeft.y + 1, element.label);
			}
		}
	}
}