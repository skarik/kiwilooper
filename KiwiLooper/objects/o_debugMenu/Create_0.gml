/// @description Init state and create Debug UI

// State:
uiMouseX = 0;
uiMouseY = 0;
image_alpha = 0.0;

// Debug UI:
uiListing = ds_list_create();
ds_list_add(uiListing, inew(o_debugCmdline));
ds_list_add(uiListing, inew(o_debugAiVisualizer));
ds_list_add(uiListing, inew(o_debugPowerVisualizer));
ds_list_add(uiListing, instance_create_depth(300, 100, 0, o_debugUiButton_KillPlayer));