/// @func ACallbackHelper()
function ACallbackHelper() constructor
{
	callbacks = [];
	
	static g_trackId = 0;
	
	static Add = function(callback)
	{
		var l_id = g_trackId++;
		array_push(callbacks, [l_id, callback]);
	}
	
	static Remove = function(cb_id)
	{
		var callbackCount = array_length(callbacks);
		for (var callbackIndex = 0; callbackIndex < callbackCount; ++callbackIndex)
		{
			if (callbacks[callbackIndex][0] == cb_id)
			{
				array_delete(callbacks, callbackIndex, 1);
				return;
			}
		}
	}
	
	static Call = function()
	{
		var callbackCount = array_length(callbacks);
		for (var callbackIndex = 0; callbackIndex < callbackCount; ++callbackIndex)
		{
			var cb = callbacks[callbackIndex][1];
			switch (argument_count)
			{
			case 0:		cb();
				break;
			case 1:		cb(argument[0]);
				break;
			case 2:		cb(argument[0], argument[1]);
				break;
			case 3:		cb(argument[0], argument[1], argument[2]);
				break;
			case 4:		cb(argument[0], argument[1], argument[2], argument[3]);
				break;
			case 5:		cb(argument[0], argument[1], argument[2], argument[3], argument[4]);
				break;
			case 6:		cb(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5]);
				break;
			case 7:		cb(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6]);
				break;
			case 8:		cb(argument[0], argument[1], argument[2], argument[3], argument[4], argument[5], argument[6], argument[7]);
				break;
			}
		}
	}
}