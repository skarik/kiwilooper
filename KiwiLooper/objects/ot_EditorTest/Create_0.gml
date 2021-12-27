/// @description Set up camera & routines.

event_inherited();

// Need control input for this
controlInit();

x = 0;
y = 0;
z = 0;

#macro kEditorToolSelect		0
#macro kEditorToolZoom			1
#macro kEditorToolCamera		2
#macro kEditorToolTileEditor	3
#macro kEditorToolTileHeight	4
#macro kEditorToolMakeProp		5
#macro kEditorToolMakeEntity	6
#macro kEditorToolTexture		7
#macro kEditorToolSplats		8

toolCurrent = kEditorToolSelect;
toolFlatX = 0;
toolFlatY = 0;
toolTileX = 0;
toolTileY = 0;

CameraSetup = function()
{
	cameraRotZSpeed = 0.0;
	cameraRotYSpeed = 0.0;
	
	cameraRotZ = 45;
	cameraRotY = 60;
	cameraZoom = 1.0;
	
	zstart = z;
}
CameraUpdate = function()
{
	o_Camera3D.zrotation = cameraRotZ;
	o_Camera3D.yrotation = cameraRotY;

	var kCameraDistance = 1200 * cameraZoom;
	o_Camera3D.x = lengthdir_x(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
	o_Camera3D.y = lengthdir_y(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
	o_Camera3D.z = lengthdir_y(-kCameraDistance, o_Camera3D.yrotation);

	o_Camera3D.orthographic = false;
	o_Camera3D.fov_vertical = 10;
}

GizmoSetup = function()
{
	m_gizmoObject = inew(ob_3DObject);
	
	m_gizmoObject.m_renderEvent = function()
	{
		// Draw 3D tools.

		draw_set_color(c_white);
		draw_rectangle(16, 16, 32, 32, true);
		draw_rectangle(-16, 16, -32, 32, true);
		draw_rectangle(16, -16, 32, -32, true);
		draw_rectangle(-16, -16, -32, -32, true);
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_font(f_Oxygen7);
		draw_text(32+4, 16, "+x");
		draw_text(16, 32+4, "+y");
		
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_text(-32-4, -16, "-x");
		draw_text(-16, -32-4, "-y");
		
		draw_circle(toolFlatX, toolFlatY, 4, true);
		draw_rectangle(toolTileX * 16, toolTileY * 16, toolTileX * 16 + 16, toolTileY * 16 + 16, true);
	}
}
GizmoUpdate = function()
{
	var pixelX = uPosition - GameCamera.view_x;
	var pixelY = vPosition - GameCamera.view_y;
	
	var viewRayPos = [o_Camera3D.x, o_Camera3D.y, o_Camera3D.z];
	var viewRayDir = o_Camera3D.viewToPosition(pixelX, pixelY);
	
	var distT = abs(viewRayPos[2] / viewRayDir[2]);
	
	toolFlatX = viewRayPos[0] + viewRayDir[0] * distT;
	toolFlatY = viewRayPos[1] + viewRayDir[1] * distT;
	
	toolTileX = max(0, floor(toolFlatX / 16));
	toolTileY = max(0, floor(toolFlatY / 16));
}

/// @function AMapTile() constructor
/// @notes A map tile that represents a filled tile in the map.
AMapTile = function() constructor
{
	floorType = 1;
	wallType = 1;
	height = 0;
	
	x = 0;
	y = 0;
}

// An unordered array of all map tiles.
mapTiles = [];
// List of all used heights.
mapUsedHeights = [];

MapHasPosition = function(x, y)
{
	for (var tileIndex = 0; tileIndex < array_length(mapTiles); ++tileIndex)
	{
		var tileInfo = mapTiles[tileIndex];
		if (tileInfo.x == x && tileInfo.y == y)
		{
			return true;
		}
	}
	return false;
}

MapAddHeight = function(height)
{
	if (!array_contains(mapUsedHeights, height))
	{
		array_push(mapUsedHeights, height);
	}
}
MapRemoveHeightSlow = function(height)
{
	for (var tileIndex = 0; tileIndex < array_length(mapTiles); ++tileIndex)
	{
		var tileInfo = mapTiles[tileIndex];
		if (tileInfo.height == height)
		{
			return;
		}
	}
	for (var heightIndex = 0; heightIndex < array_length(mapUsedHeights); ++heightIndex)
	{
		if (mapUsedHeights[heightIndex] == height)
		{
			array_delete(mapUsedHeights, heightIndex, 1);
		}
	}
}

// List of all layers currently used for the tiles and props.
intermediateLayers = [];

MapRebuildGraphics = function()
{
	// Delete existing renderers
	idelete(o_tileset3DIze);
	idelete(o_props3DIze);
	
	// Delete all current intermediate layers
	for (var layerIndex = 0; layerIndex < array_length(intermediateLayers); ++layerIndex)
	{
		layer_destroy(intermediateLayers[layerIndex]);
	}
	intermediateLayers = [];
	
	// Set up the layers
	{
		// Start with the floors
		for (var layerIndex = 0; layerIndex < array_length(mapUsedHeights); ++layerIndex)
		{
			var layerHeight = mapUsedHeights[layerIndex];
		
			var newTileLayer = layer_create(100 - layerHeight, "floor" + string(layerHeight));
			array_push(intermediateLayers, newTileLayer);
			
			var tilemap = layer_tilemap_create(newTileLayer, 0, 0, tileset_lab0, 256, 256);
			for (var tileIndex = 0; tileIndex < array_length(mapTiles); ++tileIndex)
			{
				// If tile matches the height, then we add it to the rendering
				var tileInfo = mapTiles[tileIndex];
				if (tileInfo.height == layerHeight)
				{
					tilemap_set(tilemap, tile_set_index(0, tileInfo.floorType), tileInfo.x, tileInfo.y);
				}
			}
		}
		
		// Finish up with the walls
		{
			var newTileLayer = layer_create(50, "walls");
			array_push(intermediateLayers, newTileLayer);
			
			// TODO: only add walls to tiles with a lower height.
			var tilemap = layer_tilemap_create(newTileLayer, 0, 0, tileset_lab0, 256, 256);
			for (var tileIndex = 0; tileIndex < array_length(mapTiles); ++tileIndex)
			{
				var tileInfo = mapTiles[tileIndex];
				tilemap_set(tilemap, tile_set_index(0, tileInfo.wallType), tileInfo.x, tileInfo.y);
			}
		}
	}
	
	// Create the 3d-ify chain
	inew(o_tileset3DIze);
}

/// @function AToolbar() constructor
/// @notes A toolbar for rendering a vertical selection menu.
AToolbar = function() constructor
{
	kButtonSize		= 22;
	kSpacerSize		= 3;
	kTooltipShowTime= 0.5;
	
	m_elements		= [];
	m_elementsCount	= 0;
	m_elementsHeight= 0;
	
	m_state_containsMouse	= false;
	
	x = 0;
	y = 0;
	
	static AddElement = function(elementToAdd)
	{
		m_elements[m_elementsCount] = elementToAdd;
		m_elementsCount = array_length(m_elements);
		
		return elementToAdd;
	};
	
	static Step = function(mouseX, mouseY)
	{
		m_state_containsMouse = false;
		
		var topLeft = new Vector2(x, y);
		for (var elementIndex = 0; elementIndex < m_elementsCount; ++elementIndex)
		{
			var element = m_elements[elementIndex];
			
			// Check if mouse is inside
			if (element.m_isButton)
			{
				element.m_state_isDown = element.m_onCheckDown();
				
				if (point_in_rectangle(mouseX, mouseY, topLeft.x, topLeft.y, topLeft.x + kButtonSize, topLeft.y + kButtonSize))
				{
					element.m_state_isHovered = true;
					element.m_state_hoveredTime += Time.deltaTime;
					if (element.m_state_hoveredTime > kTooltipShowTime)
					{
						element.m_state_showTooltip = true;
					}
					
					if (mouse_check_button_pressed(mb_left))
					{
						element.m_onClick();
						element.m_state_isDown = true;
					}
					
					m_state_containsMouse = true;
				}
				else if (element.m_state_isHovered)
				{
					// Mouse not inside, reset all the hover states.
					element.m_state_isHovered = false;
					element.m_state_hoveredTime = 0.0;
					element.m_state_showTooltip = false;
				}
			}
			
			// Advance cursor.
			topLeft.y += element.m_isButton ? kButtonSize : kSpacerSize;
		}
		m_elementsHeight = topLeft.y - y;
	}
	
	static ContainsMouse = function()
	{
		return m_state_containsMouse;
	}
	
	static Draw = function()
	{
		draw_set_alpha(1.0);
		
		var topLeft = new Vector2(x, y);
		for (var elementIndex = 0; elementIndex < m_elementsCount; ++elementIndex)
		{
			var element = m_elements[elementIndex];
			
			// Check if mouse is inside
			if (element.m_isButton)
			{
				draw_set_color(element.m_state_isHovered ? c_white : c_gray);
				DrawSpriteRectangle(topLeft.x, topLeft.y,
									topLeft.x + kButtonSize, topLeft.y + kButtonSize,
									true);
				if (element.m_state_isDown)
				{
					draw_set_color(c_gray);
					DrawSpriteRectangle(topLeft.x, topLeft.y,
										topLeft.x + kButtonSize, topLeft.y + kButtonSize,
										false);
				}
				
				draw_sprite(element.m_sprite, element.m_spriteIndex, topLeft.x + 1, topLeft.y + 1);
				
				if (element.m_state_showTooltip)
				{
					draw_set_font(f_04b03);
					var tooltipLength = string_width(element.m_tooltip);
					var tooltipHeight = string_height(element.m_tooltip);
					
					draw_set_color(c_black);
					DrawSpriteRectangle(topLeft.x + kButtonSize + 1, topLeft.y,
										topLeft.x + kButtonSize + 2 + 3 + tooltipLength,
										topLeft.y + 4 + tooltipHeight,
										false);
					draw_set_color(c_white);
					DrawSpriteRectangle(topLeft.x + kButtonSize + 1, topLeft.y,
										topLeft.x + kButtonSize + 2 + 3 + tooltipLength,
										topLeft.y + 4 + tooltipHeight,
										true);
					
					draw_set_halign(fa_left);
					draw_set_valign(fa_top);
					draw_text(topLeft.x + kButtonSize + 3, topLeft.y + 2, element.m_tooltip);
				}
			}
			else
			{
				draw_set_color(c_gray);
				DrawSpriteLine(topLeft.x + 1, topLeft.y + 1, topLeft.x + kButtonSize - 1, topLeft.y + 1);
			}
			
			// Advance cursor.
			topLeft.y += element.m_isButton ? kButtonSize : kSpacerSize;
		}
	};
}
/// @function AToolbarElement() constructor
/// @notes A toolbar element for the AToolbar structure
AToolbarElement = function() constructor
{
	m_isButton		= false; // If false, then is a separator.
	m_onClick		= function() {};
	m_onCheckDown	= function() { return false; };
	m_sprite		= sui_handy;
	m_spriteIndex	= 0;
	m_tooltip		= "Handy";
	
	m_state_isHovered	= false;
	m_state_hoveredTime	= 0.0;
	m_state_showTooltip	= false;
	m_state_isDown		= false;
	
	m_editor		= instance_find(ot_EditorTest, 0);
}
/// @function AToolbarElementAsButtonInfo(sprite, spriteIndex, tooltip, onClick, onCheckDown)
/// @param {Sprite} UI Icon
/// @param {Real} UI Icon image_index
/// @param {String} Hover tooltip
/// @param {Function} onClick callback
/// @param {Function} onCheckDown callback
AToolbarElementAsButtonInfo = function(sprite, spriteIndex, tooltip, onClick, onCheckDown)
{
	element = new AToolbarElement();
	element.m_isButton = true;
	element.m_onClick = onClick;
	element.m_onCheckDown = onCheckDown;
	element.m_sprite = sprite;
	element.m_spriteIndex = spriteIndex;
	element.m_tooltip = tooltip;
	return element;
}
/// @function AToolbarElementAsToolButtonInfo(sprite, spriteIndex, tooltip, editorState)
/// @param {Sprite} UI Icon
/// @param {Real} UI Icon image_index
/// @param {String} Hover tooltip
/// @param {kEditorTool} Tool to check against
AToolbarElementAsToolButtonInfo = function(sprite, spriteIndex, tooltip, editorState)
{
	var button = AToolbarElementAsButtonInfo(sprite, spriteIndex, tooltip, null, null);
	with (button)
	{
		m_local_editorState = editorState;
		m_onClick = function()
		{
			m_editor.toolCurrent = m_local_editorState;
		};
		m_onCheckDown = function()
		{
			return m_editor.toolCurrent == m_local_editorState;
		};
	}
	return button;
}

// Create toolbar
{
	m_toolbar = new AToolbar();
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 0, "Select", kEditorToolSelect));
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 1, "Zoom", kEditorToolZoom));
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 2, "Camera", kEditorToolCamera));
	m_toolbar.AddElement(new AToolbarElement());
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetTiles, 1, "Add/Subtract Tiles", kEditorToolTileEditor));
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetTiles, 2, "Edit Elevation", kEditorToolTileHeight));
	m_toolbar.AddElement(new AToolbarElement());
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetObject, 0, "Add Prop", kEditorToolMakeProp));
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetObject, 1, "Add Entity", kEditorToolMakeEntity));
	m_toolbar.AddElement(new AToolbarElement());
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetTexture, 0, "Texture", kEditorToolTexture));
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetTexture, 1, "Splats", kEditorToolSplats));
}

CameraSetup();
GizmoSetup();