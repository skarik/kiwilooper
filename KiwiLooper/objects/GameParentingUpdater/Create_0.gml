/// @description Limit to one instance
if (instance_number(object_index) > 1)
{
	show_error("More than one GameParentingUpdater exists.", false);
	idelete(this);
}