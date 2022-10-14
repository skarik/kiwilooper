/// @function executeNextStep(func, context)
function executeNextStep(in_function, in_context)
{
	var executor = inew(_execute_step);
	executor.fn = in_function;
	executor.context = in_context;
	return executor;
}

/// @function executeDelay(func, time, context)
function executeDelay(in_function, in_time, in_context)
{
	var executor = inew(_execute_time);
	executor.fn = in_function;
	executor.time = in_time; 
	executor.context = in_context;
	return executor;
}