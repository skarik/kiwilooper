function AState() constructor
{
	static onRun = function(params) {}
	static onBegin = function() {}
	static onEnd = function() {}
	
	_machine = null;
	static transitionTo = function(StateType)
	{
		_machine.transitionTo(StateType);
	}
}


function AStateMachine() constructor
{
	states = [];
	current_state = null;
	
	static run = function(param)
	{
		if (current_state != null)
		{
			states[current_state].instance.onRun(param);
		}
	}
	
	static runContext = function(context, param)
	{
		if (current_state != null)
		{
			method(context, states[current_state].instance.onRun)(param);
		}
	}
	
	static addState = function(StateType)
	{
		var new_state_instance = new StateType();
		new_state_instance._machine = self;
		
		array_push(
			states,
			{
				type: StateType,
				instance: new_state_instance,
			});
			
		return self;
	}
	
	static getState = function(StateType)
	{
		for (var i = 0; i < array_length(states); ++i)
		{
			if (states[i].type == StateType)
			{
				return states[i].instance;
			}
		}
		return undefined;
	}
	
	static getCurrentState = function()
	{
		if (current_state != null)
		{
			return states[current_state].type;
		}
		return undefined;
	}
	
	static transitionTo = function(StateType)
	{
		// Call ending on current state
		if (current_state != null)
		{
			states[current_state].instance.onEnd();
		}
		
		// Find new state
		current_state = null;
		for (var i = 0; i < array_length(states); ++i)
		{
			if (states[i].type == StateType)
			{
				current_state = i;
				break;
			}
		}
		
		// Call begin on new state
		if (current_state != null)
		{
			states[current_state].instance.onBegin();
		}
		
		return self;
	}
}