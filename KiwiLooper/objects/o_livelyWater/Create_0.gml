/// @description Inherit and setup delayed render

#macro kFluidTypeWater	0
#macro kFluidTypeBlood	1

#macro kFluidSurfaceStill		0
#macro kFluidSurfaceSlowRunning	1
#macro kFluidSurfaceFastRunning	2

#macro kFluidEdgeX1	0x1		// X+
#macro kFluidEdgeX0 0x2		// X-
#macro kFluidEdgeY1	0x4		// Y+
#macro kFluidEdgeY0 0x8		// Y-

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
	}),
	id);


function DefineLocalFunctions()
{
	// Set up getters
	
	/// @function GetBBox()
	/// @desc Returns the BBox of the given object.
	GetBBox = function()
	{
		gml_pragma("forceinline");
		return new BBox3(Vector3FromTranslation(this), new Vector3(xscale * 0.5, yscale * 0.5, zscale * 0.5));
	}
}
DefineLocalFunctions();