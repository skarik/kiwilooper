function ABMSCharacter(character) constructor
{
	m_character = character;
	m_timeUntilNextAction = 0.0;
}

function BMSInit()
{
	battleMachine = new AStateMachine();
	battleMachine
		.addState(ABMSStateWaiting)
		.addState(ABMSStateBattleMenu)
		.addState(ABMSStatePlayerMoving)
		.transitionTo(ABMSStateWaiting);
	
	battleTarget = undefined;
	battlePlayer = undefined;
	
	actionMenuChoice = 0;
	movingTimescale = 0.0;
	
	// clear inputs on all actors
	for (var iActor = 0; iActor < array_length(actors); ++iActor)
	{
		var actor = actors[iActor];
		with (actor.m_character)
		{
			controlUpdate(true);
		}
	}
}

function BMSStep()
{
	controlUpdate(false);
	
	// Run the fucking statemachine
	battleMachine.runContext(id, Time.deltaTime);
	
	// update mesh
	BMSMeshUpdate();
	
	// check for quit
	var bCanQuit = true;
	for (var iActor = 0; iActor < array_length(actors); ++iActor)
	{
		var actor = actors[iActor];
		
		if (iexists(actor.m_character) && (!actor.m_character.isPlayer && !actor.m_character.isDead))
		{
			bCanQuit = false;
		}
	}
	
	var player = o_playerKiwi; // TODO: Check all player objects
	if (player.isDead)
	{
		battleMachine.transitionTo(ABMSStateWaiting);
		Time.scale = 1.0;
		
		bCanQuit = true; // override quit if dead lmao
	}
	
	if (bCanQuit)
	{
		Time.scale = 1.0;
		idelete_delay(this, 0.0);
	}
}

function ABMSStateWaiting() : AState() constructor
{
	static onRun = function(param)
	{
		// Tick down all the actor times
		var nextActionableActor = BMSStepTickAndGetNext(Time.deltaTime);
	
		// If in wait-mode, we need to step thru all the behaviors we're doing
		if (is_undefined(nextActionableActor))
		{
			BMSStepBehaviors(Time.deltaTime);
		}
		// We need to do an action, so we have to stop things now
		else if (!is_undefined(nextActionableActor))
		{
			battleTarget = nextActionableActor;
			if (battleTarget.m_character.isPlayer)
			{
				battlePlayer = battleTarget;
				return battleMachine.transitionTo(ABMSStateBattleMenu); // Pause step, grab inputs from player
			}
			else
			{
				// START AI ACTION AND RESET ITS TIMER
				//battleTarget.m_timeUntilNextAction = 1.0; // TODO
			}
		}
	}
	
	static onBegin = function() {}
	static onEnd = function() {}
}

function BMSStepTickAndGetNext(deltaTime)
{
	var nextActionableActor = undefined;
	for (var iActor = 0; iActor < array_length(actors); ++iActor)
	{
		var actor = actors[iActor];
		
		actor.m_timeUntilNextAction -= deltaTime;
		
		// If we have an actor that has ready time, then we mark them as going next
		if (is_undefined(nextActionableActor)
			&& actor.m_timeUntilNextAction <= 0)
		{
			nextActionableActor = actor;
		}
	}
	
	return nextActionableActor;
}

