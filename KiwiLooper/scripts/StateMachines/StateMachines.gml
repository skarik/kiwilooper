/// @function AState() struct;
/// @desc A base class for states for AStateMachine's.
///		Inherit from this for your own states.
function AState() constructor
{
	static onRun = function(params) {}
	static onBegin = function() {}
	static onEnd = function() {}
	
	_machine = null;
	/// @function transitionTo(StateType)
	/// @desc Tries to transition the associated state machine to the given StateType.
	static transitionTo = function(StateType)
	{
		_machine.transitionTo(StateType);
	}
}

/// @function AStateMachine() struct;
/// @desc A straightforward state machine.
function AStateMachine() constructor
{
	states = [];
	current_state = null;
	
	current_context = null;
	
	/// @function run(param)
	/// @param {Any} param
	/// @desc Runs the state machine. Commonly used with the GM Step event.
	static run = function(param)
	{
		if (current_state != null)
		{
			states[current_state].instance.onRun(param);
		}
	}
	
	/// @function runContext(context, param)
	/// @param {Struct/Object} context
	/// @param {Any} param
	/// @desc Runs the state machine. Commonly used with the GM Step event.
	///		Context can be used to run the state as if part of another object.
	static runContext = function(context, param)
	{
		current_context = context;
		if (current_state != null)
		{
			method(context, states[current_state].instance.onRun)(param);
		}
	}
	
	/// @function addState(StateType)
	/// @desc Adds a type of state to the machine.
	///		For any state to be able to be traveled to, it must be added first.
	/// @returns {self}
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
	
	/// @function getState(StateType)
	/// @desc If the StateType exists in the machine, will return that instance.
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
	
	/// @function getCurrentState()
	/// @desc Returns type of the currently running state.
	static getCurrentState = function()
	{
		if (current_state != null)
		{
			return states[current_state].type;
		}
		return undefined;
	}
	
	/// @function transitionTo(StateType)
	/// @desc Tries to transition the state machine to the given StateType.
	/// @returns {self}
	static transitionTo = function(StateType)
	{
		// Call ending on current state
		if (current_state != null)
		{
			if (current_context == null)
				states[current_state].instance.onEnd();
			else
				method(current_context, states[current_state].instance.onEnd)();
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
			if (current_context == null)
				states[current_state].instance.onBegin();
			else
				method(current_context, states[current_state].instance.onBegin)();
		}
		// Show invalid state types
		else
		{
			debugLog(kLogError, "Could not transition to state type " + string(StateType) + "!");
		}
		
		return self;
	}
}