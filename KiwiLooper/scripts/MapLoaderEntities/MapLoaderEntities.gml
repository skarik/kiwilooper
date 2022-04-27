#macro kMapEntityFeature_None			0x0001
#macro kMapEntityFeature_ByteSizePerEnt	0x0002

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

	if (featureset <= kMapEntityFeature_None)
	{
		// Entity element format:
		//	string					entity name
		//	u16						keyvalue count
		//	{string,u8,varies}[]	keyvalue {name, type, value}
		
		for (var entIndex = 0; entIndex < elementcount; ++entIndex)
		{
			var ent_name = buffer_read(buffer, buffer_string);
			var ent = entlistFindWithName(ent_name);
		
			// If we don't recognize the struct, we can't read the data since we cannot skip ahead without size info.
			assert(is_struct(ent));
		
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
				switch (property[1])
				{
				case kValueTypePosition:
					{
						var tx = buffer_read(buffer, buffer_f16);
						var ty = buffer_read(buffer, buffer_f16);
						var tz = buffer_read(buffer, buffer_f16);
					
						if (bSpecialTransform)
						{
							instance.x = tx;
							instance.y = ty;
							instance.z = tz;
						}
						else 
						{
							variable_instance_set(instance, property[0], new Vector3(tx, ty, tz));
						}
					}
					break;
				
				case kValueTypeRotation:
					{
						var tx = DecodeAngleFromS16(buffer_read(buffer, buffer_s16));
						var ty = DecodeAngleFromS16(buffer_read(buffer, buffer_s16));
						var tz = DecodeAngleFromS16(buffer_read(buffer, buffer_s16));
					
						if (bSpecialTransform)
						{
							instance.xrotation = tx;
							instance.yrotation = ty;
							instance.zrotation = tz;
							// Apply game-maker rotations for other effects
							instance.image_angle = tz;
						}
						else 
						{
							variable_instance_set(instance, property[0], new Vector3(tx, ty, tz));
						}
					}
					break;
				
				case kValueTypeScale:
					{
						var tx = buffer_read(buffer, buffer_f16);
						var ty = buffer_read(buffer, buffer_f16);
						var tz = buffer_read(buffer, buffer_f16);
					
						if (bSpecialTransform)
						{
							instance.xscale = tx;
							instance.yscale = ty;
							instance.zscale = tz;
							// Apply game-maker scaling for other effects
							//instance.image_xscale = tx;
							//instance.image_yscale = ty;
						}
						else 
						{
							variable_instance_set(instance, property[0], new Vector3(tx, ty, tz));
						}
					}
					break;
				
				case kValueTypeFloat:
					{
						var value = buffer_read(buffer, buffer_f32);
						variable_instance_set(instance, property[0], value);
					}
					break;
					
				case kValueTypeInteger:
				case kValueTypeEnum:
					{
						var value = buffer_read(buffer, buffer_s32);
						variable_instance_set(instance, property[0], value);
					}
					break;
				
				case kValueTypeColor:
					{
						var value = buffer_read(buffer, buffer_u32); // The colors in GM cannot be expressed outside of 8-bit color, so we just IO as 32-bit int.
						variable_instance_set(instance, property[0], value);
					}
					break;
			
				case kValueTypeBoolean:
					{
						var value = buffer_read(buffer, buffer_u8) ? true : false; // No documentation on buffer_bool, so force to true/false here
						variable_instance_set(instance, property[0], value);
					}
					break;
					
				case kValueTypeString:
				case kValueTypeLively:
					{
						var value = buffer_read(buffer, buffer_string);
						variable_instance_set(instance, property[0], value);
					}
					break;
			
				default:
					assert(false); // Unknown type!
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
	
	buffer_write(buffer, buffer_u32, kMapEntityFeature_None);
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
		//	u16						keyvalue count
		//	{string,u8,varies}[]	keyvalue {name, type, value}
		
		buffer_write(buffer, buffer_string, ent.name);
		buffer_write(buffer, buffer_u16, validPropertyCount); // We write valid property count, not ent.properties. Could be less or more.
		
		for (var propertyIndex = 0; propertyIndex < array_length(ent.properties); ++propertyIndex)
		{
			var property = ent.properties[propertyIndex];
			var bSpecialTransform = entpropIsSpecialTransform(property);
			
			// Skip undefined/unsupported variables
			if (!PropertyIsValid(instance, property))
			{
				continue;
			}
			
			buffer_write(buffer, buffer_string, property[0]);
			buffer_write(buffer, buffer_u8, property[1]);
			
			
			switch (property[1])
			{
			case kValueTypePosition:
				{
					var value;
					if (bSpecialTransform)
						value = new Vector3(instance.x, instance.y, instance.z);
					else 
						value = variable_instance_get(instance, property[0]);
				
					buffer_write(buffer, buffer_f16, value.x);
					buffer_write(buffer, buffer_f16, value.y);
					buffer_write(buffer, buffer_f16, value.z);
				}
				break;
				
			case kValueTypeRotation:
				{
					var value;
					if (bSpecialTransform)
						value = new Vector3(instance.xrotation, instance.yrotation, instance.zrotation);
					else 
						value = variable_instance_get(instance, property[0]);
				
					buffer_write(buffer, buffer_s16, EncodeAngleToS16(value.x));
					buffer_write(buffer, buffer_s16, EncodeAngleToS16(value.y));
					buffer_write(buffer, buffer_s16, EncodeAngleToS16(value.z));
				}
				break;
				
			case kValueTypeScale:
				{
					var value;
					if (bSpecialTransform)
						value = new Vector3(instance.xscale, instance.yscale, instance.zscale);
					else 
						value = variable_instance_get(instance, property[0]);
						
					buffer_write(buffer, buffer_f16, value.x);
					buffer_write(buffer, buffer_f16, value.y);
					buffer_write(buffer, buffer_f16, value.z);
				}
				break;
				
			case kValueTypeFloat:
				{
					var value = variable_instance_get(instance, property[0]);
					buffer_write(buffer, buffer_f32, value);
				}
				break;
			
			case kValueTypeInteger:
			case kValueTypeEnum:
				{
					var value = variable_instance_get(instance, property[0]);
					buffer_write(buffer, buffer_s32, value);
				}
				break;
				
			case kValueTypeColor:
				{
					var value = variable_instance_get(instance, property[0]);
					buffer_write(buffer, buffer_u32, value); // The colors in GM cannot be expressed outside of 8-bit color, so we just IO as 32-bit int.
				}
				break;
			
			case kValueTypeBoolean:
				{
					var value = variable_instance_get(instance, property[0]);
					buffer_write(buffer, buffer_u8, value ? 0xFF : 0x00); // No documentation on buffer_bool, so force to u8 here
				}
				break;
				
			case kValueTypeString:
			case kValueTypeLively:
				{
					var value = variable_instance_get(instance, property[0]);
					buffer_write(buffer, buffer_string, value);
				}
				break;
			
			default:
				assert(false); // Unknown type!
			}
			
		}
	}
	
	// Save the buffer we just created to the filedata.
	filedata.blob_entities = buffer;
}