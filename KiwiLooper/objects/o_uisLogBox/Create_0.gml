/// @description Set up draw state

// Inherit the parent event
event_inherited();

m_messageString = "Test string";
m_messageStringQueued = "";
m_wantsFade = false;

m_displayNext = false;
m_displayFade = 0.0;
m_displayString = "";
m_displayLength = 0;


controlInit();