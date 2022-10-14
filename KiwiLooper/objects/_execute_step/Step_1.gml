/// @description Execute & delete self

if (context == null || iexists(context) || is_struct(context))
{
	if (fn != null)
	{
		fn();
	}
}
instance_destroy();