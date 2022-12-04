
function float_sign(n)
{
	gml_pragma("forceinline");
	return (n & 0x8000000000000000) ? -1.0 : 1.0; // Doesn't work in GML.
}

function nonzero_sign(n)
{
	gml_pragma("forceinline");
	return (n < 0) ? -1 : 1;
}