/// @description Check for player to arrive

if (place_meeting(x, y, o_playerKiwi))
{
	// TODO: do this goal better
	//room_goto_next();
	//game_restart();
	room_goto(rm_Menu);
}