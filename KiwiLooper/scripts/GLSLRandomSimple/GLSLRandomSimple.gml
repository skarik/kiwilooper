
// The classic StackOverflow GLSL randomizer

function grand_simpleRandom(scale3, seed)
{
	// use the fragment position for a different seed per-pixel
	return frac(sin(new Vector3(x + seed, y + seed, z + seed).dot(scale)) * 43758.5453 + seed);
}

/// @function grand_simpleRand(co_x, co_y)
/// @param co_x {Real}
/// @param co_y {Real}
function grand_simpleRand(co_x, co_y)
{
	static kRandomSeed = new Vector2(12.9898, 78.233);
	return frac(sin(co_x * kRandomSeed.x + co_y * kRandomSeed.y) * 43758.5453);
}

/// @function grand_simpleRand2(co)
/// @param co {Vector2}
function grand_simpleRand2(co)
{
	static kRandomSeed = new Vector2(12.9898, 78.233);
	return frac(sin(co.dot(kRandomSeed)) * 43758.5453);
}

