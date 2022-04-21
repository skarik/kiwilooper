function EditorProxyObject_Init()
{
	static OProxyClass = o_EditorProxy;
	id.OProxyClass = OProxyClass;
}

function ProxyClass()
{
	if (iexists(EditorGet()))
	{
		return EditorGet().OProxyClass;
	}
	else
	{
		return o_EditorProxy;
	}
}

function EmptyFunction(){};

function EditorEntities_SetupCallbacks()
{
	with (EditorGet())
	{
		var entInstanceList = m_entityInstList;
		for (var entIndex = 0; entIndex < entInstanceList.GetEntityCount(); ++entIndex)
		{
			var entInstance = entInstanceList.GetEntity(entIndex);
			
			if (!variable_instance_exists(entInstance, "onEditorStep"))
			{
				entInstance.onEditorStep = EmptyFunction;
			}
		}
	}
}

function EditorEntities_RunCallbacks()
{
	with (EditorGet())
	{
		var entInstanceList = m_entityInstList;
		for (var entIndex = 0; entIndex < entInstanceList.GetEntityCount(); ++entIndex)
		{
			var entInstance = entInstanceList.GetEntity(entIndex);
			entInstance.onEditorStep();
		}
	}
}
