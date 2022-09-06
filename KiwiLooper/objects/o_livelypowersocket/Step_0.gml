/// @description Update for explosion & actual logic


//triggerOnPlug

// Check if a body is nearby
var bTargetExists = iexists(m_targetLively);
var bWantTrigger = false;
{
	var connecting_plug = collision_rectangle(x - 3, y - 3, x + 3, y + 3, o_usableCorpsePlug, false, true);
	if (iexists(connecting_plug))
	{
		conducting = true;
		
		// Update door trigger
		bWantTrigger = true;
		if (bTargetExists && !livelyIsTriggered(m_targetLively))
		{
			livelyTriggerActivate(m_targetLively, id);
		}
		
		// Track conductor to see if we should be electrifying them.
		UpdateConductor(connecting_plug);
	}
	// no conductor? track effects
	else
	{
		conducting = false;
		
		// Clear conduction tracking
		ClearConductor();
	}
	
	// If door shouldnt be open, we must close it
	if (!bWantTrigger)
	{
		if (bTargetExists && !livelyIsDeactivated(m_targetLively))
		{
			livelyTriggerDeactivate(m_targetLively, id); // Should possibly work on this again.
		}
	}
}

if (!bTargetExists)
{
	// Create error text for debugging for now 
	// for LD40 - we almost always want the exploding wires to have a target.
	// for other puzzles, we might not want this, so this is also wrapped within a debug mode variable
	if (Debug.lively_show_explode_wire_target)
	{
		if (!variable_instance_exists(this, "_debug_text"))
		{
			_debug_text = Debug_CreateWorldRenderText(x, y, z, "no target", c_red);
		}
	}
}
