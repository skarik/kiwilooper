/// @func CE_MatrixCreate(_m00, _m01, _m02, _m03, _m10, _m11, _m12, _m13, _m20, _m21, _m22, _m23, _m30, _m31, _m32, _m33)
/// @desc Creates a matrix with given components.
/// @param {real} _m00.._m03 The first row of the matrix.
/// @param {real} _m10.._m13 The second row of the matrix.
/// @param {real} _m20.._m23 The third row of the matrix.
/// @param {real} _m30.._m33 The fourth row of the matrix.
/// @return {real[16]} The created matrix.
function CE_MatrixCreate(
	_m00, _m01, _m02, _m03,
	_m10, _m11, _m12, _m13,
	_m20, _m21, _m22, _m23,
	_m30, _m31, _m32, _m33)
{
	gml_pragma("forceinline");
	return [
		_m00, _m01, _m02, _m03,
		_m10, _m11, _m12, _m13,
		_m20, _m21, _m22, _m23,
		_m30, _m31, _m32, _m33
	];
}

/// @func CE_MatrixAddComponentwise(_m1, _m2)
/// @desc Adds matrices `_m1`, `_m2` componentwise and stores the result to `_m1`.
/// @param {real[16]} _m1 The first matrix.
/// @param {real[16]} _m2 The second matrix.
function CE_MatrixAddComponentwise(_m1, _m2)
{
	gml_pragma("forceinline");
	_m1[@ 0] += _m2[@ 0];
	_m1[@ 1] += _m2[@ 1];
	_m1[@ 2] += _m2[@ 2];
	_m1[@ 3] += _m2[@ 3];
	_m1[@ 4] += _m2[@ 4];
	_m1[@ 5] += _m2[@ 5];
	_m1[@ 6] += _m2[@ 6];
	_m1[@ 7] += _m2[@ 7];
	_m1[@ 8] += _m2[@ 8];
	_m1[@ 9] += _m2[@ 9];
	_m1[@ 10] += _m2[@ 10];
	_m1[@ 11] += _m2[@ 11];
	_m1[@ 12] += _m2[@ 12];
	_m1[@ 13] += _m2[@ 13];
	_m1[@ 14] += _m2[@ 14];
	_m1[@ 15] += _m2[@ 15];
}

/// @func CE_MatrixBuildLookAt(_from, _to, _up)
/// @desc Builds a look-at matrix from given vec3.
/// @param {real[3]} _from Camera's position vector.
/// @param {real[3]} _to Camera's target position.
/// @param {real[3]} _up Camera's up vector.
/// @return {real[16]} The created matrix.
function CE_MatrixBuildLookAt(_from, _to, _up)
{
	gml_pragma("forceinline");
	return matrix_build_lookat(
		_from[0], _from[1], _from[2],
		_to[0], _to[1], _to[2],
		_up[0], _up[1], _up[2]);
}

/// @func CE_MatrixCopy(_source, _target)
/// @desc Copies a matrix.
/// @param {real[16]} _source The matrix to copy from.
/// @param {real[16]} _target The matrix to copy to.
function CE_MatrixCopy(_source, _target)
{
	gml_pragma("forceinline");
	array_copy(_target, 0, _source, 0, 16);
}


/// @func CE_MatrixClone(_m)
/// @desc Creates a clone of the matrix.
/// @param {real[16]} _m The matrix to create a clone of.
/// @return {real[16]} The created matrix.
function CE_MatrixClone(_m)
{
	gml_pragma("forceinline");
	var _clone = array_create(16, 0);
	array_copy(_clone, 0, _m, 0, 16);
	return _clone;
}

/// @func CE_MatrixCloneFromColumns(_c0, _c1, _c2, _c3)
/// @desc Creates a matrix with specified columns.
/// @param {real[4]} _c0 The first column of the matrix.
/// @param {real[4]} _c1 The second column of the matrix.
/// @param {real[4]} _c2 The third column of the matrix.
/// @param {real[4]} _c3 The fourth column of the matrix.
/// @return {real[16]} The created matrix.
function CE_MatrixCloneFromColumns(_c0, _c1, _c2, _c3)
{
	gml_pragma("forceinline");
	return [
		_c0[0], _c0[1], _c0[2], _c0[3],
		_c1[0], _c1[1], _c1[2], _c1[3],
		_c2[0], _c2[1], _c2[2], _c2[3],
		_c3[0], _c3[1], _c3[2], _c3[3]
	];
}

