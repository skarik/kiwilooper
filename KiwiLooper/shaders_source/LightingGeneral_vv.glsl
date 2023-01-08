//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, 1.0, 1.0);
	vec4 v_vScreenPosition = object_space_pos;
    gl_Position = v_vScreenPosition;
    v_vColour = in_Colour;
}
