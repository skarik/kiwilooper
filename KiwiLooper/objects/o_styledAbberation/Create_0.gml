/// @description set up abberation

if (singleton_this()) exit;

depth = -8998;
persistent = true;

// temp surface buffer
m_abberationBuffer = null;
m_strength = 0.0;

m_uStrength = shader_get_uniform(sh_stylizedAbberation, "uStrength");