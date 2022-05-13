/// @function APropEntry() constructor
/// @desc Representation of a prop and their information.
function APropEntry() constructor
{
	// Indexer
	_id = null;
	static Id = function()
	{
		gml_pragma("forceinline");
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
	
	// Sprite
	index = 0;
	sprite = null;
}

/// @function APropMap() constructor
/// @desc Has a "map" of props.
function APropMap() constructor
{
	props = [];
	lastId = 0;
	
	static Clear = function()
	{
		for (var i = 0; i < GetPropCount(); ++i)
		{
			delete props[i];
		}
		props = [];
	}
	
	static GetProps = function()
	{
		gml_pragma("forceinline");
		return props;
	}
	static GetProp = function(index)
	{
		gml_pragma("forceinline");
		return props[index];
	}
	static GetPropCount = function()
	{
		gml_pragma("forceinline");
		return array_length(props);
	}
	
	static FindPropIndex = function(prop)
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
	static AddProp = function(prop)
	{
		if (FindPropIndex(prop) == null)
		{
			prop._id = lastId++;
			array_push(props, prop);
		}
	}
	static RemoveProp = function(prop)
	{
		var index = FindPropIndex(prop);
		if (index != null)
		{
			array_delete(props, index, 1);
		}
	}
	
	/// @function RebuildPropLayer(layerStorage)
	/// @desc Rebuilds the "prop" asset layer with the given prop information.
	///		The layer created will be added into the layerStorage argument.
	static RebuildPropLayer = function(layerStorage)
	{
		var newPropsLayer = layer_create(49, "props");
		if (is_array(layerStorage))
		{
			array_push(layerStorage, newPropsLayer);
		}
		
		for (var propIndex = 0; propIndex < array_length(props); ++propIndex)
		{
			var prop = props[propIndex];
			
			var asset = layer_sprite_create(newPropsLayer, prop.x, prop.y, prop.sprite);
			layer_sprite_angle(asset, prop.zrotation);
			layer_sprite_xscale(asset, prop.xscale);
			layer_sprite_yscale(asset, prop.yscale);
		}
	}
}
