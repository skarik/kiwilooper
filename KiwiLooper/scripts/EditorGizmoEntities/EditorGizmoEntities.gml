/// @function AEditorGizmoEntityBillboards() constructor
/// @desc Editor gizmo for rendering all billboards for ents
function AEditorGizmoEntityBillboards() : AEditorGizmoBase() constructor
{
	x = 0;
	y = 0;
	z = 0;
	
	m_mesh = meshb_Begin();
	meshb_End(m_mesh);
	
	/// @function Cleanup()
	/// @desc Cleans up the mesh used for rendering.
	Cleanup = function()
	{
		meshB_Cleanup(m_mesh);
	};
	
	Step = function()
	{
		//var kScreensizeFactor = CalculateScreensizeFactor();
		
		meshb_BeginEdit(m_mesh);

		for (var entTypeIndex = 0; entTypeIndex < array_length(m_editor.m_entList); ++entTypeIndex)
		{
			var entTypeInfo = m_editor.m_entList[entTypeIndex];
			var entType = entTypeInfo[0];
			var entSprite = entTypeInfo[1];
			var entImageIndex = entTypeInfo[2];
			
			// Get sprite info for this type
			var entSpriteWidth = sprite_get_width(entSprite) * 0.6;// * kScreensizeFactor * 0.5;
			var entSpriteHeight = sprite_get_height(entSprite) * 0.6;// * kScreensizeFactor * 0.5;
			var entUvs = sprite_get_uvs(entSprite, entImageIndex);
			
			// Count through the ents
			var entCount = instance_number(entType);
			for (var entIndex = 0; entIndex < entCount; ++entIndex)
			{
				var ent = instance_find(entType, entIndex);
				entColor = c_white;
				
				MeshbAddBillboardUVs(m_mesh, entColor, entSpriteWidth, entSpriteHeight, entUvs, new Vector3(0,0,1), new Vector3(ent.x, ent.y, ent.z));
			}
		}

		meshb_End(m_mesh);
	}
	
	Draw = function()
	{
		vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
	}
}