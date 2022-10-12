
function executeNextStep(in_function, in_savedData = undefined, in_targetData = undefined)
{
	var executor = inew(_execute_step);
	executor = in_function;
	executor.saved_property_info = is_undefined(in_savedData) ? undefined : in_savedData;
	executor.target = is_undefined(in_targetData) ? id : in_targetData;
}