function Character_Create()
{
	// Motion constants
	kMoveSpeed = 50;
	
	// Animation state
	image_speed = 0;
	animationSpeed = 0;
	animationIndex = 0;

	// Control state
	hasControl = false;
	isPlayer = false;
	
	// Motion state
	xspeed = 0.0;
	yspeed = 0.0;
	zspeed = 0.0;
	facingDirection = 0;
	currentMovetype = mvtNormal;
}

function Character_Step()
{
	currentMovetype = currentMovetype();
}

function Character_AnimationStep()
{
	if (iexists(o_Camera3D))
	{
		animationIndex = round(angle_difference(facingDirection, o_Camera3D.zrotation) / 90 + 1);
	}
}