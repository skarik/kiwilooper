/// @function assert(condition)
/// @desc Errors out in debug mode if the condition is not true. May not execute in release.
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

/// @function ensure(condition)
/// @desc Errors out in debug mode if the condition is not true. Will always execute.
/// @param {Real or Bool} Condition to check.
function ensure(condition)
{
	gml_pragma("forceinline");
	if (debug_mode)
	{
		if (!condition)
		{
			show_error("ASSERT FAILED", true);
		}
	}
	return condition;
}