function ABMSCharacter(character) constructor
{
	m_character = character;
	m_timeUntilNextAction = 0.0;
}

#macro kBattleStepWaiting 0
#macro kBattleStepBattleMenu 1
#macro kBattleStepMoving 2

function BMSInit()
{
	battleStep = kBattleStepWaiting;
	battleTarget = undefined;
	
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
	var player = o_playerKiwi;
	if (player.isDead)
	{
		battleStep = kBattleStepWaiting;
		Time.scale = 1.0;
	}
	
	if (battleStep == kBattleStepWaiting)
	{
		BMSStepWaiting();
	}
	else if (battleStep == kBattleStepBattleMenu)
	{
		// TODO
		BMSStepGrabInput();
	}
	else if (battleStep == kBattleStepMoving)
	{
		BMSStepMoving();
	}
	
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
	if (bCanQuit)
	{
		Time.scale = 1.0;
		idelete_delay(this, 0.0);
	}
}

function BMSStepWaiting()
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
			battleStep = kBattleStepBattleMenu; // Pause step, grab inputs from player
			// TODO: on-change w/ states?
			actionMenuChoice = 0;
		}
		else
		{
			// START AI ACTION AND RESET ITS TIMER
			//battleTarget.m_timeUntilNextAction = 1.0; // TODO
		}
	}
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

function BMSStepGrabInput()
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
	
	if (atkButton.pressed)
	{
		sound_play("sound/door/glitch1.wav");
		
		if (actionMenuChoice == 0)
		{
			movingTimescale = 0.0;
			battleStep = kBattleStepMoving;
			Time.scale = 1.0;
		}
		else if (actionMenuChoice == 1)
		{
			battleTarget.m_timeUntilNextAction = 1.0; // TODO
			battleStep = kBattleStepWaiting;
			Time.scale = 1.0;
			
			//battleTarget.m_character.isDefending = true;
			var player = instance_find(o_playerKiwi, 0);
			player.isDefending = true;
		}
		else if (actionMenuChoice == 2)
		{
			battleTarget.m_timeUntilNextAction = 1.0; // TODO
			battleStep = kBattleStepWaiting;
			Time.scale = 1.0;
			
			// we need to do an attack action? or bring up further menu? for now we just do an attack action
			var player = instance_find(o_playerKiwi, 0);
			_controlStructUpdate(player.atkButton, 1.0);
		}
		else if (actionMenuChoice == 3)
		{
			battleTarget.m_timeUntilNextAction = 1.0; // TODO
			battleStep = kBattleStepWaiting;
			Time.scale = 1.0;
		}
		
		// if 0, then it's move&wait concurrently
		// if 1, then it's action+wait
		// if 2, then it's action+wait
		// if 3, then it's wait
	}
}

function BMSStepMoving()
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
	var player = instance_find(o_playerKiwi, 0);
	controlForward(player.xAxis, xAxis);
	controlForward(player.yAxis, yAxis);
	
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
	if (useButton.pressed || atkButton.pressed)
	{
		bInterruptMoving = true;
	}
	// TODO: if the player gets hurt, we probably want to stop this action too
	
	
	// If interrupt, go back to menu
	if (bInterruptMoving)
	{
		player.xAxis.value = 0.0;
		player.yAxis.value = 0.0;
		
		// go back to prev state
		battleStep = kBattleStepBattleMenu;
		actionMenuChoice = 0;
	}
}


function BMSMeshAddGrid(mesh)
{
	// Find player and build floor grid around them
	
	var player = instance_find(o_playerKiwi, 0);
	var tex_uvs = sprite_get_uvs(sfx_square, 0);
	
	
	var playerPosition = new Vector3(round(player.x / 16) * 16, round(player.y / 16) * 16, player.z + 1);
	
	var gridXNormal = new Vector3(1, 0, 0);
	var gridYNormal = new Vector3(0, 1, 0);
	var kGridDist = 128;
	var kGridSpace = 16;
		
	for (var i = 0; i <= 4; ++i)
	{
		MeshbAddLine3(mesh, c_white, 0.25,
			0.5, kGridDist, gridXNormal, playerPosition.subtract(gridXNormal.multiply(kGridDist * 0.5)).add(gridYNormal.multiply(kGridSpace * i)), tex_uvs);
		MeshbAddLine3(mesh, c_white, 0.25,
			0.5, kGridDist, gridXNormal, playerPosition.subtract(gridXNormal.multiply(kGridDist * 0.5)).add(gridYNormal.multiply(kGridSpace * -i)), tex_uvs);
		
		MeshbAddLine3(mesh, c_white, 0.25,
			0.5, kGridDist, gridYNormal, playerPosition.subtract(gridYNormal.multiply(kGridDist * 0.5)).add(gridXNormal.multiply(kGridSpace * i)), tex_uvs);
		MeshbAddLine3(mesh, c_white, 0.25,
			0.5, kGridDist, gridYNormal, playerPosition.subtract(gridYNormal.multiply(kGridDist * 0.5)).add(gridXNormal.multiply(kGridSpace * -i)), tex_uvs);
	}
}


