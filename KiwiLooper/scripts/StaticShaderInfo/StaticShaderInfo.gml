function SetupStaticShaderInfo()
{
	global.su_unlitColormask = shaderGetUniforms(sh_unlitColormask,
	[
		"uColor",
	]);
}

gml_pragma("global", "SetupStaticShaderInfo()");
