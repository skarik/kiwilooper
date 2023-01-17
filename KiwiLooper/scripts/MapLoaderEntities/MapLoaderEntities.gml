#macro kMapEntityFeature_None			0x0001
#macro kMapEntityFeature_ByteSizePerEnt	0x0002
#macro kMapEntityFeature_Persistence	0x0003

function MapLoadEntities(filedata, entityInstanceList)
{
	var buffer = filedata.blob_entities;
	if (buffer == null) return;
	buffer_seek(buffer, buffer_seek_start, 0);
	
	// Entity format:
	//	u32			feature set
	//	u32			element count
	//	u32			extra info A
	//	u32			extra info B
	//	varies[]	entities
	
	var featureset = buffer_read(buffer, buffer_u32);
	var elementcount = buffer_read(buffer, buffer_u32);
	var extrainfoA = buffer_read(buffer, buffer_u32);
	var extrainfoB = buffer_read(buffer, buffer_u32);

	if (featureset >= kMapEntityFeature_None)
	{
		// Entity element format:
		//	string					entity name
		//	u32						entity map id
		//	u32						entity byte size
		//	u16						keyvalue count
		//	{string,u8,varies}[]	keyvalue {name, type, value}
		//	extras
		
		for (var entIndex = 0; entIndex < elementcount; ++entIndex)
		{
			var ent_name = buffer_read(buffer, buffer_string);
			var ent = entlistFindWithName(ent_name);
			
			// Read in the entity map id
			var ent_map_id = entIndex;
			if (featureset >= kMapEntityFeature_Persistence)
			{
				ent_map_id = buffer_read(buffer, buffer_u32);
			}
			
			// Read the entry size
			var ent_byte_size = 0;
			if (featureset >= kMapEntityFeature_ByteSizePerEnt)
			{
				ent_byte_size = buffer_read(buffer, buffer_u32);
				assert(ent_byte_size > 0);
			}
			
			if (ent_byte_size == 0)
			{
				// If we don't recognize the struct, we can't read the data since we cannot skip ahead without size info.
				assert(is_struct(ent));
			}
			else
			{
				// If we don't recognize the struct, skip ahead
				if (!is_struct(ent))
				{
					buffer_seek(buffer, buffer_seek_relative, ent_byte_size);
				}
			}
			
			var ent_byte_start = buffer_tell(buffer);
			
			var bMakeProxy = (ent.proxy != kProxyTypeNone);
		
			// Create an instance now, to read data into
			var instance;
			if (bMakeProxy)
				instance = inew(ProxyClass());
			else
				instance = inew(ent.objectIndex);
			// Set initial needed values
			{
				instance.entity = ent;
				instance.entityMapIndex = ent_map_id;
				instance.x = 0;
				instance.y = 0;
				instance.z = 0;
				instance.xscale = 1.0;
				instance.yscale = 1.0;
				instance.zscale = 1.0;
				instance.xrotation = 0.0;
				instance.yrotation = 0.0;
				instance.zrotation = 0.0;
			}
			
			var kv_count = buffer_read(buffer, buffer_u16);
			for (var kv_index = 0; kv_index < kv_count; ++kv_index)
			{
				var property_name = buffer_read(buffer, buffer_string);
				var property_type = buffer_read(buffer, buffer_u8);
				var property = [property_name, property_type];
			
				var bSpecialTransform = entpropIsSpecialTransform(property);
				
				var value = buffer_read_type(buffer, property[1]);
				switch (property[1])
				{
				case kValueTypePosition:
					{
						if (bSpecialTransform)
						{
							instance.x = value.x;
							instance.y = value.y;
							instance.z = value.z;
						}
						else 
						{
							variable_instance_set(instance, property[0], value);
						}
					}
					break;
			
				case kValueTypeRotation:
					{
						if (bSpecialTransform)
						{
							instance.xrotation = value.x;
							instance.yrotation = value.y;
							instance.zrotation = value.z;
							// Apply game-maker rotations for other effects
							instance.image_angle = value.z;
						}
						else 
						{
							variable_instance_set(instance, property[0], value);
						}
					}
					break;
				
				case kValueTypeScale:
					{
						if (bSpecialTransform)
						{
							instance.xscale = value.x;
							instance.yscale = value.y;
							instance.zscale = value.z;
							// Apply game-maker scaling for other effects
							//instance.image_xscale = value.x;
							//instance.image_yscale = value.y;
						}
						else 
						{
							variable_instance_set(instance, property[0], value);
						}
					}
					break;
				
				default:
					{
						assert(!is_undefined(value));
						variable_instance_set(instance, property[0], value);
					}
					break;
				}
			}
			
			// Fix up undefined values with defaults
			for (var propertyIndex = 0; propertyIndex < array_length(ent.properties); ++propertyIndex)
			{
				var property = ent.properties[propertyIndex];
				if (entpropHasDefaultValue(property)
					&& is_undefined(variable_instance_get(instance, property[0])) )
				{
					variable_instance_set(instance, property[0], property[2]);
				}
			}
			
			// Load in persistence (unused)
			if (featureset >= kMapEntityFeature_Persistence)
			{
				var persistence_count = buffer_read(buffer, buffer_u32);
				
				if (persistence_count > 0)
				{
					with (instance)
					{
						PersistentStateInitializeHolder();
					}
					for (var varIndex = 0; varIndex < persistence_count; ++varIndex)
					{
						var name = buffer_read(buffer, buffer_string);
						var type = buffer_read(buffer, buffer_u8);
						var value = buffer_read_type(buffer, type);
					
						with (instance)
						{
							PersistentState_AddVariable(name, type, value);
						}
					}
				}
			}
			
			// If we have byte size, use it to verify the data location
			if (featureset >= kMapEntityFeature_ByteSizePerEnt)
			{
				var ent_byte_now = buffer_tell(buffer);
				assert(ent_byte_start + ent_byte_size == ent_byte_now);
			}
		
			// Add instance to the listing
			entityInstanceList.Add(instance);
		}
		// End for(entList < elementcount)
	}
}

