//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;

uniform vec4 uPositionParams;
//uniform sampler2D textureScrollTextures;

vec4 edgeKillSample(sampler2D textureSampler, vec2 coord)
{
	if (coord.x < 0.0 || coord.y < 0.0
		|| coord.x > 1.0 || coord.y > 1.0)
	{
		return vec4(0, 0, 0, 1);
	}
	else return texture2D(textureSampler, coord);
}

void main()
{
	vec2 pixelStepOffset = vec2(1.0 / uPositionParams.z, 1.0 / uPositionParams.w);
	
	vec4 pixelSurface = texture2D( gm_BaseTexture, v_vTexcoord );
	
	vec3 outputColor = pixelSurface.rgb;
	if (pixelSurface.r > 0.5)
	{
		// If we're white, we want to find the distance to the nearest black
		
		// Search in all directions
		float kMaxDist = 16.0;
		for (float dist = 1.0; dist < kMaxDist; dist += 1.0)
		{
			vec4 testSample =
			min(
				min(
					min(
						edgeKillSample(gm_BaseTexture, v_vTexcoord + vec2(-pixelStepOffset.x, 0) * dist),
						edgeKillSample(gm_BaseTexture, v_vTexcoord + vec2(-pixelStepOffset.x, -pixelStepOffset.y) * 0.707 * dist)),
					min(
						edgeKillSample(gm_BaseTexture, v_vTexcoord + vec2(pixelStepOffset.x, 0) * dist),
						edgeKillSample(gm_BaseTexture, v_vTexcoord + vec2(pixelStepOffset.x, -pixelStepOffset.y) * 0.707 * dist))
					),
				min(
					min(
						edgeKillSample(gm_BaseTexture, v_vTexcoord + vec2(0, -pixelStepOffset.y) * dist),
						edgeKillSample(gm_BaseTexture, v_vTexcoord + vec2(-pixelStepOffset.x, pixelStepOffset.y) * 0.707 * dist)),
					min(
						edgeKillSample(gm_BaseTexture, v_vTexcoord + vec2(0, pixelStepOffset.y) * dist),
						edgeKillSample(gm_BaseTexture, v_vTexcoord + vec2(pixelStepOffset.x, pixelStepOffset.y) * 0.707 * dist))
					)
				);
				
			if (testSample.r < 0.5)
			{
				//outputColor = vec3(1.0, 1.0, 1.0) / dist;
				outputColor = vec3(1.0, 1.0, 1.0) * (dist / kMaxDist);
				break;
			}
		}
	}
	
	gl_FragColor = vec4(outputColor, 1.0);
}
