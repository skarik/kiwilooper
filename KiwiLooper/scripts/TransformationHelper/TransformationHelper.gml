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