function BMSMenuMeshAddTimers(mesh, surface)
{
	var tex_w = surface_get_width(surface);
	var tex_h = surface_get_height(surface);
	
	// add all the timer UIs
	surface_set_target(surface);
	
	draw_set_color(c_yellow);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_font(f_Oxygen7);
	
	for (var iActor = 0; iActor < array_length(actors); ++iActor)
	{
		var actor = actors[iActor];
		if (!iexists(actor.m_character)) continue;
		
		draw_text(0, iActor * 16, string(max(0.00, actor.m_timeUntilNextAction)));
	}
	surface_reset_target();
	
	// add all the timer meshes
	
	var frontface_direction = Vector3FromArray(o_Camera3D.m_viewForward);
	var cross_x = frontface_direction.cross(new Vector3(0, 0, 1));
	var cross_y = frontface_direction.cross(cross_x);
	cross_x.normalize().multiplySelf(-32 * 0.6);
	cross_y.normalize().multiplySelf(16 * 0.6);
	
	for (var iActor = 0; iActor < array_length(actors); ++iActor)
	{
		var actor = actors[iActor];
		if (!iexists(actor.m_character)) continue;
		
		MeshbAddQuadUVs(
			mesh, c_white, 1.0,
			cross_x,
			cross_y,
			[
				0,
				(iActor * 16) / tex_h,
				31 / tex_w,
				(iActor * 16 + 16) / tex_h
			],
			Vector3FromTranslation(actor.m_character).add(new Vector3(0, 0, 32)).subtract(cross_x.multiply(0.5)).subtract(cross_y.multiply(0.5))
		);
			
	}
}

function BMSMenuMeshAddMoveMenu(mesh, surface)
{
	var player = instance_find(o_playerKiwi, 0);
	
	if (battleStep != kBattleStepBattleMenu) return; // TODO
	if (is_undefined(battleTarget) || !iexists(battleTarget.m_character)) return; // TODO
	// todo player
	
	var tex_w = surface_get_width(surface);
	var tex_h = surface_get_height(surface);
	
	// build the menu ui
	surface_set_target(surface);
	
	var dx = 32;
	var dy = 0;
	draw_set_color(c_navy);
	draw_set_alpha(0.5);
	draw_rectangle(dx, dy, dx + 80, dy + 80, false);
	draw_set_color(c_blue);
	draw_set_alpha(1.0);
	draw_rectangle(dx + 1, dy + 1, dx + 80 - 2, dy + 80 - 2, true);
	
	// draw menu options
	draw_set_color(c_aqua);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_font(f_Oxygen10);
	draw_text(dx + 10, dy + 2 +  0, "[MOVE]");
	draw_text(dx + 10, dy + 2 + 20, "[BRACE]");
	draw_text(dx + 10, dy + 2 + 40, "[HURT]");
	draw_text(dx + 10, dy + 2 + 60, "[WAIT]");
	
	draw_set_color(c_white);
	draw_text(dx + 0, dy + 2 + 20 * actionMenuChoice, ">>");
	
	surface_reset_target();
	
	// draw menu mesh
	var frontface_direction = Vector3FromArray(o_Camera3D.m_viewForward);
	var cross_x = frontface_direction.cross(new Vector3(0, 0, 1));
	var cross_y = frontface_direction.cross(cross_x);
	cross_x.normalize().multiplySelf(-80 * 0.6);
	cross_y.normalize().multiplySelf(80 * 0.6);
	
	MeshbAddQuadUVs(
		mesh, c_white, 1.0,
		cross_x,
		cross_y,
		[
			(dx) / tex_w,
			(dy) / tex_h,
			(dx + 80) / tex_w,
			(dy + 80) / tex_h
		],
		Vector3FromTranslation(player).add(new Vector3(0, 0, 32)).subtract(cross_x.multiply(0.5)).subtract(cross_y.multiply(0.5)).add(cross_x.multiply(1.0))
	);
}