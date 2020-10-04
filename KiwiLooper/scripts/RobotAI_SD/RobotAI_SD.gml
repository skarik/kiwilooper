#macro kAiRoboState_Idle 0
#macro kAiRoboState_Chasing 1

// state structure for the AI
function AiRobo(n_owner) constructor
{
	owner = n_owner;
	
	target = o_playerKiwi;
	targetVisible = false;
	targetPosition = new Vector2(0, 0);
	
	static updateTargetVisibility = function()
	{
		if (iexists(target) && !collision4_line(owner.x, owner.y, owner.z + 8, target.x, target.y, target.z + 8))
		{
			targetVisible = true;
			targetPosition.x = target.x;
			targetPosition.y = target.y;
		}
		else
		{
			targetVisible = false;
		}
	}
	
	state = kAiRoboState_Idle;
	attackCooldown = 0;
}

function airoboCreate()
{
	m_ai = new AiRobo(id);
	
	attackState = mvtRoboAttack;
}

function airoboLogicAndControl()
{
	// Update the states now
	var xAxis_next = xAxis.value;
	var yAxis_next = yAxis.value;
	var atkButton_next = atkButton.value;
	
	if (m_ai.state == kAiRoboState_Idle)
	{
		xAxis_next = 0.0;
		yAxis_next = 0.0;
		
		// Check if the target is visible
		m_ai.updateTargetVisibility();
		
		if (m_ai.targetVisible)
		{
			m_ai.state = kAiRoboState_Chasing;
		}
	}
	else if (m_ai.state == kAiRoboState_Chasing)
	{
		var kApproachToDistance = 17;
		
		// Check if the target is visible
		m_ai.updateTargetVisibility();
		
		var deltaToTarget = new Vector2(m_ai.targetPosition.x - x, m_ai.targetPosition.y - y);
		var distanceToTargetSqr = deltaToTarget.sqrMagnitude();
		
		// Move to the target
		if (distanceToTargetSqr > sqr(kApproachToDistance))
		{
			var motionDelta = deltaToTarget.normal();
			xAxis_next = motionDelta.x;
			yAxis_next = motionDelta.y;
			
			m_ai.attackCooldown = 0.0;
		}
		// Stop and attack when close 
		else
		{
			if (atkButton_next == 0.0 && m_ai.attackCooldown <= 0.0)
			{
				// Press attack
				atkButton_next = 1.0;
				// Lay off motion axes
				xAxis_next = 0.0;
				yAxis_next = 0.0;
				
				// Have cooldown
				m_ai.attackCooldown = 2.0;
				
			}
			else
			{
				// Release attack
				atkButton_next = 0.0;
				
				// Do cooldown
				m_ai.attackCooldown -= Time.deltaTime;
			}
		}
	}
	
	_controlStructUpdate(xAxis, xAxis_next);
	_controlStructUpdate(yAxis, yAxis_next);
	_controlStructUpdate(atkButton, atkButton_next);
}


function mvtRoboAttack()
{
	if (previousMovetype != mvtRoboAttack)
	{	// Perform initial setup
		attackTimer = 0.0;
	}
	
	// Run timer
	var attackTimerPrevious = attackTimer;
	attackTimer += Time.deltaTime / 0.4;
	
	// Check for damage point
	if (attackTimer > 0.90 && attackTimerPrevious <= 0.90)
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
	animationIndex = floor(-3.0 + 6.0 * saturate(attackTimer));
	animationSpeed = 0.0;
	
	// If animation ends then we're done here
	if (attackTimer >= 1.0)
	{
		return mvtNormal;
	}
	return mvtRoboAttack;
}