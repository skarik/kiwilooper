/// @description Update animation & mesh

//Character_AnimationStep();
// Custom animation step
// TODO instead of hard code, how about make it overridable

// Animation based on map

var Event_Footstep = function(position)
{
	var mat = Material_BelowPosition(position.x, position.y, position.z + 10);
	if (World_WaterBelowPosition(position.x, position.y, position.z + 10)) // hack!
		mat = kMaterialType_WaterPuddle;
			
	if (mat == kMaterialType_Metal) // TODO: try to unify this with general impacts, if needed.
	{
		var sound = sound_play_at(position.x, position.y, z, choose("sound/phys/step_metal1.wav", "sound/phys/step_metal2.wav", "sound/phys/step_metal3.wav"));
			sound.gain = 0.05 * random_range(0.9, 1.1);
			sound.pitch = 1.2 * random_range(0.9, 1.1);
			sound.parent = id;
	}
	else
	{
		// todo
	}
			
	// TODO: clean up bloody shoes depending on the material:
	if (mat == kMaterialType_WaterWaist || mat == kMaterialType_WaterPuddle)
	{
		footstepBloody = 0;
	}
			
	if (footstepBloody > 0)
	{
		var left = (check >= 1 && checkPrev < 1);
		var blood = inew(o_playerFootstepSplatter);
			blood.x = position.x + lengthdir_x(left ? 1.6 : -1.6, facingDirection - 90);
			blood.y = position.y + lengthdir_y(left ? 1.6 : -1.6, facingDirection - 90);
			blood.z = z;
			blood.image_xscale = 1.0;
			blood.image_yscale = choose(-1, 1);
			blood.image_angle = facingDirection;
			blood.image_index = floor(random(blood.image_number));
					
		// One less bloody footstep stored up
		footstepBloody--;
	}
}


var animationNamePrevious = animationName;
animationName = "ref";

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
var animationRenderIndexPrevious = animationRenderIndex;
var subanim = mesh_resource.animation.subanims[?animationName];
var subanim_frame_begin = 0;
var subanim_frame_end = 0;
if (!is_undefined(subanim))
{
	subanim_frame_begin = subanim.frame_begin;
	subanim_frame_end = subanim.frame_end;
	animationRenderIndex = (animationIndex % (subanim.frame_end - subanim.frame_begin)) + subanim.frame_begin;
}

// Check events
if (animationNamePrevious == animationName)
{
	var event_startFrame = floor(animationRenderIndexPrevious);
	var event_endFrame = floor(animationRenderIndex);
	var event_stepCount = (event_endFrame >= event_startFrame)
		? (event_endFrame - event_startFrame)
		: ((subanim_frame_end - event_startFrame) + (event_endFrame - subanim_frame_begin));
	
	var frame = event_startFrame;
	for (var frameCount = 0; frameCount < event_stepCount; ++frameCount)
	{
		// Get frame count that will loop over this 
		//var frame = (((event_startFrame + frameCount) - subanim_frame_begin) % (subanim_frame_end - subanim_frame_begin)) + subanim_frame_begin;
		
		// We'll iterate naiively 
		frame += 1;
		if (frame >= subanim_frame_end)
			frame = subanim_frame_begin;
		
		var event = mesh_resource.animation.events[?int64(frame)];
		if (!is_undefined(event))
		{
			// We have an event!
			debugLog(kLogOutput, "have event " + event.name);
			
			// Begin event running
			if (event.name == "footstep_left" || event.name == "footstep_right")
			{
				// Get the position of the event
				offsetMatrix = matrix_build_transform(self);
				var footstepPosition = Vector3FromArray(event.position);
				footstepPosition.transformAMatrixSelf(offsetMatrix);
				
				Event_Footstep(footstepPosition);
			}
			// End event running
		}
	}
}

// Updat emesh
m_updateCharacterMesh();