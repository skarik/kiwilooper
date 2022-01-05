// Stolen from: https://github.com/kraifpatrik/CE/blob/master/scripts/ce_matrix/ce_matrix.gml

/// @func amatrix_copy(_source, _target)
/// @desc Copies a matrix.
/// @param {matrix} _source The matrix to copy from.
/// @param {matrix} _target The matrix to copy to.
function amatrix_copy(_source, _target)
{
	gml_pragma("forceinline");
	array_copy(_target, 0, _source, 0, 16);
}

/// @func amatrix_clone(_m)
/// @desc Creates a clone of the matrix.
/// @param {real[16]} _m The matrix to create a clone of.
/// @return {real[16]} The created matrix.
function amatrix_clone(_m)
{
	gml_pragma("forceinline");
	var _clone = array_create(16, 0);
	array_copy(_clone, 0, _m, 0, 16);
	return _clone;
}

/// @func amatrix_inverse(_m)
/// @desc Inverts the matrix.
/// @param {real[16]} _m The matrix.
function amatrix_inverse(_m)
{
	gml_pragma("forceinline");

	var _m0 = _m[0];
	var _m1 = _m[1];
	var _m2 = _m[2];
	var _m3 = _m[3];
	var _m4 = _m[4];
	var _m5 = _m[5];
	var _m6 = _m[6];
	var _m7 = _m[7];
	var _m8 = _m[8];
	var _m9 = _m[9];
	var _m10 = _m[10];
	var _m11 = _m[11];
	var _m12 = _m[12];
	var _m13 = _m[13];
	var _m14 = _m[14];
	var _m15 = _m[15];

	var _determinant = (0
		+ (_m3 * _m6 *  _m9 * _m12) - (_m2 * _m7 *  _m9 * _m12) - (_m3 * _m5 * _m10 * _m12) + (_m1 * _m7 * _m10 * _m12)
		+ (_m2 * _m5 * _m11 * _m12) - (_m1 * _m6 * _m11 * _m12) - (_m3 * _m6 *  _m8 * _m13) + (_m2 * _m7 *  _m8 * _m13)
		+ (_m3 * _m4 * _m10 * _m13) - (_m0 * _m7 * _m10 * _m13) - (_m2 * _m4 * _m11 * _m13) + (_m0 * _m6 * _m11 * _m13)
		+ (_m3 * _m5 *  _m8 * _m14) - (_m1 * _m7 *  _m8 * _m14) - (_m3 * _m4 *  _m9 * _m14) + (_m0 * _m7 *  _m9 * _m14)
		+ (_m1 * _m4 * _m11 * _m14) - (_m0 * _m5 * _m11 * _m14) - (_m2 * _m5 *  _m8 * _m15) + (_m1 * _m6 *  _m8 * _m15)
		+ (_m2 * _m4 *  _m9 * _m15) - (_m0 * _m6 *  _m9 * _m15) - (_m1 * _m4 * _m10 * _m15) + (_m0 * _m5 * _m10 * _m15));

	var _s = 1 / _determinant;
	
	_m[@  0] = _s * ((_m6 * _m11 * _m13) - (_m7 * _m10 * _m13) + (_m7 * _m9 * _m14) - (_m5 * _m11 * _m14) - (_m6 * _m9 * _m15) + (_m5 * _m10 * _m15));
	_m[@  1] = _s * ((_m3 * _m10 * _m13) - (_m2 * _m11 * _m13) - (_m3 * _m9 * _m14) + (_m1 * _m11 * _m14) + (_m2 * _m9 * _m15) - (_m1 * _m10 * _m15));
	_m[@  2] = _s * ((_m2 *  _m7 * _m13) - (_m3 *  _m6 * _m13) + (_m3 * _m5 * _m14) - (_m1 *  _m7 * _m14) - (_m2 * _m5 * _m15) + (_m1 *  _m6 * _m15));
	_m[@  3] = _s * ((_m3 *  _m6 *  _m9) - (_m2 *  _m7 *  _m9) - (_m3 * _m5 * _m10) + (_m1 *  _m7 * _m10) + (_m2 * _m5 * _m11) - (_m1 *  _m6 * _m11));
	_m[@  4] = _s * ((_m7 * _m10 * _m12) - (_m6 * _m11 * _m12) - (_m7 * _m8 * _m14) + (_m4 * _m11 * _m14) + (_m6 * _m8 * _m15) - (_m4 * _m10 * _m15));
	_m[@  5] = _s * ((_m2 * _m11 * _m12) - (_m3 * _m10 * _m12) + (_m3 * _m8 * _m14) - (_m0 * _m11 * _m14) - (_m2 * _m8 * _m15) + (_m0 * _m10 * _m15));
	_m[@  6] = _s * ((_m3 *  _m6 * _m12) - (_m2 *  _m7 * _m12) - (_m3 * _m4 * _m14) + (_m0 *  _m7 * _m14) + (_m2 * _m4 * _m15) - (_m0 *  _m6 * _m15));
	_m[@  7] = _s * ((_m2 *  _m7 *  _m8) - (_m3 *  _m6 *  _m8) + (_m3 * _m4 * _m10) - (_m0 *  _m7 * _m10) - (_m2 * _m4 * _m11) + (_m0 *  _m6 * _m11));
	_m[@  8] = _s * ((_m5 * _m11 * _m12) - (_m7 *  _m9 * _m12) + (_m7 * _m8 * _m13) - (_m4 * _m11 * _m13) - (_m5 * _m8 * _m15) + (_m4 *  _m9 * _m15));
	_m[@  9] = _s * ((_m3 *  _m9 * _m12) - (_m1 * _m11 * _m12) - (_m3 * _m8 * _m13) + (_m0 * _m11 * _m13) + (_m1 * _m8 * _m15) - (_m0 *  _m9 * _m15));
	_m[@ 10] = _s * ((_m1 *  _m7 * _m12) - (_m3 *  _m5 * _m12) + (_m3 * _m4 * _m13) - (_m0 *  _m7 * _m13) - (_m1 * _m4 * _m15) + (_m0 *  _m5 * _m15));
	_m[@ 11] = _s * ((_m3 *  _m5 *  _m8) - (_m1 *  _m7 *  _m8) - (_m3 * _m4 *  _m9) + (_m0 *  _m7 *  _m9) + (_m1 * _m4 * _m11) - (_m0 *  _m5 * _m11));
	_m[@ 12] = _s * ((_m6 *  _m9 * _m12) - (_m5 * _m10 * _m12) - (_m6 * _m8 * _m13) + (_m4 * _m10 * _m13) + (_m5 * _m8 * _m14) - (_m4 *  _m9 * _m14));
	_m[@ 13] = _s * ((_m1 * _m10 * _m12) - (_m2 *  _m9 * _m12) + (_m2 * _m8 * _m13) - (_m0 * _m10 * _m13) - (_m1 * _m8 * _m14) + (_m0 *  _m9 * _m14));
	_m[@ 14] = _s * ((_m2 *  _m5 * _m12) - (_m1 *  _m6 * _m12) - (_m2 * _m4 * _m13) + (_m0 *  _m6 * _m13) + (_m1 * _m4 * _m14) - (_m0 *  _m5 * _m14));
	_m[@ 15] = _s * ((_m1 *  _m6 *  _m8) - (_m2 *  _m5 *  _m8) + (_m2 * _m4 *  _m9) - (_m0 *  _m6 *  _m9) - (_m1 * _m4 * _m10) + (_m0 *  _m5 * _m10));
}

