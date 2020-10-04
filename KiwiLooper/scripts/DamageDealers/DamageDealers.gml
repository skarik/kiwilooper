#macro kDamageTypeBlunt		0x0001
#macro kDamageTypeUnarmed	0x0002
#macro kDamageTypePiercing	0x0004
#macro kDamageTypeFire		0x0010
#macro kDamageTypeAcid		0x0020
#macro kDamageTypeShock		0x0040
#macro kDamageTypeTar		0x0100
#macro kDamageTypeRift		0x0200
#macro kDamageTypeBite		0x0400
#macro kDamageTypeBullet	0x0800
#macro kDamageTypeMagic		0x1000
#macro kDamageTypeMagicVoid	(0x1000 | 0x2000)
#macro kDamageTypeCounter	0x4000

function damageCanHit(source, target)
{
	if (!iexists(source))
	{
		return true;
	}
	else if (!iexists(target))
	{
		return false;
	}
	else if (source.id == target.id)
	{
		return false;
	}
	return true;
}

function damageTarget(source, target, damage, damageType, source_x, source_y)
{
	if (damageCanHit(source, target))
	{
		target.hp -= damage;
		target.lastDamageType = damageType;
		
		if (damageType == kDamageTypeBlunt)
		{
			sound_play_at(x, y, z, "sound/phys/hit_metal2.wav");
		}
	}
}

function damageHitbox(source, x1, y1, x2, y2, damage, damageType)
{
	// For debug purposes, draw the bounding box of the hitbox
	if (Debug.on)
	{
		debugBox(x1, y1, x2, y2, c_gray);
	}
	
	var hit_list = ds_list_create();
	var hit_list_count;
	
	// Check hits against characters first
	hit_list_count = collision_rectangle_list(x1, y1, x2, y2, ob_character, true, true, hit_list, false);
	for (var i = 0; i < hit_list_count; ++i)
	{
		var hit_target = hit_list[|i];
		damageTarget(source, hit_target, damage, damageType, x, y);
	}
	
	
	ds_list_destroy(hit_list);
}