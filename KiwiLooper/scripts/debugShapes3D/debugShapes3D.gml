function debugRay3(rayOrigin, rayDir, color)
{
	var dbb = inew(ob_debugShape3D);
		dbb.x1 = rayOrigin.x; dbb.y1 = rayOrigin.y; dbb.z1 = rayOrigin.z;
		dbb.x2 = rayOrigin.x + rayDir.x; dbb.y2 = rayOrigin.y + rayDir.y; dbb.z2 = rayOrigin.z + rayDir.z;
		dbb.image_blend = color;
		
	dbb.m_mesh = meshb_Begin();
	MeshbAddLine(dbb.m_mesh, c_white, 1.0, rayDir.magnitude(), rayDir.normal(), rayOrigin);
	meshb_End(dbb.m_mesh);
	
	return dbb;
}