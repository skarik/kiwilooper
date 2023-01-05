
function BMSStepBehaviors(deltaTime)
{
	// step all the actions of all the characters
	for (var iActor = 0; iActor < array_length(actors); ++iActor)
	{
		var actor = actors[iActor];
		
		if (!iexists(actor.m_character))
		{
			actor.m_timeUntilNextAction = 10000;
			continue;
		}
		
		// TODO LMAO
		
		// reset states at end of the timer
		if (Game_IsPlayer_safe(actor.m_character))
		{
			if (actor.m_timeUntilNextAction <= 0.0)
			{
				actor.m_character.isDefending = false;
				_controlStructUpdate(actor.m_character.atkButton, 0.0);
			}
		}
		
		// basically start with copy paste from AI but with more delays
		if (actor.m_character.object_index == o_charaRobot)
		{
			var chara = actor.m_character;
			var ai = chara.m_ai;
			
			var xAxis_next = chara.xAxis.value;
			var yAxis_next = chara.yAxis.value;
			var atkButton_next = chara.atkButton.value;
	
			// wait
			if (ai.state == 0)
			{
				xAxis_next = 0.0;
				yAxis_next = 0.0;
				
				if (actor.m_timeUntilNextAction <= 0.0)
				{
					actor.m_timeUntilNextAction = 3.0;
					ai.state = 1;
				}
			}
			// move to
			else if (ai.state == 1)
			{
				var kApproachToDistance = 17;
				
				ai.updateTargetVisibility();
				
				var deltaToTarget = new Vector2(ai.targetPosition.x - chara.x, ai.targetPosition.y - chara.y);
				var distanceToTargetSqr = deltaToTarget.sqrMagnitude();

				// todo: pathfinding
				var motionDelta = deltaToTarget.normal();
				xAxis_next = motionDelta.x;
				yAxis_next = motionDelta.y;
				
				// got close enough
				if (distanceToTargetSqr < sqr(kApproachToDistance))
				{
					ai.state = 2; //attack
					actor.m_timeUntilNextAction = 1.0;
				}
				// timed out
				else if (actor.m_timeUntilNextAction <= 0.0)
				{
					ai.state = 0; //wait
					actor.m_timeUntilNextAction = 2.0;
				}
			}
			// attack
			else if (ai.state == 2)
			{
				if (atkButton_next == 0.0)
				{
					// Press attack
					atkButton_next = 1.0;
					// Lay off motion axes
					xAxis_next = 0.0;
					yAxis_next = 0.0;
				}
				else
				{
					// Release attack
					atkButton_next = 0.0;
					
					ai.state = 0; //wait
					actor.m_timeUntilNextAction = 4.0;
				}
			}
			
			_controlStructUpdate(chara.xAxis, xAxis_next);
			_controlStructUpdate(chara.yAxis, yAxis_next);
			_controlStructUpdate(chara.atkButton, atkButton_next);
		}
	}
}
