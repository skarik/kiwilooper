function SplatFindAssetByName(name)
{
	var splats = tag_get_asset_ids("splats", asset_sprite);
	for (var i = 0; i < array_length(splats); ++i)
	{
		var splatSprite = splats[i];
		
		if (string_pos(name, sprite_get_name(splatSprite)) != 0)
		{
			return splatSprite;
		}
	}
	return null;
}

/// @function SplatGetBBox(splat)
function SplatGetBBox(splat)
{
	var width = sprite_get_width(splat.sprite) ;
	var height = sprite_get_height(splat.sprite);
	var deepness = min(width, height) * splat.zscale;
	
	width *= splat.xscale;
	height *= splat.yscale;
	deepness *= splat.zscale;
	
	return new BBox3(
		new Vector3(0, 0, 0),
		new Vector3(width * 0.5, height * 0.5, deepness * 0.5)
		);
}
