function AWaterRenderBody() constructor
{
	entities = [];
	z = 0;
	minBox = new Vector3(0, 0, 0);
	maxBox = new Vector3(0, 0, 0);
	topdownSize = new Vector2(0, 0);
	
	mesh = null; // Mesh used for rendering
	
	static updateMinMax = function() 
	{
		// Set arbitrary defaults
		if (array_length(entities) > 0)
		{
			z = entities[0].z;
			minBox.x = entities[0].x;
			minBox.y = entities[0].y;
			maxBox.x = entities[0].x;
			maxBox.y = entities[0].y;
		}
		
		// Loop through all entities and build the mins & maxes based on their reported BBoxs
		for (var entityIndex = 0; entityIndex < array_length(entities); ++entityIndex)
		{
			var entityCheckBBox = entities[entityIndex].GetBBox();
			z = max(z, entityCheckBBox.center.z + entityCheckBBox.extents.z);
			
			minBox.x = min(minBox.x, entityCheckBBox.center.x - entityCheckBBox.extents.x);
			minBox.y = min(minBox.y, entityCheckBBox.center.y - entityCheckBBox.extents.y);
			
			maxBox.x = max(maxBox.x, entityCheckBBox.center.x + entityCheckBBox.extents.x);
			maxBox.y = max(maxBox.y, entityCheckBBox.center.y + entityCheckBBox.extents.y);
		}
		
		// Update the top-down size that the surface texture will be using
		topdownSize.x = maxBox.x - minBox.x;
		topdownSize.y = maxBox.y - minBox.y;
	}
	
	static hasOverlappingEntityBBox = function(bbox)
	{
		for (var entityIndex = 0; entityIndex < array_length(entities); ++entityIndex)
		{
			var entityCheckBBox = entities[entityIndex].GetBBox();
			if (bbox.overlaps(entityCheckBBox))
			{
				return true;
			}
		}
		return false;
	}
	
	static hasOverlappingEntityBBox2 = function(otherBody)
	{
		for (var entityIndex = 0; entityIndex < array_length(entities); ++entityIndex)
		{
			var entityCheckBBox = entities[entityIndex].GetBBox();
			if (otherBody.hasOverlappingEntityBBox(entityCheckBBox))
			{
				return true;
			}
		}
		return false;
	}
}


function WaterRenderer_Init()
{
	bodies = [];
}

function WaterRenderer_ClearBodies()
{
	for (var i = 0; i < array_length(bodies); ++i)
	{
		delete bodies[i];
	}
	bodies = [];
}

function WaterRenderer_Cleanup()
{
	WaterRenderer_ClearBodies();
}

function WaterRenderer_FindOverlappingBody(bbox)
{
	for (var bodyIndex = 0; bodyIndex < array_length(bodies); ++bodyIndex)
	{
		var currentBody = bodies[bodyIndex];
		
		if (currentBody.hasOverlappingEntityBBox(bbox))
		{
			return currentBody;
		}
	}
	return undefined;
}

