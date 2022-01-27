function _EntityInfoInit()
{
	#macro kValueTypePosition 0
	#macro kValueTypeRotation 1
	#macro kValueTypeScale 2
	#macro kValueTypeFloat 3
	#macro kValueTypeColor 4
	#macro kValueTypeBoolean 5
	
	#macro kGizmoDrawmodeBillboard 0
	#macro kGizmoDrawmodeHidden 1
	
	#macro kProxyTypeNone 0		// No proxy: the actual object is created.
	#macro kProxyTypeProp 1		// Specific kind of proxy usually reserved for props. Treats the given object as a special prop.
	#macro kProxyTypeDefault 2	// Creates a proxy object that represents the actual object but does not have active logic.
	
	global.entityList = [
		// Base classes:
		{
			hidden: true,
			name: "lively_base",
			objectIndex: ob_lively,
			proxy: kProxyTypeDefault,
			
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
			proxy: kProxyTypeNone,
			
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
			proxy: kProxyTypeNone,
			
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
			],
		},
		{
			parent: "lively_base",
			name: "lively_exploding_wires",
			desc: "",
			objectIndex: o_livelyExplodingWires,
			
			gizmoSprite: suie_gizmoEnts,
			gizmoIndex: 0,
			
			hullsize: 8,
			
			properties:
			[
				["", kValueTypePosition],
			],
		},
		{
			parent: "lively_base",
			name: "lively_level_goal",
			desc: "",
			objectIndex: o_livelyGoalArea,
			
			gizmoSprite: suie_gizmoEnts,
			gizmoIndex: 0,
			
			hullsize: 8,
			
			properties:
			[
				["", kValueTypePosition],
			],
		},
		
		// Usables:
		{
			parent: "lively_base",
			name: "usable_pc",
			objectIndex: o_usablePC,
			
			gizmoSprite: suie_gizmoEnts,
			gizmoIndex: 4,
			gizmoDrawmode: kGizmoDrawmodeHidden,
		},
		{
			parent: "lively_base",
			name: "usable_logbook",
			objectIndex: o_usableLogbook,
			
			gizmoSprite: suie_gizmoEnts,
			gizmoIndex: 4,
			gizmoDrawmode: kGizmoDrawmodeHidden,
		},
		{
			parent: "lively_base",
			name: "usable_corpse_robo",
			objectIndex: o_usableCorpseRobo,
			
			gizmoSprite: suie_gizmoEnts,
			gizmoIndex: 4,
			gizmoDrawmode: kGizmoDrawmodeHidden,
		},
		{
			parent: "lively_base",
			name: "usable_corpse_kiwi",
			objectIndex: o_usableCorpseKiwi,
			
			gizmoSprite: suie_gizmoEnts,
			gizmoIndex: 4,
			gizmoDrawmode: kGizmoDrawmodeHidden,
		},
	];
	global.entityList_Count = array_length(global.entityList);
	
	// Fill the structures with all the data theyre missing via inheritance.
	_EntityInfoInit_FillInheritance();
	// Fill in the missing data
	_EntityInfoInit_FillMissingDefaults();
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
							array_insert(currentEntry.properties, insertCount, CE_ArrayClone(parentProp));
							++insertCount;
						}
					} // end for-loop for parent properties
				}
			}
		} // end for-loop for all entities
	}
}
// @desc Fills the ent list values with missing mandatory values with safe defaults
function _EntityInfoInit_FillMissingDefaults()
{
	var kEntCount = array_length(global.entityList);
	for (var entIndex = 0; entIndex < kEntCount; ++entIndex)
	{
		var currentEntry = global.entityList[entIndex];
		
		// Default to full proxy
		if (!variable_struct_exists(currentEntry, "proxy"))
		{
			currentEntry.proxy = kProxyTypeDefault;
		}
		// Default to shown in the list
		if (!variable_struct_exists(currentEntry, "hidden"))
		{
			currentEntry.hidden = false;
		}
		// Default half-tile hullsize
		if (!variable_struct_exists(currentEntry, "hullsize"))
		{
			currentEntry.hullsize = 8;
		}
		// Default hidden billboard gizmo
		if (!variable_struct_exists(currentEntry, "gizmoSprite"))
		{
			currentEntry.gizmoSprite = suie_gizmoEnts;
		}
		if (!variable_struct_exists(currentEntry, "gizmoIndex"))
		{
			currentEntry.gizmoIndex = 0;
		}
		if (!variable_struct_exists(currentEntry, "gizmoDrawmode"))
		{
			currentEntry.gizmoDrawmode = kGizmoDrawmodeHidden;
		}
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

/// @function entpropToString(instance, property)
/// @desc Returns a string of the given property.
function entpropToString(instance, property)
{
	var l_bSpecialPosition = (property[0] == "") && (property[1] == kValueTypePosition);
	var l_bSpecialRotation = (property[0] == "") && (property[1] == kValueTypeRotation);
	var l_bSpecialScale = (property[0] == "") && (property[1] == kValueTypeScale);
			
	if (l_bSpecialPosition)
	{
		var string_format_pos = function(value) { return string_ltrim(string_format(round(value * 10) / 10, 10, 1)); }
		return string_format_pos(instance.x) + " " + string_format_pos(instance.y) + " " + string_format_pos(instance.z);
	}
	else if (l_bSpecialRotation)
	{
		var string_format_pos = function(value) { return string_ltrim(string_format(round(value * 10) / 10, 10, 1)); }
		return string_format_pos(instance.xrotation) + " " + string_format_pos(instance.yrotation) + " " + string_format_pos(instance.zrotation);
	}
	else if (l_bSpecialScale)
	{
		var string_format_pos = function(value) { return string_ltrim(string_format(round(value * 100) / 100, 10, 2)); }
		return string_format_pos(instance.xscale) + " " + string_format_pos(instance.yscale) + " " + string_format_pos(instance.zscale);
	}
	else if (property[1] == kValueTypeColor)
	{
		var color = is_struct(instance) ? variable_struct_get(instance, property[0]) : variable_instance_get(instance, property[0]);
		return string(color_get_red(color)) + " " + string(color_get_green(color)) + " " + string(color_get_blue(color));
	}
	else
	{
		return string(is_struct(instance) ? variable_struct_get(instance, property[0]) : variable_instance_get(instance, property[0]));
	}
}

/// @function entpropSetFromString(instance, property, stringValue)
/// @desc Converts the given value to the proper type and assigns it.
/// @returns True on success, False on failure to properly convert.
function entpropSetFromString(instance, property, stringValue)
{
	static GetFloatTuple = function(inputString)
	{
		var tokens = string_split(inputString, " ,;", true);
		var tokenCount = array_length(tokens);
		
		var results = array_create(tokenCount, 0.0);
		for (var i = 0; i < tokenCount; ++i)
		{
			try
			{
				results[i] = real(tokens[i]);
			}
			catch (_exception)
			{
				return undefined;
			}
		}
		return results;
	}
	
	var convertedValue = undefined;
	
	// First, convert the value:
	switch (property[1])
	{
	case kValueTypeFloat:
		try
		{
			convertedValue = real(stringValue);
		}
		catch (_exception)
		{
			convertedValue = undefined;
		}
		break;
		
	case kValueTypeBoolean:
		{
			var l_lowerString = string_lower(stringValue);
			var l_value = undefined;
			try
			{
				l_value = real(stringValue);
			}
			catch (_exception)
			{
				l_value = undefined;
			}
			
			if (!is_undefined(l_value))
			{
				convertedValue = bool(l_value);
			}
			else
			{
				if (l_lowerString == "t" || l_lowerString == "true" || l_lowerString == "y" || l_lowerString == "yes")
				{
					convertedValue = true;
				}
				else if (l_lowerString == "f" || l_lowerString == "false" || l_lowerString == "n" || l_lowerString == "no")
				{
					convertedValue = false;
				}
			}
		}
		break;
		
	case kValueTypeColor:
		{
			var tuple = GetFloatTuple(stringValue);
			if (!is_undefined(tuple) && array_length(tuple) >= 3)
			{
				static IsInRange = function(value) { return !is_undefined(value) && value >= 0.0 && value <= 255.0; }
				if (IsInRange(tuple[0]) && IsInRange(tuple[1]) && IsInRange(tuple[2]))
				{
					convertedValue = make_color_rgb(tuple[0], tuple[1], tuple[2]);
				}
			}
		}
		break;
		
	case kValueTypePosition:
	case kValueTypeRotation:
	case kValueTypeScale:
		{
			var tuple = GetFloatTuple(stringValue);
			if (!is_undefined(tuple) && array_length(tuple) >= 3)
			{
				convertedValue = Vector3FromArray(tuple);
			}
		}
		break;
	}
	
	// Check for invalid conversion now
	if (is_undefined(convertedValue))
	{
		return false;
	}
	
	// Now assign the values back
	var l_bSpecialPosition = (property[0] == "") && (property[1] == kValueTypePosition);
	var l_bSpecialRotation = (property[0] == "") && (property[1] == kValueTypeRotation);
	var l_bSpecialScale = (property[0] == "") && (property[1] == kValueTypeScale);
	
	if (l_bSpecialPosition)
	{
		instance.x = convertedValue.x;
		instance.y = convertedValue.y;
		instance.z = convertedValue.z;
	}
	else if (l_bSpecialRotation)
	{
		instance.xrotation = convertedValue.x;
		instance.yrotation = convertedValue.y;
		instance.zrotation = convertedValue.z;
	}
	else if (l_bSpecialScale)
	{
		instance.xscale = convertedValue.x;
		instance.yscale = convertedValue.y;
		instance.zscale = convertedValue.z;
	}
	else
	{
		if (is_struct(instance))
		{
			variable_struct_set(instance, property[0], convertedValue);
		}
		else
		{
			variable_instance_set(instance, property[0], convertedValue);
		}
	}
	
	return true;
}

/// @function entpropIsSpecialTransform(property)
/// @desc Checks if the given property is a special transform that needs to be perculated through the editor
function entpropIsSpecialTransform(property)
{
	var l_bSpecialPosition = (property[0] == "") && (property[1] == kValueTypePosition);
	var l_bSpecialRotation = (property[0] == "") && (property[1] == kValueTypeRotation);
	var l_bSpecialScale = (property[0] == "") && (property[1] == kValueTypeScale);
	
	return l_bSpecialPosition || l_bSpecialRotation || l_bSpecialScale;
}