/// @description Inherit and setup delayed render

#macro kFluidTypeWater	0
#macro kFluidTypeBlood	1

event_inherited();

updated = false;

// Create renderer
if (!iexists(o_livelyWaterRenderer))
{
	inew(o_livelyWaterRenderer);
}

// Delay call fluid renderer mesh update
executeNextStep(method(id,function()
{
	if (!updated)
	{
		o_livelyWaterRenderer.update();
		updated = true;
	}
}));