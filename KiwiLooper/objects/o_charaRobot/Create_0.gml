/// @description Set up AI shenanigans

// Inherit the parent event
event_inherited();

airoboCreate();

// Set up callbacks
m_onDeath = function()
{
	// Spawn a robot corpse...
	
	// Remove self
	instance_destroy();
}