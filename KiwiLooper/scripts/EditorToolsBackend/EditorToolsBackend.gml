#macro kEditorToolSelect		0
#macro kEditorToolZoom			1
#macro kEditorToolCamera		2
#macro kEditorToolTileEditor	3
#macro kEditorToolTileHeight	4
#macro kEditorToolMakeProp		5
#macro kEditorToolMakeEntity	6
#macro kEditorToolTexture		7
#macro kEditorToolSplats		8
#macro kEditorToolTranslate		9
#macro kEditorToolRotate		10
#macro kEditorToolScale			11
#macro kEditorToolMakeSolids	12
#macro kEditorToolTextureSolids	13
#macro kEditorTool_MAX			14

#macro kEditorToolButtonStateNone	0x01
#macro kEditorToolButtonStateMake	0x02
#macro kEditorToolButtonStateHeld	0x04
#macro kEditorToolButtonStateBreak	0x08
#macro kEditorToolButtonFlagInside	0x10
#macro kEditorToolButtonFlagOutside	0x20

#macro kEditorButtonWheelUp		0x1001
#macro kEditorButtonWheelDown	0x1002

#macro kEditorObjectTypeNone	0
#macro kEditorObjectTypeTile	1

function EditorDefaultOnStep()
{ exit; }

function EditorDefaultOnClickWorld(button, buttonState, screenPosition, worldPosition)
{ exit; }

function EditorDefaultOnEnd(trueEnd)
{ exit; }

/// @function AEditorToolState() constructor
/// @desc Default empty state for a tool definition.
function AEditorToolState() constructor
{
	state = -1;
	m_editor = null;
	
	onStep = EditorDefaultOnStep;
	onClickWorld = EditorDefaultOnClickWorld;
	onBegin = EditorDefaultOnStep;
	onEnd = EditorDefaultOnEnd;
}

function EditorToolsSetup()
{
	viewrayPixelPrevious	= [0, 0, 0];
	viewrayPixel			= [0, 0, 0];
	viewrayTopLeft			= [0, 0, 0];
	viewrayBottomRight		= [0, 0, 0];
	viewrayForward			= [0, 0, 0];
	
	toolCurrent = kEditorToolSelect;
	toolCurrentRequested = kEditorToolSelect;
	toolCurrentActive = null;
	toolFlatX = 0;
	toolFlatY = 0;
	toolTileX = 0;
	toolTileY = 0;
	toolWorldX = 0;
	toolWorldY = 0;
	toolWorldZ = 0;
	toolWorldNormal = new Vector3();
	toolWorldValid = false;
	
	toolGrid = true;
	toolGridSize = 16;
	toolGridTemporaryDisable = false;
	toolGridVisible = true;
	
	toolTextureInfo =
	{
		type:		kTextureTypeSpriteTileset,
		source:		stl_lab0,
		index:		1,
		
		mapping:	kSolidMappingWorld,
		normal:		new Vector3(0, 0, 1),
		rotation:	0,
		offset:		new Vector2(0, 0),
		scale:		new Vector2(1, 1),
		
		treatAsOne:	false,
	};
	
	EditorProxyObject_Init();
	
	// Set up all tool states that hold the various tools
	toolStates = [
		new AEditorToolStateSelect(),		// kEditorToolSelect
		new AEditorToolState(),				// kEditorToolZoom
		new AEditorToolStateCamera(),		// kEditorToolCamera
		new AEditorToolStateTileEditor(),	// kEditorToolTileEditor
		new AEditorToolStateTileHeight(),	// kEditorToolTileHeight
		new AEditorToolStateMakeProp(),		// kEditorToolMakeProp
		new AEditorToolStateMakeEntity(),	// kEditorToolMakeEntity
		new AEditorToolStateTexturing(),	// kEditorToolTexture
		new AEditorToolStateMakeSplat(),	// kEditorToolSplats
		new AEditorToolStateTranslate(),	// kEditorToolTranslate
		new AEditorToolStateRotate(),		// kEditorToolRotate
		new AEditorToolStateScale(),		// kEditorToolScale
		new AEditorToolStateMakeSolids(),	// kEditorToolMakeSolids
		new AEditorToolStateTextureSolids(),// kEditorToolTextureSolids
		];
	assert(array_length(toolStates) == kEditorTool_MAX);
	
	// Set all the tools' editor
	for (var i = 0; i < array_length(toolStates); ++i)
	{
		if (is_struct(toolStates[i]))
		{
			toolStates[i].m_editor = this;
		}
	}
	
	// Set up shortcuts now as well
	EditorToolsSetup_Shortcuts();
}

/// @function AEditorToolShortcut(name, keypress, modifiers, action)
/// @param name {String}
/// @param keypress {VKCode}
/// @param modifiers {Undefined or VKCode Array}
/// @param action {Function}
function AEditorToolShortcut(name, keypress, modifiers, action) constructor
{
	m_name = name;
	m_keypress = keypress;
	m_hasModifiers = !is_undefined(modifiers) && is_array(modifiers);
	m_modifiers = modifiers;
	m_action = action;
}

