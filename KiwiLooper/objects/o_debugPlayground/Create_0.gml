/// @description Set up playground

// Get full width for colors
paletteSetCurrent(kPaletteWide);

// Controls
uPosition = 0;
vPosition = 0;

m_control_dragging = false;
m_control_drag_origin = [0, 0];
m_control_drag_reference = [0, 0];

// NPC selection
m_npc_selection = null;

// Set up drawing
depth = kUiDepthHudBase;
