/// @function AEditorGizmoEntityBillboards() constructor
/// @desc Editor gizmo for rendering all billboards for ents
function AEditorGizmoEntityBillboards() : AEditorGizmoBase() constructor
{
	x = 0;
	y = 0;
	z = 0;
	
#region Mesh building tools
	
	#macro kLMeshbBillboardOffset_Screen	0.0
	#macro kLMeshbBillboardOffset_World		1.0
	
	/// @function l_meshb_CreateBillboardVertexFormat()
	/// @desc Creates billboard vertex format.
	function l_meshb_CreateBillboardVertexFormat()
	{
		static format = null;
		if (format == null)
		{
			vertex_format_begin();
			{
				vertex_format_add_position_3d();
				vertex_format_add_color();
				vertex_format_add_texcoord();
				// xyz,type
				vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
			}
			format = vertex_format_end();
		}
		return format;
	}
	
	/// @function l_meshb_AddBillboardQuad(mesh, position, uvs, color, alpha, offsets[][])
	function l_meshb_AddBillboardQuad(mesh, position, uvs, color, alpha, offsets)
	{
		// 0
		meshb_VertexPushPosition(mesh, position);
		vertex_color(mesh, color, alpha);
		meshb_VertexPushTexcoord(mesh, (new Vector2(0.0, 0.0)).biasUVSelf(uvs));
		vertex_float4(mesh, offsets[0][0], offsets[0][1], offsets[0][2], offsets[0][3]);
	
		// 2
		meshb_VertexPushPosition(mesh, position);
		vertex_color(mesh, color, alpha);
		meshb_VertexPushTexcoord(mesh, (new Vector2(0.0, 1.0)).biasUVSelf(uvs));
		vertex_float4(mesh, offsets[2][0], offsets[2][1], offsets[2][2], offsets[2][3]);
	
		// 1
		meshb_VertexPushPosition(mesh, position);
		vertex_color(mesh, color, alpha);
		meshb_VertexPushTexcoord(mesh, (new Vector2(1.0, 0.0)).biasUVSelf(uvs));
		vertex_float4(mesh, offsets[1][0], offsets[1][1], offsets[1][2], offsets[1][3]);
	
	
		// 1
		meshb_VertexPushPosition(mesh, position);
		vertex_color(mesh, color, alpha);
		meshb_VertexPushTexcoord(mesh, (new Vector2(1.0, 0.0)).biasUVSelf(uvs));
		vertex_float4(mesh, offsets[1][0], offsets[1][1], offsets[1][2], offsets[1][3]);
		
		// 2
		meshb_VertexPushPosition(mesh, position);
		vertex_color(mesh, color, alpha);
		meshb_VertexPushTexcoord(mesh, (new Vector2(0.0, 1.0)).biasUVSelf(uvs));
		vertex_float4(mesh, offsets[2][0], offsets[2][1], offsets[2][2], offsets[2][3]);
		
		// 3
		meshb_VertexPushPosition(mesh, position);
		vertex_color(mesh, color, alpha);
		meshb_VertexPushTexcoord(mesh, (new Vector2(1.0, 1.0)).biasUVSelf(uvs));
		vertex_float4(mesh, offsets[3][0], offsets[3][1], offsets[3][2], offsets[3][3]);
	}
	
	function l_meshb_CreateEmptyMesh()
	{
		var mesh = meshb_Begin(l_meshb_CreateBillboardVertexFormat());
		repeat (3) // Start with a single triangle so rendering doesn't completely trip up
		{
			vertex_position_3d(mesh, 0.0, 0.0, 0.0);
			vertex_color(mesh, c_white, 1.0);
			vertex_texcoord(mesh, 0.0, 0.0);
			vertex_float4(mesh, 0.0, 0.0, 0.0, kLMeshbBillboardOffset_Screen);
		}
		meshb_End(mesh);
		return mesh;
	}
	
#endregion
	
	m_mesh = l_meshb_CreateEmptyMesh();
	m_dirty = true;
	
	/// @function Cleanup()
	/// @desc Cleans up the mesh used for rendering.
	Cleanup = function()
	{
		meshB_Cleanup(m_mesh);
	};
	
	/// @function Step()
	Step = function()
	{
		if (m_dirty)
		{
			meshb_BeginEdit(m_mesh, l_meshb_CreateBillboardVertexFormat());
		
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
				var entTypeInfo, entType, entSprite, entImageIndex, entGizmoType, entHullsize, entOrient, entProxyType;
				entTypeInfo = entlistIterationGet(entTypeIndex);
				entType			= entTypeInfo.objectIndex;
				entSprite		= entTypeInfo.gizmoSprite;
				entImageIndex	= entTypeInfo.gizmoIndex;
				entGizmoType	= entTypeInfo.gizmoDrawmode;
				entHullsize		= entTypeInfo.hullsize;
				entOrient		= entTypeInfo.gizmoOrigin;
				entProxyType	= entTypeInfo.proxy;
			
				if (entProxyType != kProxyTypeNone) continue; // Skip proxies
			
				// Get sprite info for this type
				var entSpriteWidth = sprite_get_width(entSprite) * 0.6;
				var entSpriteHeight = sprite_get_height(entSprite) * 0.6;
				var entUvs = sprite_get_uvs(entSprite, entImageIndex);
			
				// Count through the ents
				var entCount = instance_number(entType);
				for (var entIndex = 0; entIndex < entCount; ++entIndex)
				{
					var ent = instance_find(entType, entIndex);
					if (ent.object_index != entType) continue; // Skip invalid objects
				
					// Generate misc rendering info
					var entColor = GetEntColor(ent);
				
					// Generate center and other dimensions
					var entCenter = entGetSelectionCenter(ent, entOrient, new Vector3(entHullsize * 0.5 * ent.xscale, entHullsize * 0.5 * ent.yscale, entHullsize * 0.5 * ent.zscale));
				
					if (entGizmoType == kGizmoDrawmodeBillboard)
					{
						l_meshb_AddBillboardQuad(m_mesh, entCenter, entUvs, entColor, 1.0,
							[
								[entSpriteWidth * 0.5, -entSpriteHeight * 0.5, 0.0, kLMeshbBillboardOffset_Screen],
								[-entSpriteWidth * 0.5, -entSpriteHeight * 0.5, 0.0, kLMeshbBillboardOffset_Screen],
								[entSpriteWidth * 0.5, entSpriteHeight * 0.5, 0.0, kLMeshbBillboardOffset_Screen],
								[-entSpriteWidth * 0.5, entSpriteHeight * 0.5, 0.0, kLMeshbBillboardOffset_Screen],
							]);
					}
					else if (entGizmoType == kGizmoDrawmodeFlatsprite)
					{
						var center = entCenter.add(new Vector3(-entHullsize * 0.5 * ent.xscale, -entHullsize * 0.5 * ent.yscale, 0.0));
						for (var i = 0; i < 4; ++i)
						{
							var z_alpha = 1.0 * (1.0 - i / 4);
							var z_offset = i * 2;
							l_meshb_AddBillboardQuad(m_mesh, center, entUvs, entColor, z_alpha,
								[
									[0.0, 0.0, z_offset, kLMeshbBillboardOffset_World],
									[entHullsize * ent.xscale, 0.0, z_offset, kLMeshbBillboardOffset_World],
									[0.0, entHullsize * ent.yscale, z_offset, kLMeshbBillboardOffset_World],
									[entHullsize * ent.xscale, entHullsize * ent.yscale, z_offset, kLMeshbBillboardOffset_World],
								]);
						}
					}
				}
			}
		
			// Add proxies as well:
			var entCount = instance_number(m_editor.OProxyClass);
			for (var entIndex = 0; entIndex < entCount; ++entIndex)
			{
				var ent = instance_find(m_editor.OProxyClass, entIndex);
			
				// Get all the ent info now.
				var entTypeInfo, entType, entSprite, entImageIndex, entGizmoType, entHullsize, entOrient, entProxyType;
				entTypeInfo = ent.entity;
				entType			= entTypeInfo.objectIndex;
				entSprite		= entTypeInfo.gizmoSprite;
				entImageIndex	= entTypeInfo.gizmoIndex;
				entGizmoType	= entTypeInfo.gizmoDrawmode;
				entHullsize		= entTypeInfo.hullsize;
				entOrient		= entTypeInfo.gizmoOrigin;
				entProxyType	= entTypeInfo.proxy;
			
				if (entProxyType == kProxyTypeNone) continue; // Skip non-proxies
			
				// Get sprite info for this type
				var entSpriteWidth = sprite_get_width(entSprite) * 0.6;
				var entSpriteHeight = sprite_get_height(entSprite) * 0.6;
				var entUvs = sprite_get_uvs(entSprite, entImageIndex);
				var entColor = GetEntColor(ent);
			
				// Generate center and other dimensions
				var entCenter = entGetSelectionCenter(ent, entOrient, new Vector3(entHullsize * 0.5 * ent.xscale, entHullsize * 0.5 * ent.yscale, entHullsize * 0.5 * ent.zscale));
			
				if (entGizmoType == kGizmoDrawmodeBillboard)
				{
					l_meshb_AddBillboardQuad(m_mesh, entCenter, entUvs, entColor, 1.0,
							[
								[entSpriteWidth * 0.5, -entSpriteHeight * 0.5, 0.0, kLMeshbBillboardOffset_Screen],
								[-entSpriteWidth * 0.5, -entSpriteHeight * 0.5, 0.0, kLMeshbBillboardOffset_Screen],
								[entSpriteWidth * 0.5, entSpriteHeight * 0.5, 0.0, kLMeshbBillboardOffset_Screen],
								[-entSpriteWidth * 0.5, entSpriteHeight * 0.5, 0.0, kLMeshbBillboardOffset_Screen],
							]);
				}
				else if (entGizmoType == kGizmoDrawmodeFlatsprite)
				{
					var center = entCenter.add(new Vector3(-entHullsize * 0.5 * ent.xscale, -entHullsize * 0.5 * ent.yscale, 0.0));
					for (var i = 0; i < 4; ++i)
					{
						var z_alpha = 1.0 * (1.0 - i / 4);
						var z_offset = i * 2;
						l_meshb_AddBillboardQuad(m_mesh, center, entUvs, entColor, z_alpha,
							[
								[0.0, 0.0, z_offset, kLMeshbBillboardOffset_World],
								[entHullsize * ent.xscale, 0.0, z_offset, kLMeshbBillboardOffset_World],
								[0.0, entHullsize * ent.yscale, z_offset, kLMeshbBillboardOffset_World],
								[entHullsize * ent.xscale, entHullsize * ent.yscale, z_offset, kLMeshbBillboardOffset_World],
							]);
					}
				}
			}

			meshb_End(m_mesh);
			
			m_dirty = false;
		} // End dirty update
	}
	
	/// @function Draw()
	Draw = function()
	{
		var frontface_direction = Vector3FromArray(o_Camera3D.m_viewForward);
		var cross_x = frontface_direction.cross(Vector3FromArray(o_Camera3D.m_viewUp)).normalize();
		var cross_y = frontface_direction.cross(cross_x).normalize();
		var cross_z = cross_x.cross(cross_y).normalize();
		
		static uLookatVectors = shader_get_uniform(sh_editorEntBillboards, "uLookatVectors");
		drawShaderSet(sh_editorEntBillboards);
		shader_set_uniform_f_array(uLookatVectors, [
			cross_x.x, cross_x.y, cross_x.z, 0.0,
			cross_y.x, cross_y.y, cross_y.z, 0.0,
			cross_z.x, cross_z.y, cross_z.z, 0.0,
			 0.0, 0.0, 0.0, 0.0,
			]);
		vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
		drawShaderReset();
	}
}

/// @function AEditorGizmoEntityRenderObjects() constructor
/// @desc Editor gizmo for creating renderers for entities
function AEditorGizmoEntityRenderObjects() : AEditorGizmoBase() constructor
{
	x = 0;
	y = 0;
	z = 0;
	
	// Structure holding the renderer state
	static ARenderInfo = function(n_object, n_renderer) constructor
	{
		object		= n_object;
		renderer	= n_renderer;
		valid		= true;
		
		bHasLit				= variable_instance_exists(n_object, "lit");
		bHasTranslucency	= variable_instance_exists(n_object, "translucent");
		
		bHasEntTransform	= is_struct(n_object.entity.gizmoMesh) ? (variable_struct_exists(n_object.entity.gizmoMesh, "transform") && is_array(n_object.entity.gizmoMesh.transform)) : false;
		bHasLitOverride		= (is_struct(n_object.entity.gizmoMesh) && variable_struct_exists(n_object.entity.gizmoMesh, "litOverride")) ? true : false;
		bHasVisibilityCheck	= is_struct(n_object.entity.gizmoMesh) ? variable_struct_exists(n_object.entity.gizmoMesh, "whenVisible") : false;
	};
	
	rendermap = ds_map_create();
	renderlist = [];
	
	/// @function Cleanup()
	/// @desc Cleans up the lookup structures & items used for rendering
	Cleanup = function()
	{
		for (var i = 0; i < array_length(renderlist); ++i)
		{
			var renderInfo = renderlist[i];
			if (is_struct(renderInfo))
			{
				idelete(renderInfo.renderer);
				delete renderInfo;
			}
		}
		renderlist = [];
		ds_map_destroy(rendermap);
		rendermap = null;
	}
	
	
	/// @function Step()
	/// @desc Manages renderer instances, updates all the renderer transforms.
	Step = function()
	{
		// TODO: Can mark individual renderers dirty to skip anything that doesn't need the full update check.
		
		// Mark all renderers as unused for now
		CE_ArrayForEach(renderlist,
			function(renderInfo, index)
			{
				renderInfo.valid = false;
			});
		
		// Update renderers in entlist
		var entInstanceList = m_editor.m_entityInstList;
		for (var entIndex = 0; entIndex < entInstanceList.GetEntityCount(); ++entIndex)
		{
			var entInstance = entInstanceList.GetEntity(entIndex);
			// Skip if object does not exist
			if (entInstance == null || !iexists(entInstance))
				continue;
			
			// Skip if no mesh defined
			if (is_undefined(entInstance.entity.gizmoMesh) || !is_struct(entInstance.entity.gizmoMesh))
				continue;
			
			var renderInfo = rendermap[?entInstance];
			
			// Create a renderer if it does not exist
			if (!is_struct(renderInfo))
			{
				renderInfo = AddRendererForInstance(entInstance, entInstance.entity);
			}
			assert(is_struct(renderInfo));
			
			// Mark as used
			renderInfo.valid = true;
			
			// Update the transformation for the object
			renderInfo.renderer.x = entInstance.x;
			renderInfo.renderer.y = entInstance.y;
			renderInfo.renderer.z = entInstance.z;
			renderInfo.renderer.xscale = entInstance.xscale;
			renderInfo.renderer.yscale = entInstance.yscale;
			renderInfo.renderer.zscale = entInstance.zscale;
			renderInfo.renderer.xrotation = entInstance.xrotation;
			renderInfo.renderer.yrotation = entInstance.yrotation;
			renderInfo.renderer.zrotation = entInstance.zrotation;
			// Update the rendering properties
			if (renderInfo.bHasLit)
				renderInfo.renderer.lit = renderInfo.bHasLitOverride ? entInstance.entity.gizmoMesh.litOverride : entInstance.lit;
			if (renderInfo.bHasTranslucency)
				renderInfo.renderer.translucent = entInstance.translucent;
			if (renderInfo.bHasVisibilityCheck)
			{
				if (entInstance.entity.gizmoMesh.whenVisible == kGizmoMeshVisibleAlways)
					renderInfo.renderer.visible = true;
				else if (entInstance.entity.gizmoMesh.whenVisible == kGizmoMeshVisibleWhenSelected)
					renderInfo.renderer.visible = EditorSelectionContains(entInstance);
				else
					assert(false);
			}
			else
				renderInfo.renderer.visible = true;
			// Apply custom transforms
			if (renderInfo.bHasEntTransform)
			{
				var transforms = entInstance.entity.gizmoMesh.transform;
				for (var transformIndex = 0; transformIndex < array_length(transforms); ++transformIndex)
				{
					var transform = transforms[transformIndex];
					if (transform[0] == kGizmoMeshTransformTranslateX) renderInfo.renderer.x += transform[1];
					else if (transform[0] == kGizmoMeshTransformTranslateY) renderInfo.renderer.y += transform[1];
					else if (transform[0] == kGizmoMeshTransformTranslateZ) renderInfo.renderer.z += transform[1];
					else if (transform[0] == kGizmoMeshTransformScaleX) renderInfo.renderer.xscale *= transform[1];
					else if (transform[0] == kGizmoMeshTransformScaleY) renderInfo.renderer.yscale *= transform[1];
					else if (transform[0] == kGizmoMeshTransformScaleZ) renderInfo.renderer.zscale *= transform[1];
					else if (transform[0] == kGizmoMeshTransformRotateZ) renderInfo.renderer.zrotation += transform[1];
				}
			}
			
			// Renderer has been updated!
		}
		
		// Clean up all renderers that weren't used
		for (var i = 0; i < array_length(renderlist); ++i)
		{
			var renderInfo = renderlist[i];
			if (!is_struct(renderInfo))
			{
				array_delete(renderlist, i, 1);
				--i;
			}
			else if (!renderInfo.valid)
			{
				ds_map_delete(rendermap, renderInfo.object);
				array_delete(renderlist, i, 1);
				--i;
				
				idelete(renderInfo.renderer);
				delete renderInfo;
			}
		}
	}
	
	static AddRendererForInstance = function(inInstance, inEntity)
	{
		var new_renderer = inew(ob_3DObject);
		new_renderer.m_renderInstance = inInstance;
		new_renderer.m_renderEntity = inEntity;
		with (new_renderer)
		{
			// Create empty mesh
			m_mesh = meshb_Begin();
			meshb_AddQuad(m_mesh, [MBVertexDefault(), MBVertexDefault(), MBVertexDefault(), MBVertexDefault()]);
			meshb_End(m_mesh);
		}
		new_renderer.m_updateMesh = method(new_renderer, function()
		{
			/// @function entGetNormalizedCenterOffset(selection, orient)
			/// @desc Returns the selection center of the given object with given properties. This math is done often, so is made global.
			static entGetNormalizedCenterOffset = function(selection, orient)
			{
				gml_pragma("forceinline");
				return new Vector3(
					(orient == kGizmoOriginBottomCorner) ? 0.5 : 0,
					(orient == kGizmoOriginBottomCorner) ? 0.5 : 0,
					(orient == kGizmoOriginBottom || orient == kGizmoOriginBottomCorner) ? 0.5 : 0
					);
			}
			
			if (iexists(m_renderInstance)) // Check since we can sometimes delete the instance before the renderer has a chance to stop.
			{
				var entMesh			= m_renderEntity.gizmoMesh;
				assert(is_struct(entMesh));
				var entHullsize		= m_renderEntity.hullsize;
				var entOrigin		= m_renderEntity.gizmoOrigin;
				var entOffset		= entGetNormalizedCenterOffset(m_renderEntity, entOrigin);
					
				var uvs = sprite_get_uvs(entMesh.sprite, entMesh.index);
				var color = variable_struct_exists(entMesh, "color") ? entMesh.color : c_white;
				meshb_BeginEdit(m_mesh);
				if (entMesh.shape == kGizmoMeshShapeQuadWall)
				{
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3(0, -0.5,  0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3(0,  0.5,  0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3(0, -0.5, -0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
						new MBVertex((new Vector3(0,  0.5, -0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0))
						]);
				}
				else if (entMesh.shape == kGizmoMeshShapeQuadFloor)
				{
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3(-0.5, -0.5, 0)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3( 0.5, -0.5, 0)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3(-0.5,  0.5, 0)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3( 0.5,  0.5, 0)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1))
						]);
				}
				else if (entMesh.shape == kGizmoMeshShapeCube)
				{
					// Bottom
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3(-0.5,  0.5, -0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, -1)),
						new MBVertex((new Vector3( 0.5,  0.5, -0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, -1)),
						new MBVertex((new Vector3(-0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, -1)),
						new MBVertex((new Vector3( 0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, -1))
						]);
					// Top
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3(-0.5,  0.5,  0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3( 0.5,  0.5,  0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3(-0.5, -0.5,  0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3( 0.5, -0.5,  0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1))
						]);
						
					// Back (X)
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3(-0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(-1, 0, 0)),
						new MBVertex((new Vector3(-0.5,  0.5, -0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(-1, 0, 0)),
						new MBVertex((new Vector3(-0.5, -0.5,  0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(-1, 0, 0)),
						new MBVertex((new Vector3(-0.5,  0.5,  0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(-1, 0, 0))
						]);
					// Front (X)
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3( 0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(1, 0, 0)),
						new MBVertex((new Vector3( 0.5,  0.5, -0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(1, 0, 0)),
						new MBVertex((new Vector3( 0.5, -0.5,  0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(1, 0, 0)),
						new MBVertex((new Vector3( 0.5,  0.5,  0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(1, 0, 0))
						]);
						
					// Back (Y)
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3(-0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, -1, 0)),
						new MBVertex((new Vector3( 0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, -1, 0)),
						new MBVertex((new Vector3(-0.5, -0.5,  0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, -1, 0)),
						new MBVertex((new Vector3( 0.5, -0.5,  0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, -1, 0))
						]);
					// Front (Y)
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3(-0.5,  0.5, -0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
						new MBVertex((new Vector3( 0.5,  0.5, -0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
						new MBVertex((new Vector3(-0.5,  0.5,  0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
						new MBVertex((new Vector3( 0.5,  0.5,  0.5)).add(entOffset).multiply(entHullsize), color, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 1, 0))
						]);
				}
				else if (entMesh.shape == kGizmoMeshWireCube)
				{
					var xface_scale = min(1.0 / m_renderInstance.yscale, 1.0 / m_renderInstance.zscale) * 0.5;
					var yface_scale = min(1.0 / m_renderInstance.xscale, 1.0 / m_renderInstance.zscale) * 0.5;
					var zface_scale = min(1.0 / m_renderInstance.xscale, 1.0 / m_renderInstance.yscale) * 0.5;
					// Bottom
					MeshbAddLine3(m_mesh, color, 1.0, xface_scale, entHullsize, new Vector3(1, 0, 0), (new Vector3(-0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), uvs);
					MeshbAddLine3(m_mesh, color, 1.0, xface_scale, entHullsize, new Vector3(1, 0, 0), (new Vector3(-0.5,  0.5, -0.5)).add(entOffset).multiply(entHullsize), uvs);
					MeshbAddLine3(m_mesh, color, 1.0, yface_scale, entHullsize, new Vector3(0, 1, 0), (new Vector3(-0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), uvs);
					MeshbAddLine3(m_mesh, color, 1.0, yface_scale, entHullsize, new Vector3(0, 1, 0), (new Vector3( 0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), uvs);
					// Top
					MeshbAddLine3(m_mesh, color, 1.0, xface_scale, entHullsize, new Vector3(1, 0, 0), (new Vector3(-0.5, -0.5,  0.5)).add(entOffset).multiply(entHullsize), uvs);
					MeshbAddLine3(m_mesh, color, 1.0, xface_scale, entHullsize, new Vector3(1, 0, 0), (new Vector3(-0.5,  0.5,  0.5)).add(entOffset).multiply(entHullsize), uvs);
					MeshbAddLine3(m_mesh, color, 1.0, yface_scale, entHullsize, new Vector3(0, 1, 0), (new Vector3(-0.5, -0.5,  0.5)).add(entOffset).multiply(entHullsize), uvs);
					MeshbAddLine3(m_mesh, color, 1.0, yface_scale, entHullsize, new Vector3(0, 1, 0), (new Vector3( 0.5, -0.5,  0.5)).add(entOffset).multiply(entHullsize), uvs);
					// Connect
					MeshbAddLine3(m_mesh, color, 1.0, zface_scale, entHullsize, new Vector3(0, 0, 1), (new Vector3(-0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), uvs);
					MeshbAddLine3(m_mesh, color, 1.0, zface_scale, entHullsize, new Vector3(0, 0, 1), (new Vector3(-0.5,  0.5, -0.5)).add(entOffset).multiply(entHullsize), uvs);
					MeshbAddLine3(m_mesh, color, 1.0, zface_scale, entHullsize, new Vector3(0, 0, 1), (new Vector3( 0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), uvs);
					MeshbAddLine3(m_mesh, color, 1.0, zface_scale, entHullsize, new Vector3(0, 0, 1), (new Vector3( 0.5,  0.5, -0.5)).add(entOffset).multiply(entHullsize), uvs);
				}
				else if (entMesh.shape == kGizmoMeshLightSphere)
				{
					var radius = m_renderInstance.range;
					var color = m_renderInstance.color;
					// Add 3 arcs around the shape for the light
					MeshbAddArc3(m_mesh, color, 0.3, 0.5, radius, 0, 360, (360 / 16), new Vector3(1, 0, 0), new Vector3(0, 1, 0), new Vector3(0, 0, 0), uvs); 
					MeshbAddArc3(m_mesh, color, 0.3, 0.5, radius, 0, 360, (360 / 16), new Vector3(0, 1, 0), new Vector3(0, 0, 1), new Vector3(0, 0, 0), uvs);
					MeshbAddArc3(m_mesh, color, 0.3, 0.5, radius, 0, 360, (360 / 16), new Vector3(1, 0, 0), new Vector3(0, 0, 1), new Vector3(0, 0, 0), uvs);
				}
				else if (entMesh.shape == kGizmoMeshLightCone)
				{
					var radius = m_renderInstance.range;
					var color = m_renderInstance.color;
					var inner_angle = m_renderInstance.inner_angle;
					var outer_angle = m_renderInstance.outer_angle;
					
					// Add arcs for the light ending
					MeshbAddArc3(m_mesh, color, 0.1, 0.5, radius, -outer_angle, outer_angle, (outer_angle / 4), new Vector3(1, 0, 0), new Vector3(0, 1, 0), new Vector3(0, 0, 0), uvs);
					MeshbAddArc3(m_mesh, color, 0.1, 0.5, radius, -outer_angle, outer_angle, (outer_angle / 4), new Vector3(1, 0, 0), new Vector3(0, 0, 1), new Vector3(0, 0, 0), uvs);
					
					// Add arcs for outer
					MeshbAddArc3(m_mesh, color, 0.1, 0.5, radius * sin(degtorad(outer_angle)), 0, 360, (360 / 16), new Vector3(0, 1, 0), new Vector3(0, 0, 1), new Vector3(radius * cos(degtorad(outer_angle)), 0, 0), uvs);
					// Draw lines for outer
					MeshbAddLine3(m_mesh, color, 0.1, 0.5, radius, new Vector3(cos(degtorad(outer_angle)),  sin(degtorad(outer_angle)), 0), new Vector3(0, 0, 0), uvs);
					MeshbAddLine3(m_mesh, color, 0.1, 0.5, radius, new Vector3(cos(degtorad(outer_angle)), -sin(degtorad(outer_angle)), 0), new Vector3(0, 0, 0), uvs);
					MeshbAddLine3(m_mesh, color, 0.1, 0.5, radius, new Vector3(cos(degtorad(outer_angle)), 0,  sin(degtorad(outer_angle))), new Vector3(0, 0, 0), uvs);
					MeshbAddLine3(m_mesh, color, 0.1, 0.5, radius, new Vector3(cos(degtorad(outer_angle)), 0, -sin(degtorad(outer_angle))), new Vector3(0, 0, 0), uvs);
					
					// Add arcs for inner
					MeshbAddArc3(m_mesh, color, 0.3, 0.5, radius * sin(degtorad(inner_angle)), 0, 360, (360 / 16), new Vector3(0, 1, 0), new Vector3(0, 0, 1), new Vector3(radius * cos(degtorad(inner_angle)), 0, 0), uvs);
					// Draw lines for inner
					MeshbAddLine3(m_mesh, color, 0.3, 0.5, radius, new Vector3(cos(degtorad(inner_angle)),  sin(degtorad(inner_angle)), 0), new Vector3(0, 0, 0), uvs);
					MeshbAddLine3(m_mesh, color, 0.3, 0.5, radius, new Vector3(cos(degtorad(inner_angle)), -sin(degtorad(inner_angle)), 0), new Vector3(0, 0, 0), uvs);
					MeshbAddLine3(m_mesh, color, 0.3, 0.5, radius, new Vector3(cos(degtorad(inner_angle)), 0,  sin(degtorad(inner_angle))), new Vector3(0, 0, 0), uvs);
					MeshbAddLine3(m_mesh, color, 0.3, 0.5, radius, new Vector3(cos(degtorad(inner_angle)), 0, -sin(degtorad(inner_angle))), new Vector3(0, 0, 0), uvs);
				
				}
				else if (entMesh.shape == kGizmoMeshLightRect)
				{
					var radius = m_renderInstance.range;
					// TODO: each corner gets 2 arcs
					
					// Since this uses scaling, the actual math will get really funky - so for now let's not even bother with making this.
					
					var radius = m_renderInstance.range;
					var color = m_renderInstance.color;
					// Add 3 arcs around the shape for the light
					MeshbAddArc3(m_mesh, color, 0.3, 0.5, radius, 0, 360, (360 / 16), new Vector3(1, 0, 0), new Vector3(0, 1, 0), new Vector3(0, 0, 0), uvs); 
					MeshbAddArc3(m_mesh, color, 0.3, 0.5, radius, 0, 360, (360 / 16), new Vector3(0, 1, 0), new Vector3(0, 0, 1), new Vector3(0, 0, 0), uvs);
					MeshbAddArc3(m_mesh, color, 0.3, 0.5, radius, 0, 360, (360 / 16), new Vector3(1, 0, 0), new Vector3(0, 0, 1), new Vector3(0, 0, 0), uvs);
				}
				else
				{
					assert(false);
				}
				meshb_End(m_mesh);
			}
		});
		new_renderer.m_renderEvent = method(new_renderer, function()
		{
			if (iexists(m_renderInstance))
			{
				var entMesh = m_renderEntity.gizmoMesh;
				vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(entMesh.sprite, entMesh.index));
			}
		});
		new_renderer.m_updateMesh();
		
		// Create render info with our new renderer
		var renderInfo = new ARenderInfo(inInstance, new_renderer);
		
		// Add the render info to both the map & the list
		array_push(renderlist, renderInfo);
		rendermap[?inInstance] = renderInfo;
		
		// Return the newly created info for immediate use
		return renderInfo;
	}
	
	static RequestUpdate = function(forInstance)
	{
		var renderInfo = rendermap[?forInstance];
		if (is_struct(renderInfo))
		{
			renderInfo.renderer.m_updateMesh();
		}
	}
}