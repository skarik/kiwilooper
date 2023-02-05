//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
	vec4 pixelColor = texture2D( gm_BaseTexture, v_vTexcoord );
	float pixelBrightness = dot(vec3(0.299, 0.587, 0.114), pixelColor.rgb);
	
	gl_FragColor.rgb = mix(vec3(0.0, 0.0, 0.0), v_vColour.rgb, pixelBrightness);
	gl_FragColor.a = v_vColour.a * pixelColor.a;
}