function MapSaveEntities(filedata, entityInstanceList)
{
	if (filedata.blob_entities != null)
	{
		buffer_delete(filedata.blob_entities);
	}
	
	var buffer = buffer_create(0, buffer_grow, 1);
	
	// Entity format:
	//	u32			feature set
	//	u32			element count
	//	u32			extra info A
	//	u32			extra info B
	//	varies[]	entities
	
	buffer_write(buffer, buffer_u32, kMapEntityFeature_Persistence);
	buffer_write(buffer, buffer_u32, entityInstanceList.GetEntityCount());
	buffer_write(buffer, buffer_u32, 0);
	buffer_write(buffer, buffer_u32, 0);
	
	for (var entIndex = 0; entIndex < entityInstanceList.GetEntityCount(); ++entIndex)
	{
		var instance = entityInstanceList.GetEntity(entIndex);
		var ent = instance.entity;
		
		// Fix up undefined values with defaults
		for (var propertyIndex = 0; propertyIndex < array_length(ent.properties); ++propertyIndex)
		{
			var property = ent.properties[propertyIndex];
			if (entpropHasDefaultValue(property)
				&& is_undefined(variable_instance_get(instance, property[0])) )
			{
				variable_instance_set(instance, property[0], property[2]);
			}
		}
		
		/// @function PropertyIsValid(instance, property)
		function PropertyIsValid(instance, property)
		{
			var bSpecialTransform = entpropIsSpecialTransform(property);
			return bSpecialTransform || !is_undefined(variable_instance_get(instance, property[0]));
		}
		// First, count number of valid properties
		var validPropertyCount = 0;
		for (var propertyIndex = 0; propertyIndex < array_length(ent.properties); ++propertyIndex)
		{
			if (PropertyIsValid(instance, ent.properties[propertyIndex]))
			{
				validPropertyCount++; // TODO: Cache the property so we only check once
			}
		}
		
		// Entity element format:
		//	string					entity name
		//	u32						entity map id
		//	u32						entity byte size
		//	u16						keyvalue count
		//	{string,u8,varies}[]	keyvalue {name, type, value}
		//	extras
		
		buffer_write(buffer, buffer_string, ent.name);
		
		// Write in the entity map id
		buffer_write(buffer, buffer_u32, instance.entityMapIndex);
		
		// Create a buffer for our ent
		var ent_buffer = buffer_create(0, buffer_grow, 1);
		{
			// Write the properties:
			buffer_write(ent_buffer, buffer_u16, validPropertyCount); // We write valid property count, not ent.properties. Could be less or more.
			for (var propertyIndex = 0; propertyIndex < array_length(ent.properties); ++propertyIndex)
			{
				var property = ent.properties[propertyIndex];
				var bSpecialTransform = entpropIsSpecialTransform(property);
			
				// Skip undefined/unsupported variables
				if (!PropertyIsValid(instance, property))
				{
					continue;
				}
			
				buffer_write(ent_buffer, buffer_string, property[0]);
				buffer_write(ent_buffer, buffer_u8, property[1]);
			
				switch (property[1])
				{
				case kValueTypePosition:
					{
						var value;
						if (bSpecialTransform)
							value = new Vector3(instance.x, instance.y, instance.z);
						else 
							value = variable_instance_get(instance, property[0]);
				
						buffer_write_type(ent_buffer, value, property[1]);
					}
					break;
				
				case kValueTypeRotation:
					{
						var value;
						if (bSpecialTransform)
							value = new Vector3(instance.xrotation, instance.yrotation, instance.zrotation);
						else 
							value = variable_instance_get(instance, property[0]);
				
						buffer_write_type(ent_buffer, value, property[1]);
					}
					break;
				
				case kValueTypeScale:
					{
						var value;
						if (bSpecialTransform)
							value = new Vector3(instance.xscale, instance.yscale, instance.zscale);
						else 
							value = variable_instance_get(instance, property[0]);
						
						buffer_write_type(ent_buffer, value, property[1]);
					}
					break;
				
				default:
					{
						var value = variable_instance_get(instance, property[0]);
						buffer_write_type(ent_buffer, value, property[1]);
					}
					break;
				}
			}
		
			// Write the persistence state (unused):
			var persistence_state = PersistentStateGet(instance);
			if (!is_undefined(persistence_state))
			{
				buffer_write(ent_buffer, buffer_u32, array_length(persistence_state.listing));
				for (var varIndex = 0; varIndex < array_length(persistence_state.listing); ++varIndex)
				{
					// Write name,type,value
					var entry = persistence_state.listing[varIndex];
					buffer_write(ent_buffer, buffer_string, entry.name);
					buffer_write(ent_buffer, buffer_u8, entry.type);
					buffer_write_type(ent_buffer, entry.value, entry.type);
				}
			}
			else
			{
				buffer_write(ent_buffer, buffer_u32, 0);
			}
		}
		
		// Write size of ent_buffer to the buffer
		buffer_write(buffer, buffer_u32, buffer_tell(ent_buffer));
		
		// Write the ent_buffer contents over
		buffer_write_buffer(buffer, ent_buffer);
	}
	
	// Save the buffer we just created to the filedata.
	filedata.blob_entities = buffer;
}