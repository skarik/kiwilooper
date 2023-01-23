/// @description Update animation & mesh

//Character_AnimationStep();
// Custom animation step
// TODO instead of hard code, how about make it overridable

// Animation based on map


var animationName = "ref";

// Update subanim index
if (currentMovetype == mvtNormal)
{
	var movespeed_sqr = sqr(xspeed) + sqr(yspeed);
	if (movespeed_sqr > sqr(5))
	{
		animationName = "walk"
		animationSpeed = 14.0;
		animationLooped = true;
		bIsWalking = true;
	}
	else
	{
		animationName = "idle";
		animationSpeed = 6.0;
		animationLooped = true;
	}
}
else if (currentMovetype == attackState)
{
	animationLooped = false;
}
else if (currentMovetype == mvtDeath)
{
	animationLooped = false;
}

// Do animation
var animationIndexPrevious = animationIndex;
animationIndex += animationSpeed * Time.deltaTime;

// Create the rendering index
var subanim = mesh_resource.animation.subanims[?animationName];
if (!is_undefined(subanim))
{
	animationRenderIndex = (animationIndex % (subanim.frame_end - subanim.frame_begin)) + subanim.frame_begin;
}

// TODO: check events

m_updateCharacterMesh();