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

uniform vec4 uWaterSheetUVs;
uniform sampler2D textureWaterSheet;

float mod289(float x)
{
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec2 mod289(vec2 x)
{
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec3 mod289(vec3 x)
{
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec4 mod289(vec4 x)
{
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float permute(float x)
{
	return mod289(((x*34.0)+10.0)*x);
}
vec2 permute(vec2 x)
{
	return mod289(((x*34.0)+10.0)*x);
}
vec3 permute(vec3 x)
{
	return mod289(((x*34.0)+10.0)*x);
}
vec4 permute(vec4 x)
{
	return mod289(((x*34.0)+10.0)*x);
}

/// Sample the water sheet texture from 0 to 1
vec4 sampleWaterSheet(vec2 uvs)
{
	return texture2D(textureWaterSheet, vec2(mix(uWaterSheetUVs.x, uWaterSheetUVs.z, uvs.x), mix(uWaterSheetUVs.y, uWaterSheetUVs.w, uvs.y)));
}

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
	
	// Now for tile bombing!
	vec2 uv_scaled = v_vWorldPosition.xy / 16.0;
	vec2	cell = floor(uv_scaled);
	vec2	cell_position = uv_scaled - cell;
	for (int i_celX = -1; i_celX <= 0; ++i_celX)
	{
		for (int i_celY = -1; i_celY <= 0; ++i_celY)
		{
			vec2	l_cell = cell + vec2(i_celX, i_celY);
			vec2	l_cell_position = cell_position - vec2(i_celX, i_celY);
			
			// Grab four random values
			vec2 random_input = l_cell * vec2(0.037, 0.119) * 100.0;
			vec4 random_base = fract(permute( vec4(
				mod289(random_input.x + mod289(random_input.y)),
				mod289(random_input.y + mod289(random_input.x)),
				random_input.x + mod289(random_input.y),
				random_input.y + mod289(random_input.x)
			) ));
			
			// todo
			
			vec2	uv_random_rebased = l_cell_position - random_base.xy;
			
			/*if (abs(length( uv_random_rebased - vec2(0.5, 0.5) ) - 0.2) < 0.01)
			{
				surfaceColor = uOutsideEdgeColor;
			}*/
			
			// Animate the sheet:
			float sheetOffset = floor(mod(uTime * 15.0 + random_base.z * 40.0, 40.0));
			
			vec2 uv_waterSheet = uv_random_rebased * 2.0 - vec2(1.0, 1.0);
			// If sheet is in range...
			if (uv_waterSheet.x >= 0.0 && uv_waterSheet.x <= 1.0
				&& uv_waterSheet.y >= 0.0 && uv_waterSheet.y <= 1.0
				&& sheetOffset < 8.0)
			{
				// Sample sheet!
				vec4 pixelWaterSheet = sampleWaterSheet(uv_waterSheet / 8.0 + vec2(sheetOffset / 8.0, 0));
				vec4 mixColor = (pixelWaterSheet.r < 0.25) ? uOutsideEdgeColor : ((pixelWaterSheet.r < 0.60) ? uInsideEdgeColor : ((pixelWaterSheet.r < 0.90) ? uInsideBaseColor : vec4(0, 0, 0, 0)));
				
				surfaceColor = mix(surfaceColor, mixColor, mixColor.a);
			}
			//surfaceColor = pixelWaterSheet;
			
		}
	}
	
	gl_FragColor = surfaceColor;
}
