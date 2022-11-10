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

/// @function ATaskRunner() constructor
function ATaskRunner() constructor
{
	_tasks = [];
	_perTaskTimeLimit = -1;
	_taskIndex = 0;
	_runner = null;
	
	static addTask = function(taskToRun)
	{
		array_push(_tasks, taskToRun);
		return self;
	}
	
	/// @param timeLimit {Real} microseconds to limit each step to
	static execute = function(timeLimit = -1)
	{
		_perTaskTimeLimit = timeLimit;
		
		_taskIndex = 0;
		
		// begin executing now prolly
		stepUpdate();
		
		// Are we done? If not, not make a runner.
		if (!isDone())
		{
			_runner = inew(_execute_step_nodelete);
			_runner.fn = method(self, stepUpdate);
			_runner.context = self;
			_runner.persistent = true;
		}
	}
	
	static isDone = function()
	{
		return _taskIndex >= array_length(_tasks);
	}
	
	static stop = function()
	{
		idelete(_runner);
		_runner = null;
	}
	
	static stepUpdate = function()
	{
		var bTimedOut = false;
		
		var startTime = get_timer();
		while (_taskIndex < array_length(_tasks) && !bTimedOut)
		{
			// Run task
			_tasks[_taskIndex]();
			
			// Go to next task
			_taskIndex++;
			
			// Check if task timed out
			if (_perTaskTimeLimit >= 0)
			{
				var currentTime = get_timer();
				bTimedOut = (currentTime - startTime > _perTaskTimeLimit);
			}
		}
		
		// clean up runner once we're done
		if (isDone())
		{
			idelete(_runner);
			_runner = null;
		}
	}
}