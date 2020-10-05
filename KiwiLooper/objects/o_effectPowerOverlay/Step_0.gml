/// @description Update if powered

if (!iexists(o_livelyRoomState))
{
	visible = true;
}
else
{
	visible = o_livelyRoomState.powered;
}