	/// Builder for AMapGeometry from editor's Solids input

function AMapGeoBuilderState() constructor
{
	materialMap = ds_map_create();
	resourceMap = ds_map_create();
	
	static Cleanup = function()
	{
		ds_map_destroy(materialMap);
		ds_map_destroy(resourceMap);
	}
}

/// @function MapGeo_BuildAll(editorMap)
/// @returns new AMapGeometry containing cooked map.
function MapGeo_BuildAll(editorMap)
{
	var geo = new AMapGeometry();
	var builderState = new AMapGeoBuilderState();
	
	// Start with collecting the materials for all of the map solids:
	builderState.materialMap = ds_map_create();
	for (var solidIndex = 0; solidIndex < array_length(editorMap.solids); ++solidIndex)
	{
		var mapSolid = editorMap.solids[solidIndex];
		for (var faceIndex = 0; faceIndex < array_length(mapSolid.faces); ++faceIndex)
		{
			MapGeo_AddMaterial(builderState, geo, mapSolid.faces[faceIndex].texture);
		}
	}
	
	// For now, we just triangulate everything and dump it into the Geo
	for (var solidIndex = 0; solidIndex < array_length(editorMap.solids); ++solidIndex)
	{
		var mapSolid = editorMap.solids[solidIndex];
		MapGeo_BuildAddSolid(builderState, geo, mapSolid);
	}
	
	builderState.Cleanup();
	delete builderState;
	
	return geo;
}

function MapGeo_AddMaterial(builderState, geo, material)
{
	// Ensure this material has a UID built for later
	unique_id = material.BuildUID(); // Since we can't be sure if its up-to-date, we force rebuilding it
	
	// Only add if the material is not inside of it
	if (!array_contains_pred(geo.materials, material, function(matA, matB){ return matA.Equals(matB); }))
	{
		// Build material
		array_push(geo.materials, material);
		
		// Cache the material with its ID for later
		builderState.materialMap[? unique_id] = array_length(geo.materials) - 1;
		
		// And load the resource into resource system for using later
		var pixel_resource;
		if ((material.type == kTextureTypeSprite && material.source == ssy_Skip)
			|| material.type == kTextureTypeSkip)
		{
			pixel_resource = null;
			
			var new_material = new AMapSolidFaceTexture();
			new_material.type = kTextureTypeSkip;
			new_material.source = ssy_Skip;
			geo.materials[array_length(geo.materials) - 1] = new_material;
		}
		else if ((material.type == kTextureTypeSprite && material.source == ssy_Clip)
			|| material.type == kTextureTypeClip)
		{
			pixel_resource = null;
			
			var new_material = new AMapSolidFaceTexture();
			new_material.type = kTextureTypeClip;
			new_material.source = ssy_Clip;
			geo.materials[array_length(geo.materials) - 1] = new_material;
		}
		else if (material.type == kTextureTypeSpriteTileset
			|| material.type == kTextureTypeSprite)
		{
			// Find the sprite resource
			var pixel_resource = ResourceFindSpriteTexture(material.source);
			if (is_undefined(pixel_resource))
			{
				pixel_resource = ResourceAddTexture(unique_id, material.source);
			}
		}
		else
		{
			// Load the texture resource
			pixel_resource = ResourceLoadTexture(material.source, GetLargestSurfaceDims(), GetLargestSurfaceDims());
		}
		builderState.resourceMap[? unique_id] = pixel_resource;
	}
}

function MapGeo_BuildAddSolid(builderState, geo, mapSolid)
{
	for (var faceIndex = 0; faceIndex < array_length(mapSolid.faces); ++faceIndex)
	{
		var face = mapSolid.faces[faceIndex];
		
		// Get the material info
		var material = builderState.materialMap[? face.texture.GetUID()];
		if (geo.materials[material].type == kTextureTypeSkip)
		{
			continue; // Skip any SKIP material.
		}
		else if (geo.materials[material].type == kTextureTypeClip)
		{
			material = kGeoMaterialIndex_Clip; // Go ahead with CLIP, but make sure to set special index.
		}
		
		var triangleList = mapSolid.TriangulateFace(faceIndex, false);
			
		// Create a plane for calculating UVs
		var facePlane = Plane3FromNormalOffset(face.uvinfo.normal, new Vector3(0, 0, 0));
		
		// Get the original size for this texture
		var scaleInfo;
		{
			var resource = builderState.resourceMap[? face.texture.GetUID()];
			if (is_struct(resource))
			{
				scaleInfo = [sprite_get_width(resource.sprite), sprite_get_height(resource.sprite)];
			}
			else
			{	// Do some sensible defaults.
				scaleInfo = [16, 16];
			}
		}
			
		// Now grab the vertices
		for (var triangleIndex = 0; triangleIndex < array_length(triangleList); ++triangleIndex)
		{
			var triIndices = triangleList[triangleIndex];
		
			// Create our geometry output
			var geoTriangle = new AMapGeometryTriangle();
			
			// Set up material first
			geoTriangle.material = material;
		
			// Set up the positions & uvs
			for (var triCorner = 0; triCorner < 3; ++triCorner)
			{
				var solidVertex = mapSolid.vertices[triIndices[triCorner]];
				
				// Grab ref
				var meshVert = geoTriangle.vertices[triCorner];
					
				// Get position
				meshVert.position.x = solidVertex.position.x;
				meshVert.position.y = solidVertex.position.y;
				meshVert.position.z = solidVertex.position.z;
					
				// Get UVs
				var uvPoint = facePlane.flattenPoint(solidVertex.position);
				face.uvinfo.TransformPoint(uvPoint, face.texture, scaleInfo);
					
				meshVert.uv.x = uvPoint.x;
				meshVert.uv.y = uvPoint.y;
			}
			
			// Calculate normal for this triangle
			var faceNormal = TriangleGetNormal([Vector3FromTranslation(geoTriangle.vertices[0].position), Vector3FromTranslation(geoTriangle.vertices[1].position), Vector3FromTranslation(geoTriangle.vertices[2].position)]);
			
			// Write normals
			for (var i = 0; i < 3; ++i)
			{
				geoTriangle.vertices[i].normal.x = faceNormal.x;
				geoTriangle.vertices[i].normal.y = faceNormal.y;
				geoTriangle.vertices[i].normal.z = faceNormal.z;
			}
			
			// Add triangle to the list
			array_push(geo.triangles, geoTriangle);
		}
	}
}