function WaterRenderer_UpdateBodies()
{
	// Clear out our current bodies
	WaterRenderer_ClearBodies();
	
	var waterEntityCount = instance_number(o_livelyWater);
	for (var waterEntityIndex = 0; waterEntityIndex < waterEntityCount; ++waterEntityIndex)
	{
		var waterEntity = instance_find(o_livelyWater, waterEntityIndex);
		
		// Get the water's BBox
		var waterBBox = waterEntity.GetBBox();
		
		// Find a body that matches
		var overlappingBody = WaterRenderer_FindOverlappingBody(waterBBox);
		if (!is_undefined(overlappingBody))
		{
			// Add this to it.
			array_push(overlappingBody.entities, waterEntity);
		}
		else
		{
			// Create a new body that we have to manage
			var newBody = new AWaterRenderBody();
			array_push(newBody.entities, waterEntity);
			
			// Save the new body
			array_push(bodies, newBody);
		}
	}
	
	// Now combine all bodies (should be 2-pass eventually to catch any super complicated bodies. even with that, it's not complete)
	for (var bodyIndex = 0; bodyIndex < array_length(bodies); ++bodyIndex)
	{
		for (var otherBodyIndex = bodyIndex + 1; otherBodyIndex < array_length(bodies); ++otherBodyIndex)
		{
			if (bodies[bodyIndex].hasOverlappingEntityBBox2(bodies[otherBodyIndex]))
			{
				// Add the ents to the new boi
				bodies[bodyIndex].entities = CE_ArrayMerge(bodies[bodyIndex].entities, bodies[otherBodyIndex].entities);
				
				// Skip and check next body.
				--otherBodyIndex;
				continue;
			}
		}
	}
	
	// Now find the min-max of the bodies
	for (var bodyIndex = 0; bodyIndex < array_length(bodies); ++bodyIndex)
	{
		bodies[bodyIndex].updateMinMax();
	}
	
	// Now we want to create meshes
	WaterRenderer_CreateMeshes();
}

function WaterRenderer_CreateMeshes()
{
	for (var bodyIndex = 0; bodyIndex < array_length(bodies); ++bodyIndex)
	{
		WaterRenderer_CreateMesh(bodies[bodyIndex]);
	}
}

