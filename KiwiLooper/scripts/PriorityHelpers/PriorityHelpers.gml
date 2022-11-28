function ASinglePriorityMin() constructor
{
	bHasData = false;
	priority = undefined;
	value = undefined;
	
	static cleanup = function() {}; // Nothing.
	
	static add = function(n_value, n_priority)
	{
		if (!bHasData || (n_priority < priority))
		{
			value = n_value;
			priority = n_priority;
			bHasData = true;
		}
	}
	
	static size = function()
	{
		return bHasData ? 1 : 0;
	}
	
	static getMinimum = function()
	{
		return value;
	}
	static deleteMinimum = function() {}; // Nothing.
}


function APriorityWrapper() constructor
{
	structure = ds_priority_create();
	
	static cleanup = function()
	{
		ds_priority_destroy(structure);
	}
	
	static add = function(n_value, n_priority)
	{
		ds_priority_add(structure, n_value, n_priority);
	}
	
	static size = function()
	{
		return ds_priority_size(structure);
	}
	
	static getMinimum = function()
	{
		return ds_priority_find_min(structure);
	}
	static deleteMinimum = function()
	{
		return ds_priority_delete_min(structure);
	}
}