/// @desc Sets up all keyboard shortcuts in the editor
function EditorToolsSetup_Shortcuts()
{
	toolShortcuts = [
		new AEditorToolShortcut("Select Tool", ord("Q"), undefined, function(){ toolCurrentRequested = kEditorToolSelect; }),
		new AEditorToolShortcut("Translate Tool", ord("W"), undefined, function(){ toolCurrentRequested = kEditorToolTranslate; }),
		new AEditorToolShortcut("Rotate Tool", ord("E"), undefined, function(){ toolCurrentRequested = kEditorToolRotate; }),
		new AEditorToolShortcut("Scale Tool", ord("R"), undefined, function(){ toolCurrentRequested = kEditorToolScale; }),
		new AEditorToolShortcut("Translate Tool", ord("E"), [vk_control], EditorCameraCenterOnSelection),
		
		new AEditorToolShortcut("Grid Smaller", /*vk_oem_4*/0xDB, undefined, EditorToolGridSmaller),
		new AEditorToolShortcut("Grid Larger", /*vk_oem_6*/0xDD, undefined, EditorToolGridLarger),
		
		new AEditorToolShortcut("Copy Selection", ord("C"), [vk_control], function(){ if (toolCurrent != kEditorToolCamera) EditorClipboardSelectionUpdate(); }),
		new AEditorToolShortcut("Paste", ord("V"), [vk_control], function(){ if (toolCurrent != kEditorToolCamera) EditorClipboardSelectionPaste(); }),
		new AEditorToolShortcut("Delete Selection", vk_delete, undefined, function(){ if (toolCurrent != kEditorToolCamera) EditorGlobalDeleteSelection(); }),
		new AEditorToolShortcut("Clear Selection", vk_escape, undefined, function(){ if (toolCurrent != kEditorToolCamera) EditorGlobalClearSelection(); }),
		
		new AEditorToolShortcut("Save", ord("S"), [vk_control], EditorGlobalSaveMap),
		new AEditorToolShortcut("Load", ord("O"), [vk_control], EditorGlobalLoadMap),
		new AEditorToolShortcut("New", ord("N"), [vk_control], EditorGlobalNukeMap),
	];
}

function EditorToolsUpdate_CheckShortcuts()
{
	if (!WindowingHasConsumingFocus())
	{
		for (var shortcutIndex = 0; shortcutIndex < array_length(toolShortcuts); ++shortcutIndex)
		{
			var shortcut = toolShortcuts[shortcutIndex];
			
			if (keyboard_check_pressed(shortcut.m_keypress))
			{
				var bCanPress = true;
				if (shortcut.m_hasModifiers)
				{
					// Ensure all modifiers are held
					for (var keyIndex = 0; keyIndex < array_length(shortcut.m_modifiers); ++keyIndex)
					{
						if (!keyboard_check(shortcut.m_modifiers[keyIndex]))
						{
							bCanPress = false;
							break;
						}
					}
				}
				
				// If marked Can Press, then execute the action
				var shortcut_action = shortcut.m_action;
				shortcut_action();
			}
		}
	}
	
	// Special state override:
	if (keyboard_check(vk_space)
		&& (mouse_check_button(mb_left) || mouse_check_button(mb_right) || mouse_check_button(mb_middle)
			|| mouse_check_button_released(mb_left) || mouse_check_button_released(mb_right) || mouse_check_button_released(mb_middle)))
	{
		toolCurrent = kEditorToolCamera;
	}
	else if (mouse_check_button(mb_middle) || mouse_check_button_released(mb_middle))
	{
		// Game-style view rotate
		toolCurrent = kEditorToolCamera;
	}
	else
	{
		toolCurrent = toolCurrentRequested;
	}
	// Other camera inputs
	if (!m_toolbar.ContainsMouse() && !m_actionbar.ContainsMouse() && !m_minimenu.ContainsMouse() && !WindowingContainsMouse())
	{
		if (mouse_wheel_down())
		{
			m_state.camera.zoom += 0.05;
		}
		else if (mouse_wheel_up())
		{
			m_state.camera.zoom -= 0.05;
		}
		m_state.camera.zoom = max(0.05, m_state.camera.zoom);
	}
}

