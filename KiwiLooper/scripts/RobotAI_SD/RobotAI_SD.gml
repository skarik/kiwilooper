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
}

function airoboCreate()
{
	m_ai = new AiRobo(id);
}

function airoboLogicAndControl()
{
	// Update the states now
	var xAxis_next = xAxis.value;
	var yAxis_next = yAxis.value;
	
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
		}
		// Stop and attack when close by
	}
	
	_controlStructUpdate(xAxis, xAxis_next);
	_controlStructUpdate(yAxis, yAxis_next);
}
