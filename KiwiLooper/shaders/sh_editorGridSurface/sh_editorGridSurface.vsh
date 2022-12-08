//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;                    // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vNormal;
varying vec3 v_vPosition;
varying vec4 v_vScreenPosition;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	v_vScreenPosition = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
	gl_Position = v_vScreenPosition;
	
	v_vPosition = (gm_Matrices[MATRIX_WORLD] * object_space_pos).xyz;
	v_vNormal = mat3(gm_Matrices[MATRIX_WORLD]) * in_Normal;
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}
