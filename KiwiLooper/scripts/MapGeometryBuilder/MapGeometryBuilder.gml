/// Builder for AMapGeometry from editor's Solids input

function AMapGeoBuilderState() constructor
{
	materialMap = ds_map_create();
	
	static Cleanup = function()
	{
		ds_map_destroy(materialMap);
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
	}
}

function MapGeo_BuildAddSolid(builderState, geo, mapSolid)
{
	for (var faceIndex = 0; faceIndex < array_length(mapSolid.faces); ++faceIndex)
	{
		var face = mapSolid.faces[faceIndex];
		var triangleList = mapSolid.TriangulateFace(faceIndex, false);
			
		// Create a plane for calculating UVs
		var facePlane = new Plane3(face.uvinfo.normal, new Vector3(0, 0, 0));
			
		// Now grab the vertices
		for (var triangleIndex = 0; triangleIndex < array_length(triangleList); ++triangleIndex)
		{
			var triIndices = triangleList[triangleIndex];
		
			// Create our geometry output
			var geoTriangle = new AMapGeometryTriangle();
			
			// Set up material first
			geoTriangle.material = builderState.materialMap[? face.texture.GetUID()];
		
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
				face.uvinfo.TransformPoint(uvPoint, face.texture);
					
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