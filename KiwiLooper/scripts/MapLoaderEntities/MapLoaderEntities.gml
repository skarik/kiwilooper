#macro kMapEntityFeature_None			0x0001

function MapLoadEntities(filedata, entityInstanceList)
{
	var buffer = filedata.blob_entities;
	if (buffer == null) return;
	buffer_seek(buffer, buffer_seek_start, 0);
	
	// todo
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
		
		// Entity element format:
		//	string					entity name
		//	u16						keyvalue count
		//	{string,u8,varies}[]	keyvalue {name, type, value}
		
		buffer_write(buffer, buffer_string, ent.name);
		buffer_write(buffer, buffer_string, array_length(ent.properties));
		
		for (var propertyIndex = 0; propertyIndex < array_length(ent.properties); ++propertyIndex)
		{
			var property = ent.properties[propertyIndex];
			buffer_write(buffer, buffer_string, property[0]);
			buffer_write(buffer, buffer_u8, property[1]);
			
			var bSpecialTransform = entpropIsSpecialTransform(property);
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
			
			default:
				assert(false); // Unknown type!
			}
			
		}
	}
	
	// Save the buffer we just created to the filedata.
	filedata.blob_entities = buffer;
}