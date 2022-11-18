/// @description Insert description here
// You can write your code in this editor

controlCleanup();

meshB_Cleanup(meshUIBits);
meshB_Cleanup(meshMenuBits);
idelete(m_renderer);
idelete(m_rendererMenu);

Time.scale = 1.0;