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
			var entSpriteWidth = sprite_get_width(entSprite) * 0.6;
			var entSpriteHeight = sprite_get_height(entSprite) * 0.6;
			var entUvs = sprite_get_uvs(entSprite, entImageIndex);
			
			// Count through the ents
			var entCount = instance_number(entType);
			for (var entIndex = 0; entIndex < entCount; ++entIndex)
			{
				var ent = instance_find(entType, entIndex);
				
				// Generate misc rendering info
				var entColor = GetEntColor(ent);
				
				// Generate center and other dimensions
				var entCenter = entGetSelectionCenter(ent, entOrient, new Vector3(entHullsize * 0.5 * ent.xscale, entHullsize * 0.5 * ent.yscale, entHullsize * 0.5 * ent.zscale));
				
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
			var entSpriteWidth = sprite_get_width(entSprite) * 0.6;
			var entSpriteHeight = sprite_get_height(entSprite) * 0.6;
			var entUvs = sprite_get_uvs(entSprite, entImageIndex);
			var entColor = GetEntColor(ent);
			
			// Generate center and other dimensions
			var entCenter = entGetSelectionCenter(ent, entOrient, new Vector3(entHullsize * 0.5 * ent.xscale, entHullsize * 0.5 * ent.yscale, entHullsize * 0.5 * ent.zscale));
			
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
				renderInfo.renderer.lit = entInstance.lit;
			if (renderInfo.bHasTranslucency)
				renderInfo.renderer.translucent = entInstance.translucent;
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
				meshb_BeginEdit(m_mesh);
				if (entMesh.shape == kGizmoMeshShapeQuadWall)
				{
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3(0, -0.5,  0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3(0,  0.5,  0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3(0, -0.5, -0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
						new MBVertex((new Vector3(0,  0.5, -0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0))
						]);
				}
				else if (entMesh.shape == kGizmoMeshShapeQuadFloor)
				{
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3(-0.5, -0.5, 0)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3( 0.5, -0.5, 0)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3(-0.5,  0.5, 0)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3( 0.5,  0.5, 0)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1))
						]);
				}
				else if (entMesh.shape == kGizmoMeshShapeCube)
				{
					// Bottom
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3(-0.5,  0.5, -0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, -1)),
						new MBVertex((new Vector3( 0.5,  0.5, -0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, -1)),
						new MBVertex((new Vector3(-0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, -1)),
						new MBVertex((new Vector3( 0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, -1))
						]);
					// Top
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3(-0.5,  0.5,  0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3( 0.5,  0.5,  0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3(-0.5, -0.5,  0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
						new MBVertex((new Vector3( 0.5, -0.5,  0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1))
						]);
						
					// Back (X)
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3(-0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(-1, 0, 0)),
						new MBVertex((new Vector3(-0.5,  0.5, -0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(-1, 0, 0)),
						new MBVertex((new Vector3(-0.5, -0.5,  0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(-1, 0, 0)),
						new MBVertex((new Vector3(-0.5,  0.5,  0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(-1, 0, 0))
						]);
					// Front (X)
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3( 0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(1, 0, 0)),
						new MBVertex((new Vector3( 0.5,  0.5, -0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(1, 0, 0)),
						new MBVertex((new Vector3( 0.5, -0.5,  0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(1, 0, 0)),
						new MBVertex((new Vector3( 0.5,  0.5,  0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(1, 0, 0))
						]);
						
					// Back (Y)
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3(-0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, -1, 0)),
						new MBVertex((new Vector3( 0.5, -0.5, -0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, -1, 0)),
						new MBVertex((new Vector3(-0.5, -0.5,  0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, -1, 0)),
						new MBVertex((new Vector3( 0.5, -0.5,  0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, -1, 0))
						]);
					// Front (Y)
					meshb_AddQuad(m_mesh, [
						new MBVertex((new Vector3(-0.5,  0.5, -0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
						new MBVertex((new Vector3( 0.5,  0.5, -0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
						new MBVertex((new Vector3(-0.5,  0.5,  0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
						new MBVertex((new Vector3( 0.5,  0.5,  0.5)).add(entOffset).multiply(entHullsize), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 1, 0))
						]);
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
}