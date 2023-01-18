function PersistentStateGameInit()
{
	global._persistent_map_info = ds_map_create();
}
function PersistentStateGameFree()
{
	ds_map_destroy(global._persistent_map_info);
}
function PersistentStateGameLoad()
{
	//TODO
}
function PersistentStateGameSave()
{
	//TODO
}

function PersistentStateRoomStart(map_id)
{
	if (is_undefined(map_id) || (is_string(map_id) && map_id == "") || map_id == null)
	{
		return;
	}
	
	// Initialize the entity listing
	
	debugLog(kLogVerbose, "Persistence target set to \"" + string(map_id) + "\"");
	
	global._persistent_ent_listing = [];
	global._persistent_map_state = global._persistent_map_info[? map_id];
	
	debugLog(kLogVerbose, " map state is \"" + string(global._persistent_map_state) + "\"");
}
function PersistentStateRoomEnd(map_id)
{
	if (is_undefined(map_id) || (is_string(map_id) && map_id == "") || map_id == null)
	{
		return;
	}
	
	// If there is no ent listing, don't bother tracking.
	if (!variable_global_exists("_persistent_ent_listing"))
	{
		return;
	}
	
	var map_state = {
		entity_listing: [],
	};
	
	debugLog(kLogVerbose, "Persistence target saving \"" + string(map_id) + "\"");
	debugLog(kLogVerbose, " map ent list has " + string(array_length(global._persistent_ent_listing)) + " values");
	
	// Check room listing & save it in the map state
	for (var i = 0; i < array_length(global._persistent_ent_listing); ++i)
	{
		var ent_entry = global._persistent_ent_listing[i];
		
		if (iexists(ent_entry.instance))
		{
			// Update variables in the state before saving
			PersistentState_UpdateValues(ent_entry.instance);
			
			array_push(	map_state.entity_listing,
						{
							index:	ent_entry.index,
							state:	ent_entry.instance.game_persistent_state,
							bDestroyed:	false,
						});
		}
		else
		{
			debugLog(kLogVerbose, " map ent " + string(i) + " is destroyed");
			array_push(	map_state.entity_listing,
						{
							index:	ent_entry.index,
							state:	undefined,
							bDestroyed:	true,
						});
		}
	}
	
	// Save the room listing in the global map
	global._persistent_map_info[? map_id] = map_state;
}

// function PersistentStateInitializeHolder(ONLY CALLED BY LOADER OR SETUP)
function PersistentStateInitializeHolder()
{
	gml_pragma("forceinline");
	
	// Initialize persistent state holder
	if (!variable_instance_exists(this, "game_persistent_state"))
	{
		game_persistent_state = {
			destroyed: false,
			listing: [],
		};
	}
}

/// @function PersistentStateExistence()
function PersistentStateExistence()
{
	PersistentState("___dummy___", kValueTypeInteger);
}

/// @function PersistentState(variable_name, type)
function PersistentState(variable_name, variable_type)
{
	// Initialize persistent state holder
	PersistentStateInitializeHolder();
	
	// Set up initial value
	var existingEntryIndex = array_get_index_pred(game_persistent_state.listing, variable_name, function(entry, name) { return entry.name == name; });
	var bVariableExists = existingEntryIndex != null;
	if (bVariableExists)
	{
		var existingEntry = game_persistent_state.listing[existingEntryIndex];
		// Has the value been set by loader or something pre-event?
		if (is_undefined(existingEntry.value) || !haveValue)
		{
			debugLog(kLogError, "Variable \"" + variable_name + "\" already exists.");
		}
		else
		{
			// This branch should never be hit, but we set the value anyways, just in case.
			debugLog(kLogWarning, "Variable \"" + variable_name + "\" loading value from persistence structure pre-load, maybe issue here?");
			variable_instance_set(this, existingEntry.name, existingEntry.value);
		}
	}
	else
	{
		PersistentState_AddVariable(variable_name, variable_type);
	}
	
	// Add this current ent to the tracked listing if it's not in it
	if (!array_contains_pred(global._persistent_ent_listing, this, function(entry, instance) { return entry.instance == instance; }))
	{
		static l_addToListing = function()
		{
			array_push(	global._persistent_ent_listing, 
						{
							instance:	this,
							index:		entityMapIndex,
						});
		};
		executeNextStep(method(this, l_addToListing), this);
	}
}

