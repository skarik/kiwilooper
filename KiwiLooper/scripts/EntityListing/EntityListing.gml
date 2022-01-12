function _EntityInfoInit()
{
	#macro kValueTypePosition 0
	#macro kValueTypeRotation 1
	#macro kValueTypeScale 2
	#macro kValueTypeFloat 3
	#macro kValueTypeColor 4
	#macro kValueTypeBoolean 5
	
	global.entityList = [
		// Base classes:
		{
			hidden: true,
			name: "lively_base",
			objectIndex: ob_lively,
			properties:
			[
				["", kValueTypePosition],
				["", kValueTypeRotation],
				["", kValueTypeScale],
				["translucent", kValueTypeBoolean],
				["lit", kValueTypeBoolean],
			],
		},
	
		// Lights:
		{
			name: "light",
			desc: "Normal dynamic 3D light",
			objectIndex: ob_3DLight,
			
			gizmoSprite: suie_gizmoEnts,
			gizmoIndex: 0,
			
			hullsize: 8,
			
			properties:
			[
				["", kValueTypePosition],
				["intensity", kValueTypeFloat],
				["range", kValueTypeFloat],
				["color", kValueTypeColor],
			],
		},
		{
			name: "light_ambient",
			desc: "Ambient light override helper",
			objectIndex: o_ambientOverride,
			
			gizmoSprite: suie_gizmoEnts,
			gizmoIndex: 1,
			
			hullsize: 8,
			
			properties:
			[
				// Position doesn't actually matter, but the object still has it.
				["color", kValueTypeColor],
			],
		},
		
		// Livelies:
		{
			parent: "lively_base",
			name: "lively_door_test",
			desc: "Door used in initial LD47 creation",
			objectIndex: o_livelyDoor,
			
			gizmoSprite: suie_gizmoEnts,
			gizmoIndex: 0,
			
			hullsize: 8,
			
			properties:
			[
				["", kValueTypePosition],
				["intensity", kValueTypeFloat],
				["range", kValueTypeFloat],
				["color", kValueTypeColor],
			],
		},
	];
	global.entityList_Count = array_length(global.entityList);
	
	// Fill the structures with all the data theyre missing via inheritance.
	_EntityInfoInit_FillInheritance();
	// Pregenerate list of entities with visible ents.
	_EntityInfoInit_GenerateVisible();
}
gml_pragma("global", "_EntityInfoInit()");

// @desc Fills entity list with missing data that's grabbed from inheritance.
function _EntityInfoInit_FillInheritance()
{
	repeat (2) // Limit to 2 levels of out-of-order inheritance.
	{
		var kEntCount = array_length(global.entityList);
		for (var entIndex = 0; entIndex < kEntCount; ++entIndex)
		{
			var currentEntry = global.entityList[entIndex];
			
			// Have a parent?
			if (variable_struct_exists(currentEntry, "parent"))
			{
				var parentEntry = entlistFindWithName(currentEntry.parent);
				
				// We have a parent, we can now iterate through all the values inside the parent.
				if (is_struct(parentEntry))
				{
					var parentVariableNames = variable_struct_get_names(parentEntry);
					for (var parentVariableIndex = 0; parentVariableIndex < array_length(parentVariableNames); ++parentVariableIndex)
					{
						var parentVariable = parentVariableNames[parentVariableIndex];
						// Skip certain values
						if (parentVariable == "hidden")
							continue;
						
						// If the variable doesn't exist in the child, then we add it.
						if (!variable_struct_exists(currentEntry, parentVariable))
						{
							variable_struct_set(currentEntry, parentVariable, variable_struct_get(parentEntry, parentVariable));
						}
					} // end for-loop for parent variables
					
					// And now fill in all the properties that are missing.
					var insertCount = 0;
					for (var parentPropIndex = 0; parentPropIndex < array_length(parentEntry.properties); ++parentPropIndex)
					{
						var parentProp = parentEntry.properties[parentPropIndex];
						if (!entPropertyExists(currentEntry, parentProp[0], parentProp[1]))
						{
							array_insert(currentEntry.properties, insertCount, ce_array_clone(parentProp));
							++insertCount;
						}
					} // end for-loop for parent properties
				}
			}
		} // end for-loop for all entities
	}
}

// @desc Generate listing of all visible entities.
function _EntityInfoInit_GenerateVisible()
{
	global.entityList_VisibleIndicies = [];
	
	var kEntCount = array_length(global.entityList);
	for (var entIndex = 0; entIndex < kEntCount; ++entIndex)
	{
		var currentEntry = global.entityList[entIndex];
		
		if (variable_struct_exists(currentEntry, "hidden")
			&& currentEntry.hidden)
		{
			continue; // Skip this one.
		}
		else
		{
			// Not hidden, save the index.
			array_push(global.entityList_VisibleIndicies, entIndex);
		}
	}
	
	global.entityList_VisibleIndicies_Count = array_length(global.entityList_VisibleIndicies);
}

/// @function entlistLength()
/// @desc Returns the number of entries in global.entityList
function entlistLength()
{
	gml_pragma("forceinline");
	return global.entityList_Count;
}

/// @function entlistIterationLength()
/// @desc Returns number of items to iterate through for global.entityList
function entlistIterationLength()
{
	gml_pragma("forceinline");
	return global.entityList_VisibleIndicies_Count;
}
/// @function entlistIterationGet(iteration)
/// @desc Returns the entity with given iteration
function entlistIterationGet(iteration)
{
	gml_pragma("forceinline");
	return global.entityList[global.entityList_VisibleIndicies[iteration]];
}

/// @function entlistFindWithName(name)
/// @desc Find the entry in the entlist with the matching name.
function entlistFindWithName(name)
{
	var kEntCount = array_length(global.entityList);
	for (var entIndex = 0; entIndex < kEntCount; ++entIndex)
	{
		var currentEntry = global.entityList[entIndex];
		if (currentEntry.name == name)
		{
			return currentEntry;
		}
	}
	return null;
}

/// @function entlistFindWithObjectIndex(objectIndex)
/// @desc Find the entry in the entlist with the matching objectIndex.
function entlistFindWithObjectIndex(objectIndex)
{
	var kEntCount = array_length(global.entityList);
	for (var entIndex = 0; entIndex < kEntCount; ++entIndex)
	{
		var currentEntry = global.entityList[entIndex];
		if (currentEntry.objectIndex == objectIndex)
		{
			return currentEntry;
		}
	}
	return null;
}

/// @function entPropertyExists(ent, name, type)
/// @desc Looks for the given property with matching name and type in the given ent.
function entPropertyExists(ent, name, type)
{
	var kPropCount = array_length(ent.properties);
	for (var propIndex = 0; propIndex < kPropCount; ++propIndex)
	{
		if (ent.properties[propIndex][0] == name
			&& ent.properties[propIndex][1] == type)
		{
			return true;
		}
	}
	return false;
}