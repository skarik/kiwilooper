/// @description Set up base calls

m_onActivation = function(caller)
{
	var spark = inew(o_envFxSpark);
		spark.x = x;
		spark.y = y;
		spark.z = z;
		spark.xrotation = xrotation;
		spark.yrotation = yrotation;
		spark.zrotation = zrotation;
}

onEditorPreviewBegin = function()
{
	m_onActivation();
}