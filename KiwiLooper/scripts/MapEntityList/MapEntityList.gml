/// @function AEntityList() constructor
function AEntityList() constructor
{
	entities = [];
	
	static Clear = function()
	{
		for (var i = 0; i < GetEntityCount(); ++i)
		{
			idelete(entities[i]);
		}
		entities = [];
	}
	
	static GetEntities = function()
	{
		gml_pragma("forceinline");
		return entities;
	};
	static GetEntity = function(index)
	{
		gml_pragma("forceinline");
		return entities[index];
	};
	static GetEntityCount = function()
	{
		gml_pragma("forceinline");
		return array_length(entities);
	};
	
	static ReplaceEntity = function(index, newEnt)
	{
		gml_pragma("forceinline");
		entities[index] = newEnt;
	};
	
	static FindIndex = function(ent)
	{
		if (!iexists(ent))
		{
			return null;
		}
		for (var i = 0; i < array_length(entities); ++i)
		{
			if (entities[i].id == ent.id)
			{
				return i;
			}
		}
		return null;
	};
	static Add = function(ent)
	{
		assert(iexists(ent));
		if (FindIndex(ent) == null)
		{
			array_push(entities, ent);
		}
	};
	static Remove = function(ent)
	{
		var index = FindIndex(ent);
		if (index != null)
		{
			array_delete(entities, index, 1);
		}
	};
};