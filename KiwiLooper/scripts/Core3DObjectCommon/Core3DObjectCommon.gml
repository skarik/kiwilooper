function ACore3DObject_RenderState() constructor
{
	m_cachedTransform = matrix_build_identity();
	m_cachedPosition	= [infinity, infinity, infinity];
	m_cachedRotation	= [infinity, infinity, infinity];
	m_cachedScale		= [infinity, infinity, infinity];
}

function Core3DObject_RenderUpdateTransform()
{
	var rs = m_renderState;
	
	if (   rs.m_cachedPosition[0] != x
		|| rs.m_cachedPosition[1] != y
		|| rs.m_cachedPosition[2] != z
		|| rs.m_cachedRotation[0] != xrotation
		|| rs.m_cachedRotation[1] != yrotation
		|| rs.m_cachedRotation[2] != zrotation
		|| rs.m_cachedScale[0] != xscale
		|| rs.m_cachedScale[1] != yscale
		|| rs.m_cachedScale[2] != zscale)
	{
		rs.m_cachedPosition[0] = x;
		rs.m_cachedPosition[1] = y;
		rs.m_cachedPosition[2] = z;
		rs.m_cachedRotation[0] = xrotation;
		rs.m_cachedRotation[1] = yrotation;
		rs.m_cachedRotation[2] = zrotation;
		rs.m_cachedScale[0] = xscale;
		rs.m_cachedScale[1] = yscale;
		rs.m_cachedScale[2] = zscale;
		
		var mat_object_pos = matrix_build(x, y, z, 0, 0, 0, 1, 1, 1);
		var mat_object_scal = matrix_build(0, 0, 0, 0, 0, 0, xscale, yscale, zscale);
		var mat_object_rotx = matrix_build(0, 0, 0, xrotation, 0, 0, 1, 1, 1);
		var mat_object_roty = matrix_build(0, 0, 0, 0, yrotation, 0, 1, 1, 1);
		var mat_object_rotz = matrix_build(0, 0, 0, 0, 0, zrotation, 1, 1, 1);
		
		var mat_object = mat_object_scal;
		mat_object = matrix_multiply(mat_object, mat_object_rotx);
		mat_object = matrix_multiply(mat_object, mat_object_roty);
		mat_object = matrix_multiply(mat_object, mat_object_rotz);
		mat_object = matrix_multiply(mat_object, mat_object_pos);
		
		rs.m_cachedTransform = mat_object;
	}
}