/// @func CE_MatrixCloneFromRows(_r0, _r1, _r2, _r3)
/// @desc Creates a matrix with specified rows.
/// @param {real[4]} _r0 The first row of the matrix.
/// @param {real[4]} _r1 The second row of the matrix.
/// @param {real[4]} _r2 The third row of the matrix.
/// @param {real[4]} _r3 The fourth row of the matrix.
/// @return {real[16]} The created matrix.
function CE_MatrixCloneFromRows(_r0, _r1, _r2, _r3)
{
	gml_pragma("forceinline");
	return [
		_r0[0], _r1[0], _r2[0], _r3[0],
		_r0[1], _r1[1], _r2[1], _r3[1],
		_r0[2], _r1[2], _r2[2], _r3[2],
		_r0[3], _r1[3], _r2[3], _r3[3]
	];
}

/// @func CE_MatrixDeterminant(_m)
/// @desc Gets the determinant of the matrix.
/// @param {real[16]} _m The matrix.
/// @return {real} The determinant of the matrix.
function CE_MatrixDeterminant(_m)
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
	return (0
		+ (_m3 * _m6 *  _m9 * _m12) - (_m2 * _m7 *  _m9 * _m12) - (_m3 * _m5 * _m10 * _m12) + (_m1 * _m7 * _m10 * _m12)
		+ (_m2 * _m5 * _m11 * _m12) - (_m1 * _m6 * _m11 * _m12) - (_m3 * _m6 *  _m8 * _m13) + (_m2 * _m7 *  _m8 * _m13)
		+ (_m3 * _m4 * _m10 * _m13) - (_m0 * _m7 * _m10 * _m13) - (_m2 * _m4 * _m11 * _m13) + (_m0 * _m6 * _m11 * _m13)
		+ (_m3 * _m5 *  _m8 * _m14) - (_m1 * _m7 *  _m8 * _m14) - (_m3 * _m4 *  _m9 * _m14) + (_m0 * _m7 *  _m9 * _m14)
		+ (_m1 * _m4 * _m11 * _m14) - (_m0 * _m5 * _m11 * _m14) - (_m2 * _m5 *  _m8 * _m15) + (_m1 * _m6 *  _m8 * _m15)
		+ (_m2 * _m4 *  _m9 * _m15) - (_m0 * _m6 *  _m9 * _m15) - (_m1 * _m4 * _m10 * _m15) + (_m0 * _m5 * _m10 * _m15));
}

/// @func CE_MatrixInverse(_m)
/// @desc Inverts the matrix.
/// @param {real[16]} _m The matrix.
function CE_MatrixInverse(_m)
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

/// @func CE_MatrixMultiply(_matrix, ...)
/// @desc Multiplies any number of given matrices.
/// @param {real[16]} _matrix The first matrix.
/// @return {real[16]} The resulting matrix.
/// @example
/// Both following lines of code would produce the same result.
/// ```gml
/// CE_MatrixMultiply(A, B, C);
/// matrix_multiply(matrix_multiply(A, B), C);
/// ```
function CE_MatrixMultiply(_matrix)
{
	gml_pragma("forceinline");
	var i = 1;
	repeat (argument_count - 1)
	{
		_matrix = matrix_multiply(_matrix, argument[i++]);
	}
	return _matrix;
}

/// @func CE_MatrixMultiplyComponentwise(_m1, _m2)
/// @desc Multiplies matrices `_m1`, `_m2` componentwise and stores the result to
/// `_m1`.
/// @param {real[16]} _m1 The first matrix.
/// @param {real[16]} _m2 The second matrix.
function CE_MatrixMultiplyComponentwise(_m1, _m2)
{
	gml_pragma("forceinline");
	_m1[@ 0] *= _m2[@ 0];
	_m1[@ 1] *= _m2[@ 1];
	_m1[@ 2] *= _m2[@ 2];
	_m1[@ 3] *= _m2[@ 3];
	_m1[@ 4] *= _m2[@ 4];
	_m1[@ 5] *= _m2[@ 5];
	_m1[@ 6] *= _m2[@ 6];
	_m1[@ 7] *= _m2[@ 7];
	_m1[@ 8] *= _m2[@ 8];
	_m1[@ 9] *= _m2[@ 9];
	_m1[@ 10] *= _m2[@ 10];
	_m1[@ 11] *= _m2[@ 11];
	_m1[@ 12] *= _m2[@ 12];
	_m1[@ 13] *= _m2[@ 13];
	_m1[@ 14] *= _m2[@ 14];
	_m1[@ 15] *= _m2[@ 15];
}

