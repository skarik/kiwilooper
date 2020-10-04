function mvtNormal()
{
	var inputAxis = new Vector2(xAxis.value, yAxis.value);
	// If the player, we need to rotate the motion to match the view
	if (isPlayer && iexists(o_Camera3D))
	{
		inputAxis.rotateSelf(o_Camera3D.zrotation - 90);
	}
	
	// Update speed
	xspeed = inputAxis.x * kMoveSpeed;
	yspeed = inputAxis.y * kMoveSpeed;
	
	// Limit max speed
	var total_speed_sqr = sqr(xspeed) + sqr(yspeed);
	if (total_speed_sqr > sqr(kMoveSpeed))
	{
		var total_speed = sqrt(total_speed_sqr);
		xspeed *= kMoveSpeed / total_speed;
		yspeed *= kMoveSpeed / total_speed;
	}

	// Update facing direction
	if (total_speed_sqr > 1)
	{
		facingDirection = point_direction(0, 0, xspeed, yspeed);
	}

	// Do common z motion
	mvtcZMotion();

	// Do common x-y collision
	mvtcCollision();
	
	// Do the actual motion
	x += xspeed * Time.deltaTime;
	y += yspeed * Time.deltaTime;
	
	return mvtNormal;
}

function mvtAttack()
{
	if (previousMovetype != mvtAttack)
	{	// Perform initial setup
		attackTimer = 0.0;
	}
	
	// Run timer
	var attackTimerPrevious = attackTimer;
	attackTimer += Time.deltaTime / 0.2;
	
	// Check for damage point
	if (attackTimer > 0.25 && attackTimerPrevious <= 0.25)
	{
		// Do the hitbox on the enemies
		var hitboxCenterX = x + lengthdir_x(9, facingDirection);
		var hitboxCenterY = y + lengthdir_y(9, facingDirection);
		//effectOnGroundHit(hitboxCenterX, hitboxCenterY);
		damageHitbox(id,
					 hitboxCenterX - 14, hitboxCenterY - 14,
					 hitboxCenterX + 14, hitboxCenterY + 14,
					 1,
					 kDamageTypeBlunt);
	}
	
	// Animation sprite is updated elsewhere
	animationIndex = floor(4.0 * saturate(attackTimer));
	animationSpeed = 0.0;
	
	// If animation ends then we're done here
	if (attackTimer >= 1.0)
	{
		return mvtNormal;
	}
	return mvtAttack;
}

function mvtDeath()
{
	if (previousMovetype != mvtDeath)
	{	// Perform initial setup
		deathTimer = 0.0;
	}
	
	// Run timer
	deathTimer += Time.deltaTime / (isPlayer ? 1.0 : 0.5);
	
	// When at the end of the timer, run the death callback
	if (deathTimer > 1.0)
	{
		m_onDeath();
	}
	
	return mvtDeath;
}