/// @function PersistentState_AddVariable(ONLY CALLED BY LOADER OR SETUP)
function PersistentState_AddVariable(variable_name, variable_type, variable_value=undefined)
{
	array_push(game_persistent_state.listing, {
		name:		variable_name,
		haveValue:	!is_undefined(variable_value),
		value:		variable_value,
		type:		variable_type,
	});
}

/// @function PersistentState_UpdateValues(instance)
/// @desc Updates the persistent state table with the current variables.
function PersistentState_UpdateValues(instance)
{
	// Initialize persistent state holder
	PersistentStateInitializeHolder();
	
	var state = instance.game_persistent_state;
	
	// Loop through all the values and grab them
	for (var varIndex = 0; varIndex < array_length(state.listing); ++varIndex)
	{
		var variableEntry = state.listing[varIndex];
		variableEntry.value = variable_instance_get(instance, variableEntry.name);
		variableEntry.haveValue = !is_undefined(variableEntry.value);
	}
}

/// @function PersistentStateGet(instance)
function PersistentStateGet(instance)
{
	if (variable_instance_exists(instance, "game_persistent_state"))
	{
		return instance.game_persistent_state;
	}
	else
	{
		return undefined;
	}
}

/// @function PersistentStateSet(instance, state_to_copy)
function PersistentStateSet(instance, state)
{
	if (!is_undefined(state))
	{
		instance.game_persistent_state = state;
	}
}

/// @function PersistentStateCopyFrom(targetInstance, sourceInstance)
function PersistentStateCopyFrom(targetInstance, sourceInstance)
{
	var source_state = PersistentStateGet(sourceInstance);
	return PersistentStateCopyFrom2(targetIndex, source_state);
}
/// @function PersistentStateCopyFrom2(targetInstance, source_state)
function PersistentStateCopyFrom2(targetInstance, source_state)
{
	with (targetInstance)
	{
		PersistentStateInitializeHolder();
	}
	var target_state = PersistentStateGet(targetInstance);
	
	if (!is_undefined(source_state) && !is_undefined(target_state))
	{
		for (var varIndex = 0; varIndex < array_length(source_state.listing); ++varIndex)
		{
			var sourceVariable = source_state.listing[varIndex];
			
			// Find the variable in the target state
			var targetVariableIndex = array_get_index_pred(target_state.listing, sourceVariable.name, function(entry, name) { return entry.name == name; });
			if (targetVariableIndex == null)
			{
				PersistentState_AddVariable(sourceVariable.name, sourceVariable.type, sourceVariable.value);
			}
			// If it exists, then copy over the variable
			else
			{
				var targetVariable = target_state.listing[targetVariableIndex];
				targetVariable.name = sourceVariable.name;
				targetVariable.type = sourceVariable.type;
				targetVariable.haveValue = sourceVariable.haveValue;
				targetVariable.value = sourceVariable.value;
			}
		}
	}
}

/// @function PersistentStateApply(instance)
function PersistentStateApply(instance)
{
	// Pull in matching information from global._persistent_map_state
	if (!is_undefined(global._persistent_map_state))
	{
		// Find matching entity
		var matchingIndex = array_get_index_pred(global._persistent_map_state.entity_listing, instance.entityMapIndex, function(entry, index) { return entry.index == index; });
		if (matchingIndex != null)
		{
			if (global._persistent_map_state.entity_listing[matchingIndex].bDestroyed)
			{
				idelete(instance);
				return;
			}
			else
			{
				PersistentStateCopyFrom2(instance, global._persistent_map_state.entity_listing[matchingIndex].state);
			}
		}
	}
	
	// Now that state is OK we continue
	var persistent_state = PersistentStateGet(instance);
	if (!is_undefined(persistent_state))
	{
		for (var varIndex = 0; varIndex < array_length(persistent_state.listing); ++varIndex)
		{
			var variable = persistent_state.listing[varIndex];
			
			// Simply apply the stored value
			if (variable.haveValue)
			{
				variable_instance_set(instance, variable.name, variable.value);
			}
		}
	}
}