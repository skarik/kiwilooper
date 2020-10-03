/// @func instance_nearest_notme(x,y,obj,n)
/// @param x
/// @param y
/// @param obj
function instance_nearest_notme(argument0, argument1, argument2) {
	{
	    var pointx, pointy, object, list, nearest;
	    pointx = argument0;
	    pointy = argument1;
	    object = argument2;
	    list = ds_priority_create();
	
	    nearest = noone;
	
	    with (object)
		{
			ds_priority_add(list, id, sqr(x - pointx) + sqr(y - pointy));
		}
	
	    nearest = ds_priority_delete_min(list);
		if (nearest == id)
		{
			nearest = ds_priority_delete_min(list);
		}
	
	    ds_priority_destroy(list);
	    return nearest;
	}



}
