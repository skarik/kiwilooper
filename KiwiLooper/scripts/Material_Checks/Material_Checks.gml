#macro kMaterialType_Metal			0
#macro kMaterialType_WaterWaist		1
#macro kMaterialType_WaterPuddle	2

function Material_BelowPosition(x, y, z)
{
	return kMaterialType_Metal;
}