/// @description Update the test (Camera & Editor)

controlUpdate(false);

m_toolbar.x = 10;
m_toolbar.y = 20;
m_toolbar.Step(uPosition - GameCamera.view_x, vPosition - GameCamera.view_y);

EditorCameraUpdate();
EditorGizmoUpdate(); // must always be before ToolsUpdate due to overriding some tool items

EditorToolsUpdate();