function EditorToolsUpdate()
{
	// Update mouse positions
	var pixelX = uPosition - GameCamera.view_x;
	var pixelY = vPosition - GameCamera.view_y;
	
	var viewRayPos = [o_Camera3D.x, o_Camera3D.y, o_Camera3D.z];
	var viewRayDir = o_Camera3D.viewToRay(pixelX, pixelY);
	
	// Collide with the flat XYZ
	if (raycast4_axisplane(kAxisZ, 0.0, Vector3FromArray(viewRayPos), Vector3FromArray(viewrayPixel)))
	{
		toolFlatX = viewRayPos[0] + viewRayDir[0] * raycast4_get_hit_distance();
		toolFlatY = viewRayPos[1] + viewRayDir[1] * raycast4_get_hit_distance();
	}
	
	toolTileX = max(0, floor(toolFlatX / 16));
	toolTileY = max(0, floor(toolFlatY / 16));
	
	viewrayPixelPrevious= viewrayPixel;
	viewrayPixel		= viewRayDir;
	viewrayTopLeft		= o_Camera3D.viewToRay(0, 0);
	viewrayBottomRight	= o_Camera3D.viewToRay(GameCamera.width, GameCamera.height);
	viewrayForward		= [
		(viewrayTopLeft[0] + viewrayBottomRight[0]) * 0.5,
		(viewrayTopLeft[1] + viewrayBottomRight[1]) * 0.5,
		(viewrayTopLeft[2] + viewrayBottomRight[2]) * 0.5];
		
	// Do picker collision with the map
	{
		var pickerObjects = [];
		var pickerDistances = [];
		var pickerNormals = [];
		var pickerCount = EditorPickerCast(Vector3FromArray(viewRayPos), Vector3FromArray(viewrayPixel), pickerObjects, pickerDistances, pickerNormals, kPickerHitMaskTilemap | kPickerHitMaskProp, false, m_selection);
		if (pickerCount > 0)
		{
			toolWorldX = viewRayPos[0] + viewrayPixel[0] * pickerDistances[0];
			toolWorldY = viewRayPos[1] + viewrayPixel[1] * pickerDistances[0];
			toolWorldZ = viewRayPos[2] + viewrayPixel[2] * pickerDistances[0];
			toolWorldNormal.copyFrom(pickerNormals[0]);
			toolWorldNormal.normalize(); // For safety
			toolWorldValid = true;
		}
		else
		{
			toolWorldValid = false;
		}
	}
	
	// Check shortcuts before state update, since shortcuts can do temp state changes
	EditorToolsUpdate_CheckShortcuts();
	
	// Update the states now:
	{
		var currentToolState = toolStates[toolCurrent];
		
		// Update begin and end states
		if (toolCurrentActive != toolCurrent)
		{
			m_statusbar.m_toolHelpText = "";
			
			if (toolCurrentActive >= 0 && toolCurrentActive < array_length(toolStates))
			{
				toolStates[toolCurrentActive].m_editor = this;
				toolStates[toolCurrentActive].onEnd(toolCurrent == toolCurrentRequested);
			}
			toolCurrentActive = toolCurrent;
			currentToolState.m_editor = this;
			currentToolState.onBegin();
		}
		
		// Perform per-frame update
		currentToolState.m_editor = this;
		currentToolState.onStep();
	
		// Check all mouse buttons and forward them to the state as well.
		if (!m_toolbar.ContainsMouse() && !m_actionbar.ContainsMouse() && !m_minimenu.ContainsMouse() && !WindowingContainsMouse()) // TODO: also check for gizmo states
		{
			var kPixelPosition = new Vector2(pixelX, pixelY);
			var kWorldPosition = toolWorldValid
				? new Vector3(toolWorldX, toolWorldY, toolWorldZ)
				: new Vector3(toolFlatX, toolFlatY, 0);
			
			var mouse_buttons = [mb_left, mb_right, mb_middle];
			for (var iButton = 0; iButton < array_length(mouse_buttons); ++iButton)
			{
				var currentButton = mouse_buttons[iButton];
				if (mouse_check_button_pressed(currentButton))
				{
					currentToolState.onClickWorld(currentButton, kEditorToolButtonStateMake, kPixelPosition, kWorldPosition);
				}
				if (mouse_check_button_released(currentButton))
				{
					currentToolState.onClickWorld(currentButton, kEditorToolButtonStateBreak, kPixelPosition, kWorldPosition);
				}
				if (mouse_check_button(currentButton))
				{
					currentToolState.onClickWorld(currentButton, kEditorToolButtonStateHeld, kPixelPosition, kWorldPosition);
				}
			}
			
			delete kPixelPosition;
			delete kWorldPosition;
		}
	}
}

function EditorToolCurrent()
{
	with (EditorGet())
	{
		return toolCurrent;
	}
	return null;
}

function EditorToolInstance()
{
	with (EditorGet())
	{
		return toolStates[toolCurrent];
	}
	return null;
}

function EditorToolGetInstance(type)
{
	with (EditorGet())
	{
		return toolStates[type];
	}
	return null;
}

//=============================================================================

function EditorToolGridToggle()
{
	with (EditorGet())
	{
		toolGrid = !toolGrid;
	}
}

function EditorToolGridLarger()
{
	with (EditorGet())
	{
		toolGridSize = min(128, toolGridSize * 2);
		m_actionbar.labelGridSize.m_text = "Grid: " + string(toolGridSize);
	}
}

function EditorToolGridSmaller()
{
	with (EditorGet())
	{
		toolGridSize = max(1, toolGridSize / 2);
		m_actionbar.labelGridSize.m_text = "Grid: " + string(toolGridSize);
	}
}
