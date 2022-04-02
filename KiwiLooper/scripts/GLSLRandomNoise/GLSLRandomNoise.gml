function grand_mod289(x)
{
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

function grand_permute(x)
{
	return mod289(((x*34.0)+10.0)*x);
}

function grand_taylorInvSqrt(r)
{
	return 1.79284291400159 - 0.85373472095314 * r;
}