/// @func CE_MatrixScaleComponentwise(_m, _s)
/// @desc Scales each component of a matrix by a value.
/// @param {real[16]} _m The matrix to scale.
/// @param {real} _s The value to scale the matrix by.
function CE_MatrixScaleComponentwise(_m, _s)
{
	gml_pragma("forceinline");
	_m[@ 0] *= _s;
	_m[@ 1] *= _s;
	_m[@ 2] *= _s;
	_m[@ 3] *= _s;
	_m[@ 4] *= _s;
	_m[@ 5] *= _s;
	_m[@ 6] *= _s;
	_m[@ 7] *= _s;
	_m[@ 8] *= _s;
	_m[@ 9] *= _s;
	_m[@ 10] *= _s;
	_m[@ 11] *= _s;
	_m[@ 12] *= _s;
	_m[@ 13] *= _s;
	_m[@ 14] *= _s;
	_m[@ 15] *= _s;
}

/// @func CE_MatrixSubtractComponentwise(_m1, _m2)
/// @desc Subtracts matrices `_m1`, `_m2` componentwise and stores the result to
/// `_m1`.
/// @param {real[16]} _m1 The first matrix.
/// @param {real[16]} _m2 The second matrix.
function CE_MatrixSubtractComponentwise(_m1, _m2)
{
	gml_pragma("forceinline");
	_m1[@ 0] -= _m2[@ 0];
	_m1[@ 1] -= _m2[@ 1];
	_m1[@ 2] -= _m2[@ 2];
	_m1[@ 3] -= _m2[@ 3];
	_m1[@ 4] -= _m2[@ 4];
	_m1[@ 5] -= _m2[@ 5];
	_m1[@ 6] -= _m2[@ 6];
	_m1[@ 7] -= _m2[@ 7];
	_m1[@ 8] -= _m2[@ 8];
	_m1[@ 9] -= _m2[@ 9];
	_m1[@ 10] -= _m2[@ 10];
	_m1[@ 11] -= _m2[@ 11];
	_m1[@ 12] -= _m2[@ 12];
	_m1[@ 13] -= _m2[@ 13];
	_m1[@ 14] -= _m2[@ 14];
	_m1[@ 15] -= _m2[@ 15];
}

/// @func CE_MatrixToEuler(_m)
/// @desc Gets euler angles from the YXZ rotation matrix.
/// @param {real[16]} _m The YXZ rotation matrix.
/// @return {real[16]} An array containing the euler angles `[rot_x, rot_y, rot_z]`.
/// @source https://www.geometrictools.com/Documentation/EulerAngles.pdf
function CE_MatrixToEuler(_m)
{
	gml_pragma("forceinline");
	var _thetaX, _thetaY, _thetaZ;
	var _m6 = _m[6];

	if (_m6 < 1)
	{
		if (_m6 > -1)
		{
			_thetaX = arcsin(-_m6);
			_thetaY = arctan2(_m[2], _m[10]);
			_thetaZ = arctan2(_m[4], _m[5]);
		}
		else
		{
			_thetaX = pi * 0.5;
			_thetaY = -arctan2(-_m[1], _m[0]);
			_thetaZ = 0;
		}
	}
	else
	{
		_thetaX = -pi * 0.5;
		_thetaY = arctan2(-_m[1], _m[0]);
		_thetaZ = 0;
	}

	return [
		(360 + radtodeg(_thetaX)) mod 360,
		(360 + radtodeg(_thetaY)) mod 360,
		(360 + radtodeg(_thetaZ)) mod 360
	];
}

/// @func CE_MatrixTranspose(_m)
/// @desc Transposes the matrix.
/// @param {real[16]} _m The matrix to be transposed.
function CE_MatrixTranspose(_m)
{
	gml_pragma("forceinline");
	CE_ArraySwap(_m, 1, 4);
	CE_ArraySwap(_m, 2, 8);
	CE_ArraySwap(_m, 3, 12);
	CE_ArraySwap(_m, 6, 9);
	CE_ArraySwap(_m, 7, 13);
	CE_ArraySwap(_m, 11, 14);
	return _m;
}

