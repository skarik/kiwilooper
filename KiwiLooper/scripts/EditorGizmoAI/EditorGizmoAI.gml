/// @function AEditorGizmoAiMap() constructor
/// @desc Editor gizmo for rendering all billboards for ents
function AEditorGizmoAiMap() : AEditorGizmoBase() constructor
{
	x = 0;
	y = 0;
	z = 0;
	
	m_mesh = meshb_CreateEmptyMesh();
	
	/// @function Cleanup()
	/// @desc Cleans up the mesh used for rendering.
	Cleanup = function()
	{
		meshB_Cleanup(m_mesh);
	};
	
	Step = function()
	{
		UpdateMesh();
	}
	
	Draw = function()
	{
		var last_shader = drawShaderGet();
		
		drawShaderSet(sh_editorLineEdge);
		shader_set_uniform_f(global.m_editorLineEdge_uLineSizeAndFade, 0.5, 0, 0, 0);
		shader_set_uniform_f(global.m_editorLineEdge_uLineColor, 1.0, 1.0, 1.0, 1.0);
		
		vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
		
		drawShaderSet(last_shader);
	}
	
	static UpdateMesh = function()
	{
		meshb_BeginEdit(m_mesh);
	
		var ai_map = m_editor.m_aimap;
		
		// Loop through each node and add a line for their connection
		for (var iNode = 0; iNode < array_length(ai_map.nodes); ++iNode)
		{
			var node = ai_map.nodes[iNode];
			for (var iConnection = 0; iConnection < array_length(node.connections); ++iConnection)
			{
				var connection = node.connections[iConnection];
				
				var position_delta = connection.node.position.subtract(node.position);
				var position_delta_len = position_delta.magnitude();
				
				MeshbAddLine(m_mesh, c_yellow, 1.0, position_delta_len, position_delta.divide(position_delta_len), node.position);
			}
		}
	
		meshb_End(m_mesh);
	}
}