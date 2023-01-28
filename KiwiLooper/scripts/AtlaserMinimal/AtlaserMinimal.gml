function ARectFitEntry(in_width, in_height, in_userdata) constructor
{
	userdata = in_userdata;
	width = in_width;
	height = in_height;
}

/// @function ARectFitter(in_width, in_height) constructor
/// @desc A minimal version of the AAtlas placement logic
function ARectFitter(in_width, in_height) constructor
{
	width = in_width;
	height = in_height;
	
	entries = []; // ARectFitEntry[]
	
	/// @function Clear()
	static Clear = function()
	{
		for (var i = 0; i < array_length(entries); ++i)
		{
			delete entries[i];
		}
		entries = [];
	}
	
	/// @function AddRect(width, height, in_userdata, [cached_placeResult])
	/// @desc Add the given rect to the fitter.
	static AddRect = function(in_width, in_height, in_userdata, cached_placeResult = undefined)
	{
		var entry = new ARectFitEntry(in_width, in_height, in_userdata);
			
		// Place it in entries?
		if (!is_undefined(cached_placeResult))
		{
			entry.x = cached_placeResult.x;
			entry.y = cached_placeResult.y;
		}
		else
		{
			var placeResult = _PlaceRect(entry.width, entry.height);
			entry.x = placeResult.x;
			entry.y = placeResult.y;
		}
			
		array_push(entries, entry);
		return array_length(entries) - 1;
	}
	
	/// @function TryFitRect(in_width, in_height)
	static TryFitRect = function(in_width, in_height)
	{
		// do a placement check here
		var place_result = _PlaceRect(in_width, in_height);
		if (!is_undefined(place_result))
		{
			return place_result;
		}
		return undefined;
	}
	
	static _PlaceRect = function(width, height)
	{
		// create all the x positions we try, create all the y positions we try
		// x positions are left & right
		// y positions are bottoms
		// try all of them
		
		var x_positions = [0];
		var y_positions = [0];
		
		// Build all the possible placement positions
		for (var i = 0; i < array_length(entries); ++i)
		{
			var entry = entries[i];
			
			if (!array_contains(x_positions, entry.x))
				array_push(x_positions, entry.x);
			if (!array_contains(x_positions, entry.x + entry.width))
				array_push(x_positions, entry.x + entry.width);
				
			if (!array_contains(y_positions, entry.y))
				array_push(y_positions, entry.y);
			if (!array_contains(y_positions, entry.y + entry.height))
				array_push(y_positions, entry.y + entry.height);
		}
		
		// Roll through all the permutations and find the first one that works
		for (var y_position_index = 0; y_position_index < array_length(y_positions); ++y_position_index)
		{
			var test_y = y_positions[y_position_index];
			for (var x_position_index = 0; x_position_index < array_length(x_positions); ++x_position_index)
			{
				var test_x = x_positions[x_position_index];
				
				var test_isOkay = true;
				for (var entry_index = 0; entry_index < array_length(entries); ++entry_index)
				{
					var test_entry = entries[entry_index];
					// BBoxes overlap, failure
					if (test_x + width > test_entry.x
						&& test_x < test_entry.x + test_entry.width
						&& test_y + height > test_entry.y
						&& test_y < test_entry.y + test_entry.height)
					{
						test_isOkay = false;
						break;
					}
				}
				
				// No overlap, we found a good position to place into.
				if (test_isOkay)
				{
					return {x: test_x, y: test_y};
				}
			}
		}
		
		return undefined;
	}
	
	/// @function RemoveEntry(index)
	static RemoveEntry = function(index)
	{
		entries[index].x = -1;
		entries[index].y = -1;
		entries[index].width = 1;
		entries[index].height = 1;
		entries[index].userdata = undefined;
	}
	
	/// @function GetUVs(index)
	static GetUVs = function(index)
	{
		var entry = entries[index];
		return [
			(entry.x) / width,
			(entry.y) / height,
			(entry.x + entry.width) / width,
			(entry.y + entry.height) / height,
			];
	}
	/// @function GetUnscaledSize(index)
	static GetUnscaledSize = function(index)
	{
		var entry = entries[index];
		return [
			entry.width,
			entry.height,
			];
	}
	/// @function GetUnscaledPosition(index)
	static GetUnscaledPosition = function(index)
	{
		var entry = entries[index];
		return [
			entry.x,
			entry.y,
			];
	}
}