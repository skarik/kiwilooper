function AMapSolid() constructor
{
	faces = [];
	vertices = [];
	
	static GetBBox = function()
	{
		var min_pos = vertices[0].position.copy();
		var max_pos = vertices[0].position.copy();
		
		for (var i = 1; i < array_length(vertices); ++i)
		{
			min_pos.x = min(min_pos.x, vertices[i].position.x);
			min_pos.y = min(min_pos.y, vertices[i].position.y);
			min_pos.z = min(min_pos.z, vertices[i].position.z);
			
			max_pos.x = max(max_pos.x, vertices[i].position.x);
			max_pos.y = max(max_pos.y, vertices[i].position.y);
			max_pos.z = max(max_pos.z, vertices[i].position.z);
		}
		
		return BBox3FromMinMax(min_pos, max_pos);
	}
	
	static TriangulateFace = function(faceIndex, triangleFan)
	{
		var triangles = [];
		var face = faces[faceIndex];
		var index_count = array_length(face.indicies);
		
		assert(index_count > 2);
		
		// Triangle
		if (index_count == 3)
		{
			triangles = [[face.indicies[0], face.indicies[1], face.indicies[2]]];
		}
		// Quad
		else if (index_count == 4)
		{
			triangles = [
				[face.indicies[0], face.indicies[1], face.indicies[2]],
				[face.indicies[2], face.indicies[3], face.indicies[0]]
			];
		}
		// Convex Polygon
		else
		{
			if (triangleFan)
			{
				// Add a triangle, fanning out from the first vertex
				for (var i = 2; i < index_count; ++i)
				{
					array_push(triangles, [face.indicies[0], face.indicies[i], face.indicies[i-1]]);
				}
			}
			else
			{
				// Add triangles for all the edges
				for (var i = 2; i <= floor(index_count / 2) * 2; i += 2)
				{
					array_push(triangles, [face.indicies[i-2], face.indicies[i-1], face.indicies[i % index_count]]);
				}
				// Fill in the center holes
				for (var i = 4; i < index_count; i += 2)
				{
					array_push(triangles, [face.indicies[0], face.indicies[i-2], face.indicies[i]]);
				}
			}
		}
		
		return triangles;
	}
}

function AMapSolidFace() constructor
{
	indicies = [];
	uvinfo = new AMapSolidFaceUVInfo();
	texture = new AMapSolidFaceTexture();
}

#macro kTextureTypeSprite 0
#macro kTextureTypeSpriteTileset 1

function AMapSolidFaceTexture() constructor
{
	source = stl_lab0;
	type = kTextureTypeSpriteTileset;
	index = 0;
}

#macro kSolidMappingWorld 0		// Specific case of Normal, where normal is locked to nearest axes
#macro kSolidMappingFace 1		// Specific case of Normal, where normal is locked to the face's normal
#macro kSolidMappingNormal 2

function AMapSolidFaceUVInfo() constructor
{
	mapping = kSolidMappingWorld;
	normal = new Vector3(0, 0, 1.0);
	scale = new Vector2(1.0, 1.0);
	offset = new Vector2(0, 0);
	rotation = 0.0;
}

function AMapSolidVertex() constructor
{
	position = new Vector3(0, 0, 0);
}