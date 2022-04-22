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

function EditorEntity_SetupCallback(entInstance)
{
	if (!variable_instance_exists(entInstance, "onEditorStep"))
	{
		entInstance.onEditorStep = EmptyFunction;
	}
	
	entInstance.onEditorDrawGizmo_Exists = variable_instance_exists(entInstance, "onEditorDrawGizmo");
}

function EditorEntities_SetupCallbacks()
{
	with (EditorGet())
	{
		var entInstanceList = m_entityInstList;
		for (var entIndex = 0; entIndex < entInstanceList.GetEntityCount(); ++entIndex)
		{
			var entInstance = entInstanceList.GetEntity(entIndex);
			EditorEntity_SetupCallback(entInstance);
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
