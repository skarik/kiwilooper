//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 uScissorRect;

void main()
{
	if (gl_FragCoord.x < uScissorRect.x || gl_FragCoord.x > uScissorRect.z
		|| gl_FragCoord.y < uScissorRect.y || gl_FragCoord.y > uScissorRect.w)
	{
		discard;
	}
    gl_FragColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
}
