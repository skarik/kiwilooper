function aquat_multiply(qa, qb)
{
	return [
		qa[3]*qb[0] + qa[0]*qb[3] - qa[1]*qb[2] + qa[2]*qb[1],
		qa[3]*qb[1] + qa[0]*qb[2] + qa[1]*qb[3] - qa[2]*qb[0],
		qa[3]*qb[2] - qa[0]*qb[1] + qa[1]*qb[0] + qa[2]*qb[3],
		qa[3]*qb[3] - qa[0]*qb[0] - qa[1]*qb[1] - qa[2]*qb[2]
		];
}

function aquat_invert(qa)
{
	return [-qa[0], -qa[1], -qa[2], qa[3]];
}

function aquat_multiply_avec3(q, v)
{
	var qr = q;
	var qri = aquat_invert(qr);
	var qv = [v[0], v[1], v[2], 0];
	var qf = aquat_multiply(aquat_multiply(qri, qv), qr);
	return [qf[0], qf[1], qf[2]];
}

function aquat_build_rotation(v)
{
	var rotx = degtorad(v[0]);
	var roty = degtorad(v[1]);
	var rotz = degtorad(v[2]);
	
	var qx = [sin(rotx / 2.0), 0.0, 0.0, cos(rotx / 2.0)];
	var qy = [0.0, sin(roty / 2.0), 0.0, cos(roty / 2.0)];
	var qz = [0.0, 0.0, sin(rotz / 2.0), cos(rotz / 2.0)];
	
	var q1 = aquat_multiply(qz, qy);
	return   aquat_multiply(q1, qx);
}