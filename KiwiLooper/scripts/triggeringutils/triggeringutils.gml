/// @function instanceIsDoor(instance)
/// @param instance {Instance}
function instanceIsDoor(instance)
{
	gml_pragma("forceinline");
	return instance.object_index == o_livelyDoor || object_is_ancestor(instance.object_index, o_livelyDoor);
}

/// @function instanceIsLivelyEffect(instance)
/// @param instance {Instance}
function instanceIsLivelyEffect(instance)
{
	return instance.object_index == ob_livelyEffect || object_is_ancestor(instance.object_index, ob_livelyEffect);
}

/// @function livelyIsTriggered(object)
/// @param object {Instance}
function livelyIsTriggered(object)
{
	gml_pragma("forceinline");
	if (instanceIsDoor(object))
	{
		return object.opening || object.openstate >= 0.5;
	}
}

/// @function livelyIsDeactivated(object)
/// @param object {Instance}
function livelyIsDeactivated(object)
{
	gml_pragma("forceinline");
	if (instanceIsDoor(object))
	{
		return object.closing || object.openstate < 0.5;
	}
}

/// @function livelyTriggerActivate(object, caller)
/// @param object {Instance}
/// @param caller {Instance}
function livelyTriggerActivate(object, caller)
{
	gml_pragma("forceinline");
	if (instanceIsDoor(object))
	{
		object.m_onActivation(caller);
	}
	else if (instanceIsLivelyEffect(object))
	{
		object.m_onActivation(caller);
	}
}

/// @function livelyTriggerDeactivate(object, caller)
/// @param object {Instance}
/// @param caller {Instance}
function livelyTriggerDeactivate(object, caller)
{
	gml_pragma("forceinline");
	if (instanceIsDoor(object))
	{
		object.m_onActivation(caller);
	}
}