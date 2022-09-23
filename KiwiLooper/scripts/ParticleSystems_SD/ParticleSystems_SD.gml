/// @function ALiteParticleSystem() struct
/// @desc A simple, object-based particle system for 10s of particles, made for fools.
function ALiteParticleSystem() constructor
{
	renderer = null;
	onParticleAllocate = EmptyFunction;
	onParticleSpawn = function(particle, index){};
	getParticleSpawnCount = function(frameAge){return 0;};
	
	frame = 0;
	particles = [];
	behaviors = [];
	
	static Particle = new ALiteParticle();
	
	static Step = function(deltaTime)
	{
		gml_pragma("forceinline");
		
		// spawn new particles & reuse old ones
		var particlesToSpawn = getParticleSpawnCount(frame);
		if (particlesToSpawn > 0)
		{
			var particlesSpawned = 0;
			
			// find old particles & reuse em
			var particleCount = array_length(particles);
			for (var particleIndex = 0; particleIndex < particleCount; ++particleIndex)
			{
				if (particles[particleIndex].bIsDead)
				{
					particles[particleIndex].bIsDead = false;
					particles[particleIndex].age = 0.0;
					
					onParticleSpawn(particles[particleIndex], index);
					particlesSpawned++;
					
					if (particlesSpawned >= particlesToSpawn)
					{
						break;
					}
				}
			}
			
			// add new particles
			for (var particleAddCount = particlesSpawned; particleAddCount < particlesToSpawn; ++particleAddCount)
			{
				// allocate & call allocate CB
				var new_particle = new ALiteParticle();
				var behaviorsToAdd = array_create(array_length(behaviors));
				for (var behaviorIndex = 0; behaviorIndex < array_length(behaviors); ++behaviorIndex)
				{
					behaviorsToAdd[behaviorIndex] = new behaviors[behaviorIndex]();
				}
				new_particle.AddBehaviors(behaviorsToAdd);
				
				// add to particles & call spawn on it
				array_push(particles, new_particle);
				var index = array_length(particles) - 1;
				onParticleSpawn(particles[index], index);
			}
		}
		
		// slow update loop:
		{
			var particleCount = array_length(particles);
			for (var particleIndex = 0; particleIndex < particleCount; ++particleIndex)
			{
				particles[particleIndex].Step(deltaTime);
			}
		}
		
		// update death of particles
		/*var bHasNewParticleArray = [];
		var newParticleCount = 0;
		var newParticles = [];
		for (var particleIndex = 0; particleIndex < particleCount; ++particleIndex)
		{
			if (!particles[particleIndex].bWantsDeath)
			{
				newParticles[newParticleCount] = particles[particleIndex];
				newParticleCount++;
			}
			else
			{
				particles.Cleanup();
				delete particles[particleIndex];
				bHasNewParticleArray = true;
			}
		}
		if (bHasNewParticleArray)
		{
			particles = newParticles;
		}*/
		
		frame++;
	}
	
	static BuildMesh = function(liveMesh, spriteIndex, spriteFrame)
	{
		// Get UVs for sprite we will be using for this.
		var uvs = sprite_get_uvs(spriteIndex, spriteFrame);
		
		// Build mesh for each particle
		var particleCount = array_length(particles);
		for (var particleIndex = 0; particleIndex < particleCount; ++particleIndex)
		{
			if (!particles[particleIndex].bIsDead)
			{
				renderer.BuildMesh(liveMesh, particles[particleIndex], uvs);
			}
		}
	}
	
	/// @description ARenderCard() : basic renderer generator
	static ARenderCard = function() constructor
	{
		static BuildMesh = function(liveMesh, particle, uvs)
		{
			gml_pragma("forceinline");
			// We want to push a screen-facing quad.
			//meshb_PushVertex
			
			// Grab camera forward & up to generate card vectors (up & side)
			var forward = new Vector3(1, 0, 0);
			var up = new Vector3(0, 0, 1);
			if (iexists(o_Camera3D))
			{
				forward.copyFromArray(o_Camera3D.m_viewForward);
				up.copyFromArray(o_Camera3D.m_viewUp);
			}
			var side = forward.cross(up);
			
			// get the card sizes
			side.multiplySelf(particle.behavior_size.size * 0.5);
			up  .multiplySelf(particle.behavior_size.size * 0.5);
			
			// Now make a card based on size
			meshb_AddQuad(liveMesh, [
				new MBVertex(particle.behavior_position.position.add(side)		.add(up),		c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), forward),
				new MBVertex(particle.behavior_position.position.subtract(side) .add(up),		c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), forward),
				new MBVertex(particle.behavior_position.position.add(side)		.subtract(up),	c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), forward),
				new MBVertex(particle.behavior_position.position.subtract(side) .subtract(up),	c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), forward),
				]);
			
		}
	}
}

