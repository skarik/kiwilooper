/// @func array_any_not(array, value)
/// @param array {Array 1d}
/// @param value
function array_any_not(array, value)
{
	var len = array_length(array);
	for (var i = 0; i < len; ++i)
	{
		if (array[i] != value)
		{
			return true;
		}
	}
	return false;
}

/// @function array_is_any_of(array, callback)
function array_is_any_of(_array, _callback)
{
	gml_pragma("forceinline");
	var i = 0;
	repeat (array_length(_array))
	{
		if (_callback(_array[i], i)) return true;
		++i;
	}
	return false;
}

/// @function array_is_none_of(array, callback)
function array_is_none_of(_array, _callback)
{
	gml_pragma("forceinline");
	var i = 0;
	repeat (array_length(_array))
	{
		if (_callback(_array[i], i)) return false;
		++i;
	}
	return true;
}

/// @function array_is_mismatch(array1, array2, eq_callback)
function array_is_mismatch(_array1, _array2, _eq_callback)
{
	gml_pragma("forceinline");
	var array1_len = array_length(_array1);
	if (array1_len != array_length(_array2))
	{
		return true;
	}
	var i = 0;
	repeat (array1_len)
	{
		if (!_eq_callback(_array1[i], _array2[i]))
		{
			return true;
		}
		++i;
	}
	return false;
}

/// @function array_get_index_pred(array, value, eq_callback)
function array_get_index_pred(array, value, eq_callback)
{
	var i = 0;
	repeat (array_length(array))
	{
		if (eq_callback(array[i], value)) return i;
		++i;
	}
	return null;
}

/// @func array_contains(array, value)
/// @param array {Array 1d}
/// @param value
function array_contains(array, value)
{
	var len = array_length(array);
	for (var i = 0; i < len; ++i)
	{
		if (array[i] == value)
		{
			return true;
		}
	}
	return false;
}

/// @func array_contains_pred(array, value, eq_callback)
/// @param array {Array 1d}
/// @param value
/// @param eq_callback
function array_contains_pred(array, value, eq_callback)
{
	var len = array_length(array);
	for (var i = 0; i < len; ++i)
	{
		if (eq_callback(array[i], value))
		{
			return true;
		}
	}
	return false;
}
