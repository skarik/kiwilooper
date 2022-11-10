/// @description Execute

if (context == null || iexists(context) || is_struct(context))
{
	if (fn != null)
	{
		fn();
	}
}