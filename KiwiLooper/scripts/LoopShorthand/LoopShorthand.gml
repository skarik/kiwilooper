/// @function Repeat(n, fn)
/// @param n {Integer}
/// @param fn {Function(n)} Function called each iteration
function Repeat(n, fn)
{
	gml_pragma("forceinline");
	for (var i = 0; i < n; ++i)
		fn(i);
}

