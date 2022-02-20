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