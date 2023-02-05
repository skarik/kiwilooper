//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;			// (x,y,z)
attribute vec4 in_Colour;			// (r,g,b,a)
attribute vec2 in_TextureCoord;		// (u,v)
attribute vec4 in_Offset;			// (x,y,z,t)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform mat4 uLookatVectors;

void main()
{
	vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	vec4 world_space_pos = gm_Matrices[MATRIX_WORLD] * object_space_pos;
	
	int offset_type = int(in_Offset.w);
	// Screen offset
	if (offset_type == 0)
	{
		world_space_pos.xyz += 
			  uLookatVectors[0].xyz * in_Offset.x
			+ uLookatVectors[1].xyz * in_Offset.y
			+ uLookatVectors[2].xyz * in_Offset.z;
	}
	// World offset
	else if (offset_type == 1)
	{
		world_space_pos.xyz += in_Offset.xyz;
	}
	
	vec4 view_space_pos = gm_Matrices[MATRIX_VIEW] * world_space_pos;
	gl_Position = gm_Matrices[MATRIX_PROJECTION] * view_space_pos;

	v_vColour = in_Colour;
	v_vTexcoord = in_TextureCoord;
}
