function Character_Create()
{
	// Motion constants
	kMoveSpeed = 50;
	
	// Attack constants
	attackState = mvtAttack;
	
	// Animation constants
	kAnimStand = sprite_index;
	kAnimAttack = sprite_index;
	kAnimWalk = sprite_index;
	kAnimInteract = sprite_index;
	kAnimDeath = sprite_index;
	
	// Empty callbacks
	m_onBeginDeath = function(){}
	m_onDeath = function(){}
	
	// Other state
	hp = 1;
	hp_previous = 1;
	hp_max = 1;
	isDead = false;
	lastDamageType = kDamageTypeUnarmed;
	
	// Animation state
	image_speed = 0;
	animationSpeed = 0;
	animationIndex = 0;
	animationRenderIndex = 0;
	animationLooped = false;

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
	interactionLock = noone;
	
	// Motion state
	xspeed = 0.0;
	yspeed = 0.0;
	zspeed = 0.0;
	facingDirection = 0;
	currentMovetype = mvtNormal;
	previousMovetype = mvtNormal;
	onGround = true;
	motionHitWall = false;
	
	// Attack state
	attackTimer = 0.0;
	
	// Death state
	deathTimer = 0.0;
}

function Character_BeginStep()
{
	// Drop HP when underground
	if (z < -8 && !isDead)
	{
		hp -= 1;
		lastDamageType = kDamageTypeMagicVoid;
	}
	
	// Has HP dropped? If so, let's do some EFFECTS.
	if (hp < hp_previous)
	{
		// TODO: Do blood effects
		
		// Are we dying here?
		if (hp <= 0)
		{
			if (!isDead)
			{
				// TODO: Create initial death effect
				m_onBeginDeath();
				
				// Interrupt everything, and go to death
				currentMovetype = mvtDeath;
				isDead = true;
			}
		}
	}
	// Update previous values
	hp_previous = hp;
}

function Character_Step()
{
	var lastMovetype = currentMovetype;
	currentMovetype = currentMovetype();
	previousMovetype = lastMovetype;
	
	// Update interaction lock
	if (iexists(interactionLock))
	{
		isInteracting = true;
		if (useButton.pressed)
		{
			interactionLock.m_onActivation(id);
			if (!iexists(interactionLock))
			{
				isInteracting = false;
			}
		}
	}
	// Update interaction
	else if (currentMovetype == mvtNormal
		&& canInteract && !isInteracting)
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
				// Enable interaction lock & isInteracting disable
				if (iexists(interactionLock))
				{
					isInteracting = true;
				}
			}
		}
	}
	
	// Update attacking
	if (currentMovetype == mvtNormal
		&& !isInteracting)
	{
		if (atkButton.pressed)
		{	// Simple and clean!
			currentMovetype = attackState;
		}
	}
	
	// Update on-ground shock death
	if (onGround)
	{
		if (iexists(o_livelyRoomState) && o_livelyRoomState.powered)
		{
			if (((z + 64) % 16 > 8) // Quick hack to let us start falling first
				&& collision4_get_groundtype(x, y, z) == kGroundType_Tileset
				&& collision4_get_tileextra(x, y) == kTileExtras_Shock)
			{
				if (!isDead)
				{
					damageTarget(null, id, 1, kDamageTypeShock, x, y);
				}
			}
		}
	}
}

function Character_AnimationStep()
{
	var animationOffset = 0;
	if (iexists(o_Camera3D))
	{
		animationOffset = round(angle_difference(facingDirection, o_Camera3D.zrotation) / 90 + 5);
	}
	
	var bIsWalking = false;
	
	// Update sprite index
	if (currentMovetype == mvtNormal)
	{
		var movespeed_sqr = sqr(xspeed) + sqr(yspeed);
		if (movespeed_sqr > sqr(5))
		{
			sprite_index = kAnimWalk;
			animationSpeed = 7.0;
			animationLooped = true;
			bIsWalking = true;
		}
		else
		{
			sprite_index = kAnimStand;
			animationSpeed = 2.0;
			animationLooped = true;
		}
	}
	else if (currentMovetype == attackState)
	{
		sprite_index = kAnimAttack;
		animationLooped = false;
	}
	else if (currentMovetype == mvtDeath)
	{
		sprite_index = kAnimDeath;
		animationLooped = false;
	}
	
	// Do animation
	var animationIndexPrevious = animationIndex;
	animationIndex += animationSpeed * Time.deltaTime;
	
	// Update final index to actually display
	if ((image_number % 4) == 0)
	{
		var subanimation_length = floor(image_number / 4);
		if (animationLooped)
		{
			animationRenderIndex = floor(animationIndex % subanimation_length) + (subanimation_length * animationOffset);
		}
		else
		{
			animationRenderIndex = clamp(animationIndex, 0, subanimation_length * 0.99) + (subanimation_length * animationOffset);
		}
	}
	else
	{
		animationRenderIndex = animationIndex;
	}
	
	// Do footstep effects
	if (bIsWalking)
	{
		var checkPrev = animationIndexPrevious % 4;
		var check = animationIndex % 4;
		if ((check >= 1 && checkPrev < 1)
			|| (check >= 3 && checkPrev < 3))
		{
			var sound = sound_play_at(x, y, z, choose("sound/phys/step_metal1.wav", "sound/phys/step_metal2.wav", "sound/phys/step_metal3.wav"));
				sound.gain = 0.05 * random_range(0.9, 1.1);
				sound.pitch = 1.2 * random_range(0.9, 1.1);
				sound.parent = id;
		}
	}
}