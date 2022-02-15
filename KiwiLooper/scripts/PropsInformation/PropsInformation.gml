#macro kPropBuildstyleNone 0
#macro kPropBuildstyleStandingQuad 1
#macro kPropBuildstyleCubic 2
#macro kPropBuildstyleFloorQuad 3

function PropGetBuildstyle( prop_sprite )
{
	switch (prop_sprite)
	{
	case spr_metalBoard:
	case spr_metalScreen0:
	case spr_metalBottleStanding0:
	case spr_metalBody1:
		return kPropBuildstyleStandingQuad;
			
	case spr_metalTable0:
	case spr_metalTable1:
	case spr_metalLocker0:
	case spr_metalCrate0:
		return kPropBuildstyleCubic;
			
	default:
		return kPropBuildstyleFloorQuad;
	}
	return kPropBuildstyleNone;
}

function PropGetZHeight( prop_sprite )
{
	// Just going to hard-code the heights of props to avoid fiddling with the UV tools
	switch (prop_sprite)
	{
	case spr_metalTable0:
	case spr_metalTable1:
		return 6;
		break;
	case spr_metalCrate0: break; // Nothing needed to change here!
	}
	return sprite_get_height(prop_sprite);
}

function PropGetYHeight( prop_sprite )
{
	// Just going to hard-code the heights of props to avoid fiddling with the UV tools
	switch (prop_sprite)
	{
	case spr_metalLocker0:
		return 12;
		break;
	case spr_metalCrate0: break; // Nothing needed to change here!
	}
	return sprite_get_height(prop_sprite);
}

function PropGetBBox( prop_sprite )
{
	var buildstyle = PropGetBuildstyle(prop_sprite);
	assert(buildstyle != kPropBuildstyleNone);
	
	var element_width = sprite_get_width(prop_sprite);
	var element_height = sprite_get_height(prop_sprite);
	
	switch (buildstyle)
	{
	case kPropBuildstyleStandingQuad:
		return new BBox3(
			new Vector3(0, 0, element_height * 0.5),
			new Vector3(element_width * 0.5, 4.0 * 0.5, element_height * 0.5)
			);
			
	case kPropBuildstyleCubic:
		return new BBox3(
			new Vector3(0, 0, PropGetZHeight(prop_sprite) * 0.5),
			new Vector3(element_width * 0.5, element_height * 0.5, PropGetZHeight(prop_sprite) * 0.5)
			);
			
		
	case kPropBuildstyleFloorQuad:
		return new BBox3(
			new Vector3(0, 0, 1.0 * 0.5),
			new Vector3(element_width * 0.5, element_height * 0.5, 1.0 * 0.5)
			);
	}
	
	return new BBox3(null, null); // Should crash here.
}

function PropFindAssetByName(name)
{
	var props = tag_get_asset_ids("objects", asset_sprite);
	for (var i = 0; i < array_length(props); ++i)
	{
		var propSprite = props[i];
		
		if (string_pos(name, sprite_get_name(propSprite)) != 0)
		{
			return propSprite;
		}
	}
	return null;
}