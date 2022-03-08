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
		meshb_BeginEdit(m_mesh);
		
		static GetEntColor = function(entity)
		{
			if (entity.object_index == ob_3DLight
				|| entity.object_index == o_ambientOverride)
			{
				return entity.color;
			}
			else if (entity.object_index == m_editor.OProxyClass)
			{
				return c_white; // TODO for specific entity types
			}
			else
			{
				return c_white;
			}
		};

		// Add all non-proxy entities:
		for (var entTypeIndex = 0; entTypeIndex < entlistIterationLength(); ++entTypeIndex)
		{
			var entTypeInfo, entType, entSprite, entImageIndex, entGizmoType, entHullsize, entOrient;
			entTypeInfo = entlistIterationGet(entTypeIndex);
			entType			= entTypeInfo.objectIndex;
			entSprite		= entTypeInfo.gizmoSprite;
			entImageIndex	= entTypeInfo.gizmoIndex;
			entGizmoType	= entTypeInfo.gizmoDrawmode;
			entHullsize		= entTypeInfo.hullsize;
			entOrient		= entTypeInfo.gizmoOrigin;
			
			// Get sprite info for this type
			var entSpriteWidth = max(entHullsize, sprite_get_width(entSprite) * 0.6);
			var entSpriteHeight = max(entHullsize, sprite_get_height(entSprite) * 0.6);
			var entUvs = sprite_get_uvs(entSprite, entImageIndex);
			
			// Count through the ents
			var entCount = instance_number(entType);
			for (var entIndex = 0; entIndex < entCount; ++entIndex)
			{
				var ent = instance_find(entType, entIndex);
				
				// Generate misc rendering info
				var entColor = GetEntColor(ent);
				
				// Generate center and other dimensions
				var entCenter = new Vector3(ent.x, ent.y, ent.z);
				if (entOrient == kGizmoOriginBottom)
					entCenter.z += entHullsize * 0.5; // todo: factor in scalez if available
				
				if (entGizmoType == kGizmoDrawmodeBillboard)
				{
					MeshbAddBillboardUVs(m_mesh, entColor, entSpriteWidth, entSpriteHeight, entUvs, new Vector3(0,0,1), entCenter);
				}
				else if (entGizmoType == kGizmoDrawmodeFlatsprite)
				{
					// TODO
				}
			}
		}
		
		// Add proxies as well:
		var entCount = instance_number(m_editor.OProxyClass);
		for (var entIndex = 0; entIndex < entCount; ++entIndex)
		{
			var ent = instance_find(m_editor.OProxyClass, entIndex);
			
			// Get all the ent info now.
			var entTypeInfo, entType, entSprite, entImageIndex, entGizmoType, entHullsize, entOrient;
			entTypeInfo = ent.entity;
			entType			= entTypeInfo.objectIndex;
			entSprite		= entTypeInfo.gizmoSprite;
			entImageIndex	= entTypeInfo.gizmoIndex;
			entGizmoType	= entTypeInfo.gizmoDrawmode;
			entHullsize		= entTypeInfo.hullsize;
			entOrient		= entTypeInfo.gizmoOrigin;
			
			// Get sprite info for this type
			var entSpriteWidth = max(entHullsize, sprite_get_width(entSprite) * 0.6);
			var entSpriteHeight = max(entHullsize, sprite_get_height(entSprite) * 0.6);
			var entUvs = sprite_get_uvs(entSprite, entImageIndex);
			var entColor = GetEntColor(ent);
			
			// Generate center and other dimensions
			var entCenter = new Vector3(ent.x, ent.y, ent.z);
			if (entOrient == kGizmoOriginBottom)
				entCenter.z += entHullsize * 0.5 * ent.zscale;
			
			if (entGizmoType == kGizmoDrawmodeBillboard)
			{
				MeshbAddBillboardUVs(m_mesh, entColor, entSpriteWidth, entSpriteHeight, entUvs, new Vector3(0,0,1), entCenter);
			}
			else if (entGizmoType == kGizmoDrawmodeFlatsprite)
			{
				for (var i = 0; i < 4; ++i)
				{
					MeshbAddQuadUVs(
						m_mesh, entColor, 1.0 * (1.0 - i/4),
						new Vector3(entHullsize * ent.xscale, 0, 0),
						new Vector3(0, entHullsize * ent.yscale, 0),
						entUvs,
						entCenter.add(new Vector3(-entHullsize * 0.5 * ent.xscale, -entHullsize * 0.5 * ent.yscale, i * 2))
						);
				}
			}
		}

		meshb_End(m_mesh);
	}
	
	Draw = function()
	{
		vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
	}
}