function ce_array_swap(_array, _i, _j)
{
	gml_pragma("forceinline");
	var _temp = _array[_i];
	_array[@ _i] = _array[_j];
	_array[@ _j] = _temp;
}

/// @func amatrix_transpose(_m)
/// @desc Transposes the matrix.
/// @param {real[16]} _m The matrix to be transposed.
function amatrix_transpose(_m)
{
	gml_pragma("forceinline");
	ce_array_swap(_m, 1, 4);
	ce_array_swap(_m, 2, 8);
	ce_array_swap(_m, 3, 12);
	ce_array_swap(_m, 6, 9);
	ce_array_swap(_m, 7, 13);
	ce_array_swap(_m, 11, 14);
}

function amatrix_build_projection_perspective_fov(fov_y, aspect, znear, zfar)
{
	var projection = array_create(16, 0);
	var f = 1.0 / tan(degtorad(fov_y) / 2);
	
	projection[0] = f / aspect;
	projection[5] = f;
	//projection[10] = (zfar + znear) / (znear - zfar);
	projection[10] = zfar / (zfar - znear);
	projection[11] = 1.0;
	//projection[14] = (2 * zfar * znear) / (znear - zfar);
	projection[14] = (-znear * zfar) / (zfar - znear);
	
	return projection;
}

function amatrix_empty_w(_m)
{
	_m[3] = 0;
	_m[7] = 0;
	_m[11] = 0;
	_m[12] = 0;
	_m[13] = 0;
	_m[14] = 0;
	_m[15] = 0;
	
}