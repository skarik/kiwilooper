function GetLargestSurfaceDims()
{
	static largestSize = 0;
	if (largestSize == 0)
	{
		// TODO: Query from the device in os_info()
		largestSize = 1024;
	}
	return largestSize;
}

// this system doubles up on the sprite memory usage
// but rather use more memory and have a backup in case we lose the buffers

function AAtlasEntry(n_resource) constructor
{
	ResourceAddReference(n_resource);
	resource = n_resource;
	sprite = n_resource.sprite;
	x = 0;
	y = 0;
	width = sprite_get_width(sprite);
	height = sprite_get_height(sprite);
	inUse = false;
}

function _AtlasInitialize()
{
	global._atlas_listing = [];
}
gml_pragma("global", "_AtlasInitialize()");

/// @function AtlasGetListing() 
/// @desc Returns the current list of atlases.
function AtlasGetListing() 
{
	return global._atlas_listing;
}

/// @function AtlasPushToGPU()
/// @desc Ensures all atlases exist as textures on the GPU.
function AtlasPushToGPU()
{
	var atlases = AtlasGetListing();
	for (var i = 0; i < array_length(atlases); ++i)
	{
		var atlas_texture = atlases[i].GetTexture();
		if (atlas_texture == nullptr || atlas_texture == pointer_null || atlas_texture == pointer_invalid)
		{
			debugLog(kLogError, "Atlas index " + string(i) + " had a null texture. This may crash.");
		}
	}
}

/// @function AtlasAddResource(texture_resource)
/// @desc Adds the given resource.
/// @returns Struct {atlas, index}
function AtlasAddResource(texture_resource)
{
	var atlases = AtlasGetListing();
	for (var i = 0; i < array_length(atlases); ++i)
	{
		var atlas = atlases[i];
		// Try to place the new resource.
		var place_result = atlas.TryFitResource(texture_resource);
		if (!is_undefined(place_result))
		{
			// If it fits, place it there and return this new atlas
			var texture_index = atlas.AddResource(texture_resource, place_result);
			return {atlas: i, index: texture_index};
		}
	}
	
	// Else, we need to create a new atlas.
	var atlas = new AAtlas();
	var atlas_index = array_length(atlases);
	array_push(atlases, atlas);
	
	// Add new texture to atlas
	var texture_index = atlas.AddResource(texture_resource);
	return {atlas: atlas_index, index: texture_index};
}

/// @function AtlasGet(atlas_index)
function AtlasGet(atlas_index)
{
	return AtlasGetListing()[atlas_index];
}

function AAtlas() constructor
{
	width = GetLargestSurfaceDims();
	height = GetLargestSurfaceDims();
	
	entries = []; // AAtlasEntry[]
	
	surface = null;
	
	/// @function AddResource(resource, [cached_placeResult])
	/// @desc Add the given texture resource to the atlas.
	static AddResource = function(resource, cached_placeResult = undefined)
	{
		if (ResourceGetTypeIsTexture(resource))
		{
			// Free surface if exists - it is no longer valid for use.
			surface_free_if_exists(surface);
		
			var entry = new AAtlasEntry(resource);
			
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
		else
		{
			debugLog(kLogError, "Resource passed into atlas is not a texture!");
			return null;
		}
	}
	
	/// @function TryFitResource(resource)
	static TryFitResource = function(resource)
	{
		// do a placement check here
		var place_result = _PlaceRect(sprite_get_width(resource.sprite), sprite_get_height(resource.sprite));
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
						|| test_x < test_entry.x + test_entry.width
						|| test_y + height > test_entry.y
						|| test_y < test_entry.y + test_entry.height)
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
	
	/// @function RemoveResource(index)
	static RemoveResource = function(index)
	{
		ResourceRemoveReference(entries[index].resource);
		entries[index].resource = null;
		entries[index].sprite = null;
		entries[index].x = -1;
		entries[index].y = -1;
		entries[index].width = 1;
		entries[index].height = 1;
	}
	
	/// @function GetUVs(index)
	static GetUVs = function(index)
	{
		var entry = entries[index];
		// Texture is in use. Mark that it shouldn't be moved.
		entry.inUse = true; 
		// Generate a GM-style UV array
		return [
			(entry.x) / width,
			(entry.y) / height,
			(entry.x + entry.width) / width,
			(entry.y + entry.height) / height,
			];
	}
	
	static IsFull = function()
	{
		return false; // TODO
	}
	
	static GetTexture = function()
	{
		if (!surface_exists(surface))
		{
			_RenderToSurface();
		}
		return surface_get_texture(surface);
	}
	
	/// @function _RenderToSurface(DO NOT CALL)
	static _RenderToSurface = function()
	{
		surface = surface_create(width, height);
		surface_set_target(surface);
		for (var i = 0; i < array_length(entries); ++i)
		{
			var entry = entries[i];
			if (entry.sprite != null)
			{
				draw_sprite_ext(
					entry.sprite, 0,
					entry.x, entry.y,
					sprite_get_width(entry.sprite) / entry.width,
					sprite_get_height(entry.sprite) / entry.height,
					0, c_white, 1.0);
			}
		}
		surface_reset_target();
	}
}