/// @function ASplatEntry() constructor
/// @desc Representation of a prop and their information.
function ASplatEntry() constructor
{
	// Indexer
	_id = null;
	static Id = function()
	{
		return _id;
	}
	
	// Transformation
	x = 0;
	y = 0;
	z = 0;
	xrotation = 0;
	yrotation = 0;
	zrotation = 0;
	xscale = 1.0;
	yscale = 1.0;
	zscale = 1.0;
	
	// Display
	blend = bm_normal;
	color = c_white;
	
	// Sprite
	index = 0;
	sprite = null;
}

/// @function ASplatMap() constructor
/// @desc Has a "map" of props.
function ASplatMap() constructor
{
	props = []; // TODO: Rename someday
	lastId = 0;
	
	static Clear = function()
	{
		for (var i = 0; i < GetSplatCount(); ++i)
		{
			delete props[i];
		}
		props = [];
	}
	
	static GetSplats = function()
	{
		gml_pragma("forceinline");
		return props;
	}
	static GetSplat = function(index)
	{
		gml_pragma("forceinline");
		return props[index];
	}
	static GetSplatCount = function()
	{
		gml_pragma("forceinline");
		return array_length(props);
	}
	
	static FindSplatIndex = function(prop)
	{
		if (prop._id == null)
		{
			return null;
		}
		for (var i = 0; i < array_length(props); ++i)
		{
			if (props[i]._id == prop._id)
			{
				return i;
			}
		}
		return null;
	}
	static AddSplat = function(prop)
	{
		if (FindSplatIndex(prop) == null)
		{
			prop._id = lastId++;
			array_push(props, prop);
		}
	}
	static RemoveSplat = function(prop)
	{
		var index = FindSplatIndex(prop);
		if (index != null)
		{
			array_delete(props, index, 1);
		}
	}
	
	/// @function SpawnSplats()
	/// @desc Spawns all splats instances so their meshes may rebuild.
	static SpawnSplats = function()
	{
		for (var splatIndex = 0; splatIndex < array_length(props); ++splatIndex)
		{
			var splat = props[splatIndex];
			
			var instance = inew(ob_splatter);
			instance.x = splat.x;
			instance.y = splat.y;
			instance.z = splat.z;
			
			instance.image_angle = splat.zrotation;
			instance.image_xscale = splat.xscale;
			instance.image_yscale = splat.yscale;
			
			instance.sprite_index = splat.sprite;
			instance.image_index = splat.index;
		}
	}
}
