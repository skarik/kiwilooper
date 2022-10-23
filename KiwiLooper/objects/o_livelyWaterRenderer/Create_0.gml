/// @description Insert description here
// You can write your code in this editor

event_inherited();

WaterRenderer_Init();

update = function() 
{
	// TODO: defer this call until we're done updating everything? Should be fine on instantiation, since the waters are already delayed start.
	WaterRenderer_UpdateBodies();
	
	// Mark all the water's as updated now.
	with (o_livelyWater)
	{
		updated = true;
	}
}

m_renderEvent = function()
{
	WaterRenderer_RenderBodies();
}