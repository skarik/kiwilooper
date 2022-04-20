//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, 1.0, 1.0);
	vec4 v_vScreenPosition = object_space_pos;
	//vec4 v_vScreenPosition = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
		// TODO: make sure the lights render as a screen quad when inside
		//v_vScreenPosition.z = max(0, v_vScreenPosition.z);
		//v_vScreenPosition.w = max(0, v_vScreenPosition.w);
		//
    gl_Position = v_vScreenPosition;
    
    v_vColour = in_Colour;
}
