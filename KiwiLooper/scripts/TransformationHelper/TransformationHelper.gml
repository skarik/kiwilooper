/// @function matrix_build_transform(transform_struct)
/// @param {Struct} full TRS transform data
function matrix_build_transform(transform_struct)
{
	gml_pragma("forceinline");
	
	var mat_object_pos = matrix_build(transform_struct.x, transform_struct.y, transform_struct.z, 0, 0, 0, 1, 1, 1);
	var mat_object_scal = matrix_build(0, 0, 0, 0, 0, 0, transform_struct.xscale, transform_struct.yscale, transform_struct.zscale);
	var mat_object_rotx = matrix_build(0, 0, 0, transform_struct.xrotation, 0, 0, 1, 1, 1);
	var mat_object_roty = matrix_build(0, 0, 0, 0, transform_struct.yrotation, 0, 1, 1, 1);
	var mat_object_rotz = matrix_build(0, 0, 0, 0, 0, transform_struct.zrotation, 1, 1, 1);
		
	var mat_object = mat_object_scal;
	mat_object = matrix_multiply(mat_object, mat_object_rotx);
	mat_object = matrix_multiply(mat_object, mat_object_roty);
	mat_object = matrix_multiply(mat_object, mat_object_rotz);
	mat_object = matrix_multiply(mat_object, mat_object_pos);
	
	return mat_object;
}

/// @function matrix_build_translation(transform_struct)
/// @param {Struct} full T transform data
function matrix_build_translation(transform_struct)
{
	gml_pragma("forceinline");
	
	var mat_object_pos = matrix_build(transform_struct.x, transform_struct.y, transform_struct.z, 0, 0, 0, 1, 1, 1);
	return mat_object_pos;
}

/// @function matrix_build_rotation(transform_struct)
/// @param {Struct} full R transform data
function matrix_build_rotation(transform_struct)
{
	gml_pragma("forceinline");
	
	var mat_object_rotx = matrix_build(0, 0, 0, transform_struct.xrotation, 0, 0, 1, 1, 1);
	var mat_object_roty = matrix_build(0, 0, 0, 0, transform_struct.yrotation, 0, 1, 1, 1);
	var mat_object_rotz = matrix_build(0, 0, 0, 0, 0, transform_struct.zrotation, 1, 1, 1);
		
	var mat_object = mat_object_rotx;
	mat_object = matrix_multiply(mat_object, mat_object_roty);
	mat_object = matrix_multiply(mat_object, mat_object_rotz);
	
	return mat_object;
}

/// @function matrix_get_rotator(matrix4)
/// @param {Array} 4x4 rotation matrix
function matrix_get_rotator(matrix4)
{
	return [
		matrix4[0], matrix4[1], matrix4[2],
		matrix4[4], matrix4[5], matrix4[6],
		matrix4[8], matrix4[9], matrix4[10]
	];
}

/// @function matrix_get_rotation(matrix3)
/// @param {Array} 3x3 rotation matrix
function matrix_get_rotation(matrix)
{
	// https://www.geometrictools.com/Documentation/EulerAngles.pdf
	var angle = new Vector3(0, 0, 0);
	if (matrix[2] < 1.0)
	{
		if (matrix[2] > -1.0)
		{
			angle.y = radtodeg(arcsin(matrix[2]));
			angle.x = radtodeg(arctan2(-matrix[5], matrix[8]));
			angle.z = radtodeg(arctan2(-matrix[1], matrix[0]));
		}
		else
		{
			angle.y = radtodeg(-pi / 2.0);
			angle.x = radtodeg(-arctan2(matrix[3], matrix[4]));
			angle.z = radtodeg(0.0);
		}
	}
	else
	{
		angle.y = radtodeg(pi / 2.0);
		angle.x = radtodeg(arctan2(matrix[3], matrix[4]));
		angle.z = radtodeg(0.0);
	}
	
	/*
	var tr_x, tr_y, C, D;
	var angle = new Vector3(0, 0, 0);
	
	//D = arcsin(min(max(matrix[6], -1.0), 1.0));
	D = arctan2(-matrix[6], sqrt(sqr(matrix[7]) + sqr(matrix[8])));
	C = cos(D);
	angle.y = radtodeg(D);
	
	// Decompose the matrix
	if (abs(C) > KINDA_SMALL_NUMBER)
	{
		//tr_x =  matrix[8];// / C;
		//tr_y = -matrix[7];// / C;
		angle.x = radtodeg(arctan2(matrix[7], matrix[8]));
		//tr_x =  matrix[0];// / C;
		//tr_y = -matrix[3];// / C;
		angle.z = radtodeg(arctan2(matrix[3], matrix[0]));
	}
	// Gimbal lock, find another axis
	else
	{
		angle.x = 0;
		//tr_x = matrix[4];
		//tr_y = matrix[1];
		//angle.z = radtodeg(arctan2(matrix[4], matrix[1]));
		angle.z = radtodeg(arctan2(matrix[1], -matrix[4]));
	}
	*/
	
	return angle;
}