/// @function assert(condition)
/// @desc Errors out in debug mode if the condition is not true.
/// @param {Real or Bool} Condition to check.
function assert(condition)
{
	gml_pragma("forceinline");
	if (debug_mode)
	{
		if (!condition)
		{
			show_error("ASSERT FAILED", true);
		}
	}
}