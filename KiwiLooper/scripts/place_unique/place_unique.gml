function place_unique(argument0, argument1, argument2) {
	if ( !position_meeting(argument0,argument1,argument2) )
	{
	    return instance_create_layer(argument0,argument1,layer,argument2);
	}
	return null;


}
