//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 uColor;

void main()
{
	float alpha = v_vColour.a * texture2D( gm_BaseTexture, v_vTexcoord ).a;
	if (alpha <= gm_AlphaRefValue)
		discard;
		
    gl_FragColor = uColor;
}
