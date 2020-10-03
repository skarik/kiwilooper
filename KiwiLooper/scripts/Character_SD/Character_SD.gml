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
	
	// Interaction constants
	kInteractionRadius = 7;
	kInteractionCenterDist = kInteractionRadius - 1;
	
	// Interaction state
	canInteract = true;
	isInteracting = false;
	interactionTarget = noone;
	
	// Motion state
	xspeed = 0.0;
	yspeed = 0.0;
	zspeed = 0.0;
	facingDirection = 0;
	currentMovetype = mvtNormal;
	
	motionHitWall = false;
}

function Character_Step()
{
	currentMovetype = currentMovetype();
	
	// Update interaction
	if (canInteract && !isInteracting)
	{
		// Do interaction check
		var interaction_list = ds_list_create();
		var interaction_list_count = collision_circle_list(
			x + lengthdir_x(kInteractionCenterDist, facingDirection),
			y + lengthdir_y(kInteractionCenterDist, facingDirection),
			kInteractionRadius,
			ob_usable,
			true, true,
			interaction_list,
			false);
			
		if (interaction_list_count > 0)
		{
			var interaction_priorities = ds_priority_create();
			// Find best/closest interaction target
			for (var i = 0; i < interaction_list_count; ++i)
			{
				var interactible = interaction_list[|i];
				ds_priority_add(interaction_priorities, interactible, sqr(x - interactible.x) + sqr(y - interactible.y) + sqr(kInteractionRadius * interactible.m_priority));
			}
			ds_list_destroy(interaction_list);
		
			// Update interaction target
			interactionTarget = ds_priority_find_min(interaction_priorities);
			ds_priority_destroy(interaction_priorities);
		}
		else
		{
			interactionTarget = noone;
		}
		
		// Now interact
		if (useButton.pressed)
		{
			if (iexists(interactionTarget))
			{
				interactionTarget.m_onActivation(id);
			}
		}
	}
}

function Character_AnimationStep()
{
	if (iexists(o_Camera3D))
	{
		animationIndex = round(angle_difference(facingDirection, o_Camera3D.zrotation) / 90 + 5);
	}
}