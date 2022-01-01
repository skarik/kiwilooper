#macro kEditorToolSelect		0
#macro kEditorToolZoom			1
#macro kEditorToolCamera		2
#macro kEditorToolTileEditor	3
#macro kEditorToolTileHeight	4
#macro kEditorToolMakeProp		5
#macro kEditorToolMakeEntity	6
#macro kEditorToolTexture		7
#macro kEditorToolSplats		8
#macro kEditorTool_MAX			9

#macro kEditorToolButtonStateMake	0
#macro kEditorToolButtonStateHeld	1
#macro kEditorToolButtonStateBreak	2

function EditorDefaultOnStep()
{ exit; }

function EditorDefaultOnClickWorld(button, buttonState, screenPosition, worldPosition)
{ exit; }

/// @function AEditorToolState() constructor
/// @desc Default empty state for a tool definition.
function AEditorToolState() constructor
{
	state = -1;
	m_editor = null;
	
	onStep = EditorDefaultOnStep;
	onClickWorld = EditorDefaultOnClickWorld;
}

function EditorToolsSetup()
{
	toolCurrent = kEditorToolSelect;
	toolFlatX = 0;
	toolFlatY = 0;
	toolTileX = 0;
	toolTileY = 0;
	
	// Set up all tool states that hold the various tools
	toolStates = [
		new AEditorToolStateSelect(),		// kEditorToolSelect
		new AEditorToolState(),				// kEditorToolZoom
		new AEditorToolStateCamera(),		// kEditorToolCamera
		new AEditorToolStateTileEditor(),	// kEditorToolTileEditor
		new AEditorToolStateTileHeight(),	// kEditorToolTileHeight
		new AEditorToolState(),
		new AEditorToolState(),
		new AEditorToolState(),
		new AEditorToolState()
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
	
	var distT = abs(viewRayPos[2] / viewRayDir[2]);
	
	toolFlatX = viewRayPos[0] + viewRayDir[0] * distT;
	toolFlatY = viewRayPos[1] + viewRayDir[1] * distT;
	
	toolTileX = max(0, floor(toolFlatX / 16));
	toolTileY = max(0, floor(toolFlatY / 16));
	
	// Update the states now:
	{
		var currentToolState = toolStates[toolCurrent];
		currentToolState.m_editor = this;
		
		// Perform per-frame update
		currentToolState.onStep();
	
		// Check all mouse buttons and forward them to the state as well.
		if (!m_toolbar.ContainsMouse())
		{
			var kPixelPosition = new Vector2(pixelX, pixelY);
			var kWorldPosition = new Vector3(toolFlatX, toolFlatY, 0);
			
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