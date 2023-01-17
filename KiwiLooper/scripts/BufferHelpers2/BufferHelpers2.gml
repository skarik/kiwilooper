// @function buffer_write_type(buffer, value, type)
function buffer_write_type(buffer, value, type)
{
	switch (type)
	{
	case kValueTypePosition:
	case kValueTypeScale:
		{
			buffer_write(buffer, buffer_f16, value.x);
			buffer_write(buffer, buffer_f16, value.y);
			buffer_write(buffer, buffer_f16, value.z);
		}
		break;
				
	case kValueTypeRotation:
		{
			buffer_write(buffer, buffer_s16, EncodeAngleToS16(value.x));
			buffer_write(buffer, buffer_s16, EncodeAngleToS16(value.y));
			buffer_write(buffer, buffer_s16, EncodeAngleToS16(value.z));
		}
		break;
		
	case kValueTypeFloat:
		{
			buffer_write(buffer, buffer_f32, value);
		}
		break;
			
	case kValueTypeInteger:
	case kValueTypeEnum:
		{
			buffer_write(buffer, buffer_s32, value);
		}
		break;
				
	case kValueTypeColor:
		{
			buffer_write(buffer, buffer_u32, value); // The colors in GM cannot be expressed outside of 8-bit color, so we just IO as 32-bit int.
		}
		break;
			
	case kValueTypeBoolean:
		{
			buffer_write(buffer, buffer_u8, value ? 0xFF : 0x00); // No documentation on buffer_bool, so force to u8 here
		}
		break;
				
	case kValueTypeString:
	case kValueTypeLively:
		{
			buffer_write(buffer, buffer_string, value);
		}
		break;
			
	default:
		assert(false); // Unknown type!
	}
}

// @function buffer_read_type(buffer, type)
function buffer_read_type(buffer, type)
{
	var value = undefined;
	switch (type)
	{
	case kValueTypePosition:
	case kValueTypeScale:
		{
			var tx = buffer_read(buffer, buffer_f16);
			var ty = buffer_read(buffer, buffer_f16);
			var tz = buffer_read(buffer, buffer_f16);
			value = new Vector3(tx, ty, tz);
		}
		break;
						
	case kValueTypeRotation:
		{
			var tx = DecodeAngleFromS16(buffer_read(buffer, buffer_s16));
			var ty = DecodeAngleFromS16(buffer_read(buffer, buffer_s16));
			var tz = DecodeAngleFromS16(buffer_read(buffer, buffer_s16));
			value = new Vector3(tx, ty, tz);
		}
		break;
						
	case kValueTypeFloat:
		{
			value = buffer_read(buffer, buffer_f32);
		}
		break;
						
	case kValueTypeInteger:
	case kValueTypeEnum:
		{
			value = buffer_read(buffer, buffer_s32);
		}
		break;
						
	case kValueTypeColor:
		{
			value = buffer_read(buffer, buffer_u32); // The colors in GM cannot be expressed outside of 8-bit color, so we just IO as 32-bit int.
		}
		break;
			
	case kValueTypeBoolean:
		{
			value = buffer_read(buffer, buffer_u8) ? true : false; // No documentation on buffer_bool, so force to true/false here
		}
		break;
					
	case kValueTypeString:
	case kValueTypeLively:
		{
			value = buffer_read(buffer, buffer_string);
		}
		break;
			
	default:
		assert(false); // Unknown type!
	}
	
	return value;
}