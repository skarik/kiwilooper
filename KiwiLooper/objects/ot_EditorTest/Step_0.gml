/// @description Update the test (Camera & Editor)

controlUpdate(false);

EditorUIBitsUpdate();

EditorCameraUpdate();
EditorGizmoUpdate(); // must always be before ToolsUpdate due to overriding some tool items

EditorToolsUpdate();