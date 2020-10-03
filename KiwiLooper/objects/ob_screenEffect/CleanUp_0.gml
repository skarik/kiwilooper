/// @description Mark render list dirty

if (m_applyToGame)
{
	Screen.m_renderQueue_GameEffectDirty = true;
}
if (m_applyToUI)
{
	Screen.m_renderQueue_UIEffectDirty = true;
}