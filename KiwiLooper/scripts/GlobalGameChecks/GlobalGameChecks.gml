/// @function Game_IsPlayer_safe( instance )
/// @desc Checks if given instance is a player
function Game_IsPlayer_safe( instance )
{
	return iexists(instance)
			&& object_is_ancestor(instance.object_index, ob_character)
			&& instance.isPlayer;
};

/// @function Game_IsInEditor()
/// @desc Returns if we're in an editor sesh instead of in-game
function Game_IsInEditor()
{
	return iexists(EditorGet());
}