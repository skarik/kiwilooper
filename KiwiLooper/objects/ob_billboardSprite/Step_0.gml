/// @description Update mesh for frame animation

// Animate:
animationIndex += animationSpeed * Time.deltaTime;

// Update mesh:
m_updateOrientation();
m_updateMesh();

// If kill on end, need to check for end of animation
if (killOnEnd)
{
	if (animationIndex >= image_number)
	{
		instance_destroy();
	}
}