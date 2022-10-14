/// @function executeNextStep(func, [data], [target])
function executeNextStep(in_function, in_savedData = undefined, in_targetData = undefined)
{
	var executor = inew(_execute_step);
	executor.fn = in_function;
	executor.saved_property_info = is_undefined(in_savedData) ? undefined : in_savedData;
	executor.target = is_undefined(in_targetData) ? id : in_targetData;
}

/// @function executeDelay(func, time, context)
function executeDelay(in_function, in_time, in_context)
{
	var executor = inew(_execute_step);
	executor.fn = in_function;
	executor.time = in_time; 
	executor.context = in_context;
}