function WaterRenderer_CreateMesh(body)
{
	// Loop across each edge and generate either a solid line or a wobbly boi.
	global.water_EdgeOffset = 6;
	
	// Start with a mesh
	body.mesh = meshb_Begin();
	
	// On our initial pass, we assume each edge is a hard edge
	for (var entityIndex = 0; entityIndex < array_length(body.entities); ++entityIndex)
	{
		var entity = body.entities[entityIndex];
		var bbox = entity.GetBBox();
		
		// Set up a lookup table for the edges. We specify counterclockwise for our triangle-fan
		static s_kEdgeLookupTable = [
			//EdgeBitmask	MinEdgeBitmask	MaxEdgeBitmask
			[kFluidEdgeX1,	kFluidEdgeY0,	kFluidEdgeY1],
			[kFluidEdgeY1,	kFluidEdgeX1,	kFluidEdgeX0],
			[kFluidEdgeX0,	kFluidEdgeY1,	kFluidEdgeY0],
			[kFluidEdgeY0,	kFluidEdgeX0,	kFluidEdgeX1],
		];
		
		// (Can actually easily recreate this - there's a pattern)
		static s_getCorner = function(bbox, bitmask, hardEdgeMask)
		{
			var kEdgeOffset = global.water_EdgeOffset; // keep in sync w/ calculateEdgePosition
			return new Vector2(
				bbox.center.x + ((bitmask & kFluidEdgeX0) ? -1.0 : 1.0) * (bbox.extents.x - ((hardEdgeMask & bitmask & (kFluidEdgeX0|kFluidEdgeX1)) ? 0.0 : kEdgeOffset)),
				bbox.center.y + ((bitmask & kFluidEdgeY0) ? -1.0 : 1.0) * (bbox.extents.y - ((hardEdgeMask & bitmask & (kFluidEdgeY0|kFluidEdgeY1)) ? 0.0 : kEdgeOffset))
				);
		}
		
		// Cache the center
		var entMeshCenter = new Vector3(bbox.center.x, bbox.center.y, body.z);
		var entMeshColor = c_white;
		var entMeshUp = new Vector3(0, 0, 1.0);
		var entHardEdge = entity.hardEdgeMask;
		
		// Build the mesh via a triangle fan, going along the edges
		for (var edgeIndex = 0; edgeIndex < 4; ++edgeIndex)
		{
			var edgeLookup = s_kEdgeLookupTable[edgeIndex];
			
			var minCorner = s_getCorner(bbox, edgeLookup[0] | edgeLookup[1], entHardEdge);
			var maxCorner = s_getCorner(bbox, edgeLookup[0] | edgeLookup[2], entHardEdge);
			
			var segmentCount = max(2, ceil(minCorner.subtract(maxCorner).magnitude() / 8));
			
			/// @function calculateSegmentPosition(percent, edgeStart, edgeEnd, edge, hardEdge)
			/// @desc Calculates a position on the edge.
			static calculateEdgePosition = function(percent, minCorner, maxCorner, edge, hardEdge)
			{
				if (hardEdge)
				{
					return minCorner.linearlerp(maxCorner, percent);
				}
				else
				{
					var kEdgeOffset = global.water_EdgeOffset; // keep in sync w/ s_getCorner
					
					var edgeDelta = maxCorner.subtract(minCorner);
					var edgeLength = edgeDelta.magnitude();
					var edgeCross = new Vector2(edgeDelta.y / edgeLength, -edgeDelta.x / edgeLength);
					
					// Now we scale the peturb down at the beginning and end
					var peturbScale =
						min((percent - 0.0) * edgeLength,
							(1.0 - percent) * edgeLength);
					peturbScale = min(1.0, peturbScale);
					
					// Create our regular peturb now
					peturbSize = 0.5 + 0.25 * sin(percent * edgeLength * 0.115 + minCorner.x + minCorner.y) + 0.25 * sin(percent * edgeLength * 0.067 + maxCorner.x + maxCorner.y);
					
					// TODO: peturb in a perpendicular direciton to the corner distances
					return minCorner.linearlerp(maxCorner, percent).add(edgeCross.multiply(peturbScale * kEdgeOffset * peturbSize));
				}
			}
			
			// Build the triangle fan by steping through the segments:
			var segmentStart;
			var segmentEnd = calculateEdgePosition(0, minCorner, maxCorner, edgeLookup[0], edgeLookup[0] & entHardEdge);
			for (var segmentIndex = 0; segmentIndex < segmentCount; ++segmentIndex)
			{
				// Calculate min & max for the segment
				segmentStart = segmentEnd;
				segmentEnd = calculateEdgePosition((segmentIndex + 1)/ segmentCount, minCorner, maxCorner, edgeLookup[0], edgeLookup[0] & entHardEdge);
				
				// Add the triangle fan for this edge segment
				meshb_PushVertex(body.mesh, new MBVertex(new Vector3(segmentStart.x, segmentStart.y, entMeshCenter.z), entMeshColor, 1.0, new Vector2(1.0, 0.0), entMeshUp));
				meshb_PushVertex(body.mesh, new MBVertex(new Vector3(segmentEnd.x,   segmentEnd.y,   entMeshCenter.z), entMeshColor, 1.0, new Vector2(1.0, 0.0), entMeshUp));
				meshb_PushVertex(body.mesh, new MBVertex(entMeshCenter, entMeshColor, 1.0, new Vector2(0.0, 0.0), entMeshUp));
			}
		}
	}
	
	meshb_End(body.mesh);
}

