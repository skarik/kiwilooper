///@desc Deferred surface lighting. Starts off with the ambient lighting.

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 uLightAmbientColor;
uniform mat4 uInverseViewProjection;
uniform vec4 uCameraInfo;
uniform vec4 uViewInfo;

uniform sampler2D textureAlbedo;
uniform sampler2D textureNormal;
uniform sampler2D textureIllum;
uniform sampler2D textureDepth;

vec2 encode_to_r8g8( float value )
{
	float low_prec = floor(value * 255.0) / 255.0;
	float high_prec = (value - low_prec) * 255.0;
	return vec2(low_prec, high_prec);
}

float decode_from_r8g8( vec2 value )
{
	return value.x + value.y / 255.0;
}

vec3 calculate_world_position( float depth )
{
	// Start with view coords
	vec4 viewCoords = vec4(
		(gl_FragCoord.x / uViewInfo.x - 0.5) * 2.0,
		(gl_FragCoord.y / uViewInfo.y - 0.5) * -2.0,
		depth,
		1.0);
		
	// Transform to world coords
	vec4 worldCoords = uInverseViewProjection * viewCoords;
	worldCoords.xyz = worldCoords.xyz / worldCoords.w;
	
	return worldCoords.xyz;
}

void main()
{
	// use gl_FragCoord to sample the textures. Render in 3D space
	
	vec4 baseAlbedo = texture2D( textureAlbedo, v_vTexcoord );
	if (baseAlbedo.a < 0.5) discard;
	
	vec4 baseNormal = texture2D( textureNormal, v_vTexcoord );
	vec4 baseDepth  = texture2D( textureDepth,  v_vTexcoord );
	vec4 baseIllum  = texture2D( textureIllum,  v_vTexcoord );
	
	vec3	pixelNormal		= baseNormal.xyz * 2.0 - 1.0;
	float	pixelDepth		= decode_from_r8g8(baseDepth.rg);
	vec3	pixelPosition	= calculate_world_position(pixelDepth);
	
	vec3 totalLighting = uLightAmbientColor.rgb + baseIllum.rgb;
	
	gl_FragData[0] = vec4(clamp(totalLighting, 0.0, 1.2), 1.0) * baseAlbedo;
	gl_FragData[0].a = 1.0;
}
