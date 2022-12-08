//
// Simple passthrough fragment shader
//
#extension GL_OES_standard_derivatives : enable

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vPosition;
varying vec4 v_vScreenPosition;

// Grid info
//	x - Grid size
//	y - Big div size
//	z - Enable skip
uniform vec4 uGridInfo;

// Grid colors
uniform vec4 uGridColorCenter; // recommend default: vec4(1.0, 1.0, 1.0, 0.5)
uniform vec4 uGridColorBigDiv; // recommend default: vec4(0.5, 0.8, 0.8, 0.5)
uniform vec4 uGridColorNormal; // recommend default: vec4(0.5, 0.5, 0.5, 0.5)

// Samplers
uniform sampler2D textureSkip;

void main()
{
	// Skip if outside of the solid
	if (   v_vTexcoord.x < 0.0 || v_vTexcoord.x > 1.0
		|| v_vTexcoord.y < 0.0 || v_vTexcoord.y > 1.0)
	{
		discard;
	}
	
	// Skip if we have texture skipping enabled
	if (uGridInfo.z > 0.5)
	{
		vec2 coordSkip = v_vScreenPosition.xy / v_vScreenPosition.w;
		coordSkip.y = -coordSkip.y;
		
		vec4 sampleSkip = texture2D(textureSkip, coordSkip * 0.5 + vec2(0.5, 0.5));
		if (sampleSkip.x > 0.5)
		{
			discard;
		}
	}
	
	// Take our position and flatten it against our normal face
	vec3 face_side	= normalize(cross(v_vNormal, (v_vNormal.z > 0.95) ? vec3(0, -1, 0) : vec3(0, 0, 1)));
	vec3 face_up	= normalize(-cross(v_vNormal, -face_side));
	vec2 face_flatten = vec2(dot(v_vPosition.xyz, face_side), dot(v_vPosition.xyz, face_up));
	
	// Find our deltas so we can make sure grid stays constant width
	vec2 deltaPixel_X = dFdx(face_flatten);
	vec2 deltaPixel_Y = dFdy(face_flatten);
	vec2 deltaPixel_Max = max(abs(deltaPixel_X), abs(deltaPixel_Y));
	
	// Create our grid positions
	vec2 position_repeat = mod(face_flatten, uGridInfo.x);
	vec2 position_repeatBig = mod(face_flatten, uGridInfo.y);
	
	if (abs(face_flatten.x) < deltaPixel_Max.x * 2.0 || abs(face_flatten.y) < deltaPixel_Max.y * 2.0)
	{
		gl_FragColor = uGridColorCenter;
	}
	else if (position_repeatBig.x < deltaPixel_Max.x * 2.0 || position_repeatBig.y < deltaPixel_Max.y * 2.0)
	{
		gl_FragColor = uGridColorBigDiv;
	}
	else if (position_repeat.x < deltaPixel_Max.x * 1.0 || position_repeat.y < deltaPixel_Max.y * 1.0)
	{
		gl_FragColor = uGridColorNormal;
	}
	else
	{
		discard;
	}
}
