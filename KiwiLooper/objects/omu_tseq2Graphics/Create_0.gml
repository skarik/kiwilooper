/// @description Initial states

image_alpha = 0.0;

// Need control input for this
controlInit();

// abberate on start
effectAbberate(0.02, 0.05, false);
effectAbberate(0.02, 0.3, true);

// play sound on start
fmusic_fade_all();
sound_play_channel("music/title_guitar.ogg", kFAMixChannelMusic);

// Are we fading in
m_fadeIn = true;

// Current menu selection
#macro kMainMenuOptionBegin 0
#macro kMainMenuOptionContinue 1
#macro kMainMenuOptionBreak 2

m_menuSelection = -1;
m_menuOptionStrings = ["CONTINUE LOOP", "ENTER LOOP", "BREAK"];
m_menuOptions = [kMainMenuOptionContinue, kMainMenuOptionBegin, kMainMenuOptionBreak];
m_menuCallbacks = array_create(3);

m_menuCallbacks[kMainMenuOptionContinue] = function()
{
	Game_LoadMap(Gameplay.m_checkpoint_room);
}

m_menuCallbacks[kMainMenuOptionBegin] = function()
{
	Game_LoadMap(rm_Ship1);
}

m_menuCallbacks[kMainMenuOptionBreak] = function()
{
	game_end();
}