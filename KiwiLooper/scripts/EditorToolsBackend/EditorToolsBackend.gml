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
#macro kEditorTool_MAX			12

#macro kEditorToolButtonStateNone	0
#macro kEditorToolButtonStateMake	1
#macro kEditorToolButtonStateHeld	2
#macro kEditorToolButtonStateBreak	3

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
		new AEditorToolState(),
		new AEditorToolState(),
		new AEditorToolStateTranslate(),	// kEditorToolTranslate
		new AEditorToolStateRotate(),		// kEditorToolRotate
		new AEditorToolState(),
		];
	assert(array_length(toolStates) == kEditorTool_MAX);
}

function EditorToolsUpdate()
{
	// Update mouse positions
	var pixelX = uPosition - GameCamera.view_x;
	var pixelY = vPosition - GameCamera.view_y;
	
	var viewRayPos = [o_Camera3D.x, o_Camera3D.y, o_Camera3D.z];
	var viewRayDir = o_Camera3D.viewToRay(pixelX, pixelY);
	
	//var distT = abs(viewRayPos[2] / viewRayDir[2]);
	//toolFlatX = viewRayPos[0] + viewRayDir[0] * distT;
	//toolFlatY = viewRayPos[1] + viewRayDir[1] * distT;
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
	if (raycast4_tilemap(Vector3FromArray(viewRayPos), Vector3FromArray(viewrayPixel)))
	{
		toolWorldX = viewRayPos[0] + viewrayPixel[0] * raycast4_get_hit_distance();
		toolWorldY = viewRayPos[1] + viewrayPixel[1] * raycast4_get_hit_distance();
		toolWorldZ = viewRayPos[2] + viewrayPixel[2] * raycast4_get_hit_distance();
		toolWorldNormal.copyFrom(raycast4_get_hit_normal());
		toolWorldValid = true;
	}
	else
	{
		toolWorldValid = false;
	}
	
	// Hard-coded shortcuts:
	if (keyboard_check_pressed(ord("Q")))
	{
		toolCurrentRequested = kEditorToolSelect;
	}
	if (keyboard_check_pressed(ord("W")))
	{
		toolCurrentRequested = kEditorToolTranslate;
	}
	
	// Hard-coded command overrides:
	
	// Delete selected objects
	if (keyboard_check_pressed(vk_delete)
		&& toolCurrent != kEditorToolCamera
		&& !WindowingHasConsumingFocus())
	{
		EditorGlobalDeleteSelection();
	}
	// Clear selection
	if (keyboard_check_pressed(vk_escape)
		&& toolCurrent != kEditorToolCamera
		&& !WindowingHasFocus())
	{
		EditorGlobalClearSelection();
	}
	
	// Special state override:
	if (keyboard_check(vk_space)
		&& (mouse_check_button(mb_left) || mouse_check_button(mb_right) || mouse_check_button(mb_middle)
			|| mouse_check_button_released(mb_left) || mouse_check_button_released(mb_right) || mouse_check_button_released(mb_middle)))
	{
		toolCurrent = kEditorToolCamera;
	}
	else
	{
		toolCurrent = toolCurrentRequested;
	}
	
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
		if (!m_toolbar.ContainsMouse() && !WindowingContainsMouse()) // TODO: also check for gizmo states
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