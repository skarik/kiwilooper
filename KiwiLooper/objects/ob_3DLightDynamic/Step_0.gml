/// @description Update Light

// TODO: make this branch compile out in builds? may not be a perf issue
if (EditorGet() != null)
{
	SelectLightMode();
}

m_lightStepper();
