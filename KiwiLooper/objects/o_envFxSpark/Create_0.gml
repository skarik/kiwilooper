/// @description Set up particle system basics

event_inherited();


m_system = new ALiteParticleSystem();
m_system.behaviors = [
	m_system.Particle.AMotion,
	m_system.Particle.ASize,
]; // thank you @meseta#6458
m_system.onParticleSpawn = function(particle, index)
{
	// Set initial spawn position
	particle.behaviors[0].position.x = x;
	particle.behaviors[0].position.y = y;
	particle.behaviors[0].position.z = z;
	
	// Set size
	particle.behaviors[1].size = 7.0;
	
	// Set age
	particle.maxlife = random_range(1.0, 2.0);
	
	// Set gravity
	particle.behaviors[0].acceleration.z = -350.0;
	
	// Set velocity and whatnot
	particle.behaviors[0].velocity.x = random_range(-30.0, +30.0);
	particle.behaviors[0].velocity.y = random_range(-30.0, +30.0);
	particle.behaviors[0].velocity.z = (random_range(-30.0, +30.0) + 20.0) * 4.0;
}
m_system.getParticleSpawnCount = function(frameAge)
{
	if (frameAge == 0)
	{
		return 20;
	}
	return 0;
}
m_system.renderer = new m_system.ARenderCard();

// Create empty mesh
m_mesh = meshb_CreateEmptyMesh();
m_updateMesh = function()
{
	// If have no sprite, don't make a mesh.
	if (!sprite_exists(sprite_index))
	{
		return;
	}
	meshb_BeginEdit(m_mesh);
	m_system.BuildMesh(m_mesh, sprite_index, 0);
	meshb_End(m_mesh);
}
m_renderEvent = function()
{
	matrix_set(matrix_world, matrix_build_identity());
	var p_blendmode = gpu_get_blendmode_ext_sepalpha();
	gpu_set_blendmode(bm_add);
		vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sprite_index, 0));
	gpu_set_blendmode_ext_sepalpha(p_blendmode[0], p_blendmode[1], p_blendmode[2], p_blendmode[3]);
};