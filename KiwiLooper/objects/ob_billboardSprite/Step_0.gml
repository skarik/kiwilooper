/// @description Update mesh for frame animation

animationIndex += animationSpeed * Time.deltaTime;

m_updateMesh();

// If kill on end, need to check for end of animation
if (killOnEnd)
{
	if (animationIndex >= image_number)
	{
		instance_destroy();
	}
}