function WaterRenderer_RenderBodies()
{
	static water_uniforms = shaderGetUniforms(sh_unlitWater,
	[
		"uOutsideEdgeColor",
		"uInsideEdgeColor",
		"uInsideBaseColor",
		"uPositionParams",
		"uTime",
		"uWaterSheetUVs",
	]);
	static water_samplers = shaderGetSamplers(sh_unlitWater,
	[
		"textureEdgemask",
		"textureWaterSheet",
	]);
	static water_mask_uniforms = shaderGetUniforms(sh_unlitWater_Mask, ["uDrawColor"]);
	static water_edgefind_uniforms = shaderGetUniforms(sh_unlitWater_EdgeFind, ["uPositionParams"]);
	
	var last_shader = drawShaderGet();
	gpu_push_state();
	
	// Render all the bodies - first by making temp textures and then rendering their meshes.
	
	// TODO: move this texture creation to a offline step
	// Create each body's texture:
	var edgemasks = array_create(array_length(bodies));
	
	for (var bodyIndex = 0; bodyIndex < array_length(bodies); ++bodyIndex)
	{
		var body = bodies[bodyIndex];
		
		var temp_edge_mask = surface_create(body.topdownSize.x, body.topdownSize.y);
		surface_set_target(temp_edge_mask);
		
		// Clear off shader & clear the surface
		drawShaderSet(null);
		draw_clear_alpha(c_black, 1.0);
		
		// Draw the center mesh white
		drawShaderSet(sh_unlitWater_Mask);
		shader_set_uniform_f(water_mask_uniforms.uDrawColor, 1.0, 1.0, 1.0, 1.0);
		// Set up matrix - pull it to the center of device, then pull it from the center to the upper left
		matrix_set(matrix_view, matrix_build_translation(new Vector3(-body.minBox.x - body.topdownSize.x * 0.5, -body.minBox.y - body.topdownSize.y * 0.5 , -0.0)));
		vertex_submit(body.mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
		
		surface_reset_target();
		
		// Create an edge mask now
		edgemasks[bodyIndex] = surface_create(body.topdownSize.x, body.topdownSize.y);
		surface_set_target(edgemasks[bodyIndex]);
		
		// Clear off shader & clear the surface
		drawShaderSet(null);
		draw_clear_alpha(c_black, 1.0);
		
		// Draw the prev surface w/ edge find shader
		drawShaderSet(sh_unlitWater_EdgeFind);
		shader_set_uniform_f(water_edgefind_uniforms.uPositionParams, body.minBox.x, body.minBox.y, body.topdownSize.x, body.topdownSize.y);
		draw_surface(temp_edge_mask, 0, 0);
		
		surface_reset_target();
		
		surface_free(temp_edge_mask);
	}
	
	// Needed since surface_sets set up their own projection.
	o_Camera3D.reapplyViewProjection();
	
	drawShaderSet(sh_unlitWater);
	
	//gpu_set_blendmode_ext(bm_dest_color, bm_src_color);
	//gpu_set_blendmode_ext(bm_src_alpha, bm_src_color);
	gpu_set_blendmode(bm_normal);
	gpu_set_ztestenable(true);
	gpu_set_zwriteenable(true);
	//gpu_set_zfunc(cmpfunc_notequal);
	
	shader_set_uniform_f(water_uniforms.uOutsideEdgeColor, 73.0 / 255, 226.0 / 255, 226.0 / 255, 1.0);
	shader_set_uniform_f(water_uniforms.uInsideEdgeColor, 28.0 / 255, 170.0 / 255, 170.0 / 255, 1.0);
	shader_set_uniform_f(water_uniforms.uInsideBaseColor, 28.0 / 255, 170.0 / 255, 170.0 / 255, 0.3);
	shader_set_uniform_f(water_uniforms.uTime, Time.time);
	
	var waterSheetUvs = sprite_get_uvs(sfx_waterSheets, 0);
	shader_set_uniform_f(water_uniforms.uWaterSheetUVs, waterSheetUvs[0], waterSheetUvs[1], waterSheetUvs[2], waterSheetUvs[3]);
	texture_set_stage(water_samplers.textureWaterSheet, sprite_get_texture(sfx_waterSheets, 0));
	
	// Now submit each body's mesh w/ special shader
	for (var bodyIndex = 0; bodyIndex < array_length(bodies); ++bodyIndex)
	{
		var body = bodies[bodyIndex];
		
		// Set up rendering params
		shader_set_uniform_f(water_uniforms.uPositionParams, body.minBox.x, body.minBox.y, body.topdownSize.x, body.topdownSize.y);
		texture_set_stage(water_samplers.textureEdgemask, surface_get_texture(edgemasks[bodyIndex]));
		
		// Push the entire body's mesh thru
		vertex_submit(body.mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
		
		// Done with the edgemask
		surface_free(edgemasks[bodyIndex]);
	}
	
	
	drawShaderSet(last_shader);
	gpu_pop_state();
}