/// @func CE_MatrixTranslate(_matrix, _x[, _y, _z])
/// @desc Translates a matrix.
/// @param {real[16]} _matrix The matrix to translate.
/// @param {real/real[]} _x The translation on an X axis or an array with
/// `[x, y, z]` translation.
/// @param {real} [_y] The translation on the Y axis. Not used when `_x` is an
/// array.
/// @param {real} [_z] The translation on the Z axis. Not used when `_x` is an
/// array.
/// @return {real[16]} The resulting matrix.
/// @example
/// Both following lines of code would produce the same result.
/// ```gml
/// CE_MatrixTranslate(M, 1, 2, 3);
/// CE_MatrixTranslate(M, [1, 2, 3]);
/// ```
function CE_MatrixTranslate(_matrix, _x)
{
	gml_pragma("forceinline");
	var _y = (argument_count == 4) ? argument[2] : _x[1];
	var _z = (argument_count == 4) ? argument[3] : _x[2];
	_x = (argument_count == 4) ? _x : _x[0];
	return matrix_multiply(_matrix,
		matrix_build(_x, _y, _z, 0, 0, 0, 1, 1, 1));
}

/// @func CE_MatrixTranslateX(_matrix, _translate)
/// @desc Translates a matrix on the X axis.
/// @param {real[16]} _matrix The matrix to translate.
/// @param {real} _translate A value to translate the matrix by.
/// @return {real[16]} The resulting matrix.
function CE_MatrixTranslateX(_matrix, _translate)
{
	gml_pragma("forceinline");
	return matrix_multiply(_matrix,
		matrix_build(_translate, 0, 0, 0, 0, 0, 1, 1, 1));
}

/// @func CE_MatrixTranslateY(_matrix, _translate)
/// @desc Translates a matrix on the Y axis.
/// @param {real[16]} _matrix The matrix to translate.
/// @param {real} _translate A value to translate the matrix by.
/// @return {real[16]} The resulting matrix.
function CE_MatrixTranslateY(_matrix, _translate)
{
	gml_pragma("forceinline");
	return matrix_multiply(_matrix,
		matrix_build(0, _translate, 0, 0, 0, 0, 1, 1, 1));
}

/// @func CE_MatrixTranslateZ(_matrix, _translate)
/// @desc Translates a matrix on the Z axis.
/// @param {real[16]} _matrix The matrix to translate.
/// @param {real} _translate A value to translate the matrix by.
/// @return {real[16]} The resulting matrix.
function CE_MatrixTranslateZ(_matrix, _translate)
{
	gml_pragma("forceinline");
	return matrix_multiply(_matrix,
		matrix_build(0, 0, _translate, 0, 0, 0, 1, 1, 1));
}

/// @func CE_MatrixRotate(_matrix, _x[, _y, _z])
/// @desc Rotates a matrix.
/// @param {real[16]} _matrix The matrix to rotate.
/// @param {real/real[]} _x Either rotation on the X axis, array with
/// `[x, y, z]` rotation or an array with `[x, y, z, w]` quaternion.
/// @param {real} [_y] The rotation on the Y axis. Not used when `_x` is an
/// array.
/// @param {real} [_z] The rotation on the Z axis. Not used when `_x` is an
/// array.
/// @return {real[16]} The resulting matrix.
/// @example
/// Each of following lines of code would produce the same result.
/// ```gml
/// CE_MatrixRotate(M, 90, 0, 0);
/// CE_MatrixRotate(M, [90, 0, 0]);
/// CE_MatrixRotate(M, ce_quaternion_create_from_axisangle([1, 0, 0], 90));
/// ```
/// @note The order of rotations is the same as in `matrix_build`.
/// @see ce_quaternion_create_from_axisangle
function CE_MatrixRotate(_matrix, _x)
{
	gml_pragma("forceinline");
	if (is_array(_x))
	{
		if (array_length(_x) == 4)
		{
			// Quaternion
			return matrix_multiply(_matrix, ce_quaternion_to_matrix(_x));
		}
		// Array of angles
		return matrix_multiply(_matrix,
			matrix_build(0, 0, 0, _x[0], _x[1], _x[2], 1, 1, 1));
	}
	// Passed individually as arguments
	return matrix_multiply(_matrix,
		matrix_build(0, 0, 0, _x, argument[2], argument[3], 1, 1, 1));
}

/// @func CE_MatrixRotateX(_matrix, _angle)
/// @desc Rotates a matrix on the X axis.
/// @param {real[16]} _matrix The matrix to rotate.
/// @param {real} _angle An angle in degrees.
/// @return {real[16]} The resulting matrix.
function CE_MatrixRotateX(_matrix, _angle)
{
	gml_pragma("forceinline");
	return matrix_multiply(_matrix,
		matrix_build(0, 0, 0, _angle, 0, 0, 1, 1, 1));
}

/// @func CE_MatrixRotateY(_matrix, _angle)
/// @desc Rotates a matrix on the Y axis.
/// @param {real[16]} _matrix The matrix to rotate.
/// @param {real} _angle An angle in degrees.
/// @return {real[16]} The resulting matrix.
function CE_MatrixRotateY(_matrix, _angle)
{
	gml_pragma("forceinline");
	return matrix_multiply(_matrix,
		matrix_build(0, 0, 0, 0, _angle, 0, 1, 1, 1));
}

/// @func CE_MatrixRotateZ(_matrix, _angle)
/// @desc Rotates a matrix on the Z axis.
/// @param {real[16]} _matrix The matrix to rotate.
/// @param {real} _angle An angle in degrees.
/// @return {real[16]} The resulting matrix.
function CE_MatrixRotateZ(_matrix, _angle)
{
	gml_pragma("forceinline");
	return matrix_multiply(_matrix,
		matrix_build(0, 0, 0, 0, 0, _angle, 1, 1, 1));
}

/// @func CE_MatrixScale(_matrix, _x[, _y, _z])
/// @desc Scales a matrix.
/// @param {real[16]} _matrix The matrix to scale.
/// @param {real/real[]} _x The scale on an X axis or an array with
/// `[x, y, z]` scale.
/// @param {real} [_y] The scale on the Y axis. Not used when `_x` is an
/// array.
/// @param {real} [_z] The scale on the Z axis. Not used when `_x` is an
/// array.
/// @return {real[16]} The resulting matrix.
/// @example
/// Both following lines of code would produce the same result.
/// ```gml
/// CE_MatrixScale(M, 1, 2, 3);
/// CE_MatrixScale(M, [1, 2, 3]);
/// ```
function CE_MatrixScale(_matrix, _x)
{
	gml_pragma("forceinline");
	var _y = (argument_count == 4) ? argument[2] : _x[1];
	var _z = (argument_count == 4) ? argument[3] : _x[2];
	_x = (argument_count == 4) ? _x : _x[0];
	return matrix_multiply(_matrix,
		matrix_build(0, 0, 0, 0, 0, 0, _x, _y, _z));
}

/// @func CE_MatrixScaleX(_matrix, _scale)
/// @desc Scales a matrix on the X axis.
/// @param {real[16]} _matrix The matrix to scale.
/// @param {real} _scale A value to scale the matrix by.
/// @return {real[16]} The resulting matrix.
function CE_MatrixScaleX(_matrix, _scale)
{
	gml_pragma("forceinline");
	return matrix_multiply(_matrix,
		matrix_build(0, 0, 0, 0, 0, 0, _scale, 1, 1));
}

/// @func CE_MatrixScaleY(_matrix, _scale)
/// @desc Scales a matrix on the Y axis.
/// @param {real[16]} _matrix The matrix to scale.
/// @param {real} _scale A value to scale the matrix by.
/// @return {real[16]} The resulting matrix.
function CE_MatrixScaleY(_matrix, _scale)
{
	gml_pragma("forceinline");
	return matrix_multiply(_matrix,
		matrix_build(0, 0, 0, 0, 0, 0, 1, _scale, 1));
}

/// @func CE_MatrixScaleZ(_matrix, _scale)
/// @desc Scales a matrix on the Z axis.
/// @param {real[16]} _matrix The matrix to scale.
/// @param {real} _scale A value to scale the matrix by.
/// @return {real[16]} The resulting matrix.
function CE_MatrixScaleZ(_matrix, _scale)
{
	gml_pragma("forceinline");
	return matrix_multiply(_matrix,
		matrix_build(0, 0, 0, 0, 0, 0, 1, 1, _scale));
}

/// @func CE_MatrixToAABB(_matrix, _aabbOut)
/// @desc Converts matrix into an axis-aligned bounding box.
/// @param {real[16]} _matrix The matrix.
/// @param {real[6]} _aabbOut An output array in form of
/// `[x_min, y_min, z_min, x_max, y_max, z_max]`.
/// @example
/// ```gml
/// var _matrix = matrix_build(x, y, z, rotX, rotY, rotZ, scaleX, scaleY, scaleZ);
/// var _aabb = array_create(6);
/// CE_MatrixToAABB(_matrix, _aabb);
/// var _width = _aabb[3] - _aabb[0];
/// var _height = _aabb[4] - _aabb[1];
/// var _depth = _aabb[5] - _aabb[2];
/// ```
function CE_MatrixToAABB(_matrix, _aabbOut)
{
	var _m0, _m1, _m2, _m3;
	var _temp;
	var _b0, _b1, _b2, _b3;
	var _t0, _t1, _t2, _t3;
	var _min, _max;

	////////////////////////////////////////////////////////////////////////////
	// X
	_m0 = _matrix[0];
	_m1 = _matrix[4];
	_m2 = _matrix[8];
	_m3 = _matrix[12];

	_temp = -_m0 - _m1;
	_b0 = _temp - _m2 + _m3;
	_t0 = _temp + _m2 + _m3;

	_temp = _m0 - _m1;
	_b1 = _temp - _m2 + _m3;
	_t1 = _temp + _m2 + _m3;

	_temp = _m0 + _m1;
	_b2 = _temp - _m2 + _m3;
	_t2 = _temp + _m2 + _m3;

	_temp = -_m0 + _m1;
	_b3 = _temp - _m2 + _m3;
	_t3 = _temp + _m2 + _m3;

	_min = min(_b0, _b1, _b2, _b3, _t0, _t1, _t2, _t3);
	_max = max(_b0, _b1, _b2, _b3, _t0, _t1, _t2, _t3);
	_aabbOut[@ 0] = _min;
	_aabbOut[@ 3] = _max;

	////////////////////////////////////////////////////////////////////////////
	// Y
	_m0 = _matrix[1];
	_m1 = _matrix[5];
	_m2 = _matrix[9];
	_m3 = _matrix[13];

	_temp = -_m0 - _m1;
	_b0 = _temp - _m2 + _m3;
	_t0 = _temp + _m2 + _m3;

	_temp = _m0 - _m1;
	_b1 = _temp - _m2 + _m3;
	_t1 = _temp + _m2 + _m3;

	_temp = _m0 + _m1;
	_b2 = _temp - _m2 + _m3;
	_t2 = _temp + _m2 + _m3;

	_temp = -_m0 + _m1;
	_b3 = _temp - _m2 + _m3;
	_t3 = _temp + _m2 + _m3;

	_min = min(_b0, _b1, _b2, _b3, _t0, _t1, _t2, _t3);
	_max = max(_b0, _b1, _b2, _b3, _t0, _t1, _t2, _t3);
	_aabbOut[@ 1] = _min;
	_aabbOut[@ 4] = _max;

	////////////////////////////////////////////////////////////////////////////
	// Z
	_m0 = _matrix[2];
	_m1 = _matrix[6];
	_m2 = _matrix[10];
	_m3 = _matrix[14];

	_temp = -_m0 - _m1;
	_b0 = _temp - _m2 + _m3;
	_t0 = _temp + _m2 + _m3;

	_temp = _m0 - _m1;
	_b1 = _temp - _m2 + _m3;
	_t1 = _temp + _m2 + _m3;

	_temp = _m0 + _m1;
	_b2 = _temp - _m2 + _m3;
	_t2 = _temp + _m2 + _m3;

	_temp = -_m0 + _m1;
	_b3 = _temp - _m2 + _m3;
	_t3 = _temp + _m2 + _m3;

	_min = min(_b0, _b1, _b2, _b3, _t0, _t1, _t2, _t3);
	_max = max(_b0, _b1, _b2, _b3, _t0, _t1, _t2, _t3);
	_aabbOut[@ 2] = _min;
	_aabbOut[@ 5] = _max;
}