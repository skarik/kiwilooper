//
// Simple passthrough fragment shader
//
#extension GL_OES_standard_derivatives : enable

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vPosition;

uniform vec4 uLineColor;
// X: line size
uniform vec4 uLineSizeAndFade;

void main()
{
	// Half the line size:
	float kLineSize = uLineSizeAndFade.x;
	
	vec2 deltaPixelUV_X = dFdx(v_vTexcoord);
	vec2 deltaPixelUV_Y = dFdy(v_vTexcoord);
	
	// Get the max size of a pixel in the U or V direction (we don't care about the screen X or Y)
	vec2 deltaPixelUV_Max = max(abs(deltaPixelUV_X), abs(deltaPixelUV_Y));
	// Multiply by line so we have a modded delta to check against
	deltaPixelUV_Max *= kLineSize;
	
	// If we're beyond the size of the line, don't render.
	if ((  abs(v_vTexcoord.x)		> deltaPixelUV_Max.x
		&& abs(v_vTexcoord.x - 1.0)	> deltaPixelUV_Max.x
		&& abs(v_vTexcoord.y)		> deltaPixelUV_Max.y
		&& abs(v_vTexcoord.y - 1.0)	> deltaPixelUV_Max.y)
		// Probably a better way to do this, but here for clarity, not smarts
		|| v_vTexcoord.x < 0.0-deltaPixelUV_Max.x || v_vTexcoord.x > 1.0+deltaPixelUV_Max.x
		|| v_vTexcoord.y < 0.0-deltaPixelUV_Max.y || v_vTexcoord.y > 1.0+deltaPixelUV_Max.y)
	{
		discard;
	}
	
	// Still here, set final color
	gl_FragColor = v_vColour * uLineColor;
}
