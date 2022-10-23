//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vWorldPosition;

uniform vec4 uOutsideEdgeColor;
uniform vec4 uInsideEdgeColor;
uniform vec4 uInsideBaseColor;
uniform float uTime;

uniform vec4 uPositionParams;
uniform sampler2D textureEdgemask;

void main()
{
	vec2 edgemaskCoords = (v_vWorldPosition.xy - uPositionParams.xy) / uPositionParams.zw;
	vec4 pixelEdgemask = texture2D(textureEdgemask, edgemaskCoords);
	
	vec4 surfaceColor =
		(pixelEdgemask.x < 0.14)
			? ((pixelEdgemask.x < 0.07) ? uOutsideEdgeColor : uInsideEdgeColor) // Edges
			: uInsideBaseColor;
	
	// Now we do the basic time-based edge waves
	float wavePeturbedTime = uTime * 0.6 + ceil(sin(v_vWorldPosition.x * 0.053 * 0.25) * 2.0 + cos(v_vWorldPosition.y * 0.061 * 0.25) * 2.0);
	float waveTimeScroller = max(0.0, mod(wavePeturbedTime, 1.4) - 0.4);
	float waveScrollerTarget = pow(waveTimeScroller, 0.5) * 0.4;
	if (abs(pixelEdgemask.x - waveScrollerTarget) < 0.036)
	{
		surfaceColor = (waveTimeScroller < 0.5) ? uOutsideEdgeColor : uInsideEdgeColor;
	}
	
	gl_FragColor = surfaceColor;
}
