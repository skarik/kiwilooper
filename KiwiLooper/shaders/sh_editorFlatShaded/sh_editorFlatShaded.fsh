//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vPosition;

uniform vec4 uFlatColor;

void main()
{
	// Still here, set final color
	gl_FragColor = v_vColour * uFlatColor;
}