function BMSStepBehaviors(deltaTime)
{
	// step all the actions of all the characters
	for (var iActor = 0; iActor < array_length(actors); ++iActor)
	{
		var actor = actors[iActor];
		
		if (!iexists(actor.m_character)) continue;
		
		// TODO LMAO
		
		// reset states at end of the timer
		if (actor.m_character.object_index == o_playerKiwi)
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

function ABMSStateBattleMenu() : AState() constructor
{
	static onBegin = function()
	{
		Time.scale = 0.0;
		actionMenuChoice = 0;
	}
	
	static onRun = function(param)
	{
		Time.scale = 0.0; // let's just stop everything for a hot minute
	
		// menu input
	
		// check yaxis to go thru the menu
	
		if (abs(yAxis.value) > 0.707 && (sign(yAxis.value) != sign(yAxis.previous) || abs(yAxis.previous) < 0.707))
		{
			actionMenuChoice += sign(yAxis.value);
			actionMenuChoice = clamp(actionMenuChoice, 0, 3);
		
			// Play glitch sound
			sound_play("sound/door/button1.wav");
		}
	
		if (atkButton.pressed || useButton.pressed)
		{
			sound_play("sound/door/glitch1.wav");
		
			if (actionMenuChoice == 0)
			{
				return battleMachine.transitionTo(ABMSStatePlayerMoving);
			}
			else if (actionMenuChoice == 1)
			{
				battleTarget.m_timeUntilNextAction = 1.0; // TODO
			
				//battleTarget.m_character.isDefending = true;
				var player = instance_find(o_playerKiwi, 0);
				player.isDefending = true;
				
				return battleMachine.transitionTo(ABMSStateWaiting);
			}
			else if (actionMenuChoice == 2)
			{
				battleTarget.m_timeUntilNextAction = 1.0; // TODO
				
				// we need to do an attack action? or bring up further menu? for now we just do an attack action
				var player = instance_find(o_playerKiwi, 0);
				_controlStructUpdate(player.atkButton, 1.0);
				
				return battleMachine.transitionTo(ABMSStateWaiting);
			}
			else if (actionMenuChoice == 3)
			{
				battleTarget.m_timeUntilNextAction = 1.0; // TODO
				
				return battleMachine.transitionTo(ABMSStateWaiting);
			}
		
			// if 0, then it's move&wait concurrently
			// if 1, then it's action+wait
			// if 2, then it's action+wait
			// if 3, then it's wait
		}
	}
	
	static onEnd = function()
	{
		Time.scale = 1.0;
	}
}

function ABMSStatePlayerMoving() : AState() constructor
{
	static onBegin = function()
	{
		Time.scale = 0.0;
		movingTimescale = 0.0;
	}
	static onEnd = function()
	{
		// Stop the moving
		_controlStructUpdate(battlePlayer.m_character.xAxis, 0.0);
		_controlStructUpdate(battlePlayer.m_character.yAxis, 0.0);
		
		Time.scale = 1.0;
	}
	
	static onRun = function(param)
	{
		var kRampUpTime = 0.5;
		var kRampDownTime = 0.25;
		// when character moves, ramp up time to full time
	
		if (abs(xAxis.value) > 0.5 || abs(yAxis.value) > 0.5)
		{
			movingTimescale += Time.unscaledDeltaTime / kRampUpTime;
		}
		else
		{
			movingTimescale -= Time.unscaledDeltaTime / kRampDownTime;
		}
		movingTimescale = saturate(movingTimescale);
	
		// copy the inputs to the player
		//var player = instance_find(o_playerKiwi, 0);
		controlForward(battlePlayer.m_character.xAxis, xAxis);
		controlForward(battlePlayer.m_character.yAxis, yAxis);
	
		// but if there's a character that's got some actions, then we want to possibly still do shit
	
	
		// Set timescale
		Time.scale = movingTimescale;
		// Update everynyan now
		//BMSStepWaiting();
		var next_actor = BMSStepTickAndGetNext(Time.deltaTime);
		if (!is_undefined(next_actor))
		{
			// Ask AI to just keep going
		}
		BMSStepBehaviors(Time.deltaTime);
	
		var bInterruptMoving = false;
	
	
		// Check for interrupts
		if (atkButton.pressed || useButton.pressed)
		{
			bInterruptMoving = true;
		}
		// TODO: if the player gets hurt, we probably want to stop this action too (but let it go immediately????)
		if (player.lastDamaged)
		{
			bInterruptMoving = true;
		}
	
		// If interrupt, go back to menu
		if (bInterruptMoving)
		{
			// go back to prev state
			return battleMachine.transitionTo(ABMSStateBattleMenu);
		}
	}
}
