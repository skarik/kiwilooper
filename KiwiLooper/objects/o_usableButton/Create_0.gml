/// @description Create mesh

event_inherited();

// Set up initial state
image_speed = 0;
image_index = 0;

m_activated = false;
m_activeTime = 0.0;

// Set up persistent state
PersistentState("m_activated", kValueTypeBoolean);
PersistentState("m_activeTime", kValueTypeFloat);

// Set up callback
m_onActivation = function(activatedBy)
{
	// locked - check player inventory for keys
	if (m_usable && (m_activated == false || m_isToggle)) // can we be activated?
	{
		// activate only from player for now
		if (iexists(activatedBy) && Game_IsPlayer_safe(activatedBy))
		{
			if (l_isUnlockedForPlayer())
			{
				l_updateActivationState(!m_activated); // update state & everything that comes with it
			
				// If single use, we stop
				if (m_singleUse)
				{
					enabled = false;
				}
				else
				{
					m_activeTime = m_delayBeforeReset;
				}
		
				// Play sfx
				sound_play_at(x, y, z, "sound/door/button0.wav");
			
				// Now, actually toggle the target
				if (iexists(m_targetLively))
				{
					var l_activateTarget = function()
					{
						livelyTriggerActivate(m_targetLively, id);
					};
					var l_deactivateTarget = function()
					{
						livelyTriggerDeactivate(m_targetLively, id);
					};
				
					// Execute with delay if we have it
					if (m_activeTime > 0.0)
					{
						if (m_activated)
							executeDelay(method(this, l_activateTarget), m_activeTime, this);
						else
							executeDelay(method(this, l_deactivateTarget), m_activeTime, this);
					}
					// Else trigger as is
					else
					{
						if (m_activated)
							l_activateTarget();
						else
							l_deactivateTarget();
					}
				} // End triggering target
			} // End unlock check
			else
			{
				// Play locked noise
			}
		} // End triggered-by check
	} // End can-be-activated check
	else
	{
		// if usable, play the do-not-use sound?
	}
}

l_isUnlockedForPlayer = function()
{
	if (!m_locked)
	{
		return true;
	}
	else
	{
		// check player inventory
		if (iexists(o_playerKiwi))
		{
			return o_playerKiwi.m_inventory.keys[m_unlockChannel];
		}
		return false;
	}
}

/// @desc Updates state & if there's been change, updates mesh
l_updateActivationState = function(newState, force=false)
{
	if (newState != m_activated || force)
	{
		// Save new state
		m_activated = newState;
		
		// Switch image
		image_index = l_isUnlockedForPlayer() ? (m_flipState ? (m_activated ? 0 : 1) : (m_activated ? 1 : 0)) : 2;
		
		// Update the mesh
		m_updateMesh();
	}
}
/// @desc Updates frame-to-frame state
l_onStep = function()
{
	// if been activated, and we want to count down, then do so
	if (m_activated && !m_singleUse && !m_isToggle)
	{
		m_activeTime -= Time.deltaTime;
		if (m_activeTime <= 0.0)
		{
			l_updateActivationState(false);
		}
	}
}

// Create empty mesh
m_mesh = meshb_CreateEmptyMesh();

// Define the sprite update function
m_updateMesh = function()
{
	var width = image_xscale * sprite_width * 0.5;
	var height = image_yscale * sprite_height;
	
	var uvs = sprite_get_uvs(sprite_index, image_index);
	meshb_BeginEdit(m_mesh);
	meshb_AddQuad(m_mesh, [
		new MBVertex(new Vector3(0, -width, height), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3(0,  width, height), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3(0, -width, 0), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
		new MBVertex(new Vector3(0,  width, 0), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0))
		]);
	meshb_End(m_mesh);
}

// Define the rendering function
m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sprite_index, image_index));
}

// Update mesh on load
onPostLevelLoad = function()
{
	// do forced activation update, which should update mesh to the correct sprite
	l_updateActivationState(m_activated, true);
}