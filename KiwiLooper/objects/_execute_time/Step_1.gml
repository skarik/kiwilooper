/// @description Execute & delete self

time -= Time.deltaTime;
if (time <= 0)
{
	if (iexists(context) || is_struct(context))
	{
		if (fn != null)
		{
			fn();
		}
	}
	instance_destroy();
}