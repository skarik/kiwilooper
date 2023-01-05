/// @function Game_IsPlayer_safe( instance )
/// @desc Checks if given instance is a player
function Game_IsPlayer_safe( instance )
{
	return iexists(instance)
			&& object_is_ancestor(instance.object_index, ob_character)
			&& instance.isPlayer;
};