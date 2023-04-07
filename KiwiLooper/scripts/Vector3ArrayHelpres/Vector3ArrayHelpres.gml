// Only use these when it is harder to read w/ indicies
#macro AVEC_X [0]
#macro AVEC_Y [1]
#macro AVEC_Z [2]

function avec3_cross(a, b, d)
{
	gml_pragma("forceinline");
	var tx = a AVEC_Y * b AVEC_Z - a AVEC_Z * b AVEC_Y;
	var ty = a AVEC_Z * b AVEC_X - a AVEC_X * b AVEC_Z;
	var tz = a AVEC_X * b AVEC_Y - a AVEC_Y * b AVEC_X;
	d[@0] = tx;
	d[@1] = ty;
	d[@2] = tz;
}

function avec3_sqrMagnitude(a)
{
	gml_pragma("forceinline");
	return (a[0] * a[0]) + (a[1] * a[1]) + (a[2] * a[2]);
}

function avec3_dot(a, b)
{
	gml_pragma("forceinline");
	return
		(a[0] * b[0]) +
		(a[1] * b[1]) +
		(a[2] * b[2]);
}

function avec3_dot3a(vec3, b)
{
	gml_pragma("forceinline");
	return
		(vec3.x * b[0]) +
		(vec3.y * b[1]) +
		(vec3.z * b[2]);
}