#macro kParticleBehaviorType_Position	0x0001
#macro kParticleBehaviorType_Rotation	0x0002
#macro kParticleBehaviorType_Size		0x0004

function ALiteParticle() constructor
{
	// The one behavior that is always persistent is the "kill after age"
	// We define both age & death age here.
	deathAge = 5.0;
	age = 0.0;
	bIsDead = false;
	
	// List of behaviors that the particle uses.
	behaviors = [];
	// References to some very common ones
	behavior_position = null;
	behavior_size = null;
	
	//========================================//
	
	/// @function AddBehaviors(behaviorList)
	/// @param {Array} behaviors
	static AddBehaviors = function(in_behaviors)
	{
		gml_pragma("forceinline");
		for (var i = 0; i < array_length(in_behaviors); ++i)
		{
			AddBehavior(in_behaviors[i]);
		}
	}
	/// @function AddBehavior(behavior)
	/// @param {Struct} behavior
	static AddBehavior = function(behavior)
	{
		array_push(behaviors, behavior);
		if (behavior.kType & kParticleBehaviorType_Position)
		{
			behavior_position = behavior;
		}
		if (behavior.kType & kParticleBehaviorType_Size)
		{
			behavior_size = behavior;
		}
	}
	
	/// @function Cleanup()
	/// @desc Cleans up all the allocated behaviors.
	static Cleanup = function()
	{
		gml_pragma("forceinline");
		
		var behaviorCount = array_length(behaviors);
		for (var behaviorIndex = 0; behaviorIndex < behaviorCount; ++behaviorIndex)
		{
			behaviors[behaviorIndex].Cleanup();
			delete behaviors[behaviorIndex];
		}
	}

	/// @function Step(deltaTime)
	/// @desc Updates particle behavior for input frame time info
	static Step = function(deltaTime)
	{
		gml_pragma("forceinline");
		
		// Run through all the particle behaviors defined
		var behaviorCount = array_length(behaviors);
		for (var behaviorIndex = 0; behaviorIndex < behaviorCount; ++behaviorIndex)
		{
			behaviors[behaviorIndex].Step(deltaTime);
		}
		
		// Step the age up
		age += deltaTime;
		// Cheack for death
		bIsDead |= (age >= deathAge);
	}
	
	//========================================//
	
	static AMotion = function() constructor
	{
		static kType = kParticleBehaviorType_Position;
		position = new Vector3(0, 0, 0);
		velocity = new Vector3(0, 0, 0);
		acceleration = new Vector3(0, 0, 0);
		
		static Cleanup = function()
		{
			delete position;
			delete velocity;
			delete acceleration;
		}
		
		static Step = function(deltaTime)
		{
			gml_pragma("forceinline");
			velocity.addSelf(acceleration.multiply(deltaTime));
			position.addSelf(velocity.multiply(deltaTime));
		}
	}
	
	static ASize = function() constructor
	{
		static kType = kParticleBehaviorType_Size;
		size = 1.0;
		
		static Cleanup = function() {};
		
		static Step = function(deltaTime)
		{
			gml_pragma("forceinline");
			//size
		}
	}
}