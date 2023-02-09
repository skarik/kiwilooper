//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;

uniform float uStrength;

void main()
{
	// These colors are special to the style
	vec4 abberateLeft	= vec4(0.125, 0.75, 0.75, 1.0);
	vec4 abberateRight	= vec4(0.87, 0.161, 0.854, 1.0);
	
	vec4 leftColor	= texture2D( gm_BaseTexture, v_vTexcoord - vec2(uStrength, 0) );
	vec4 rightColor	= texture2D( gm_BaseTexture, v_vTexcoord + vec2(uStrength, 0) );
	vec4 baseColor	= texture2D( gm_BaseTexture, v_vTexcoord );
	
	vec4 finalColor = baseColor;
	finalColor = max(finalColor, leftColor * abberateLeft);
	finalColor = max(finalColor, rightColor * abberateRight);
		
    gl_FragColor = finalColor;
}
