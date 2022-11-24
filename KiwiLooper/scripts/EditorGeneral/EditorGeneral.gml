function EditorLevel_Init()
{
	x = 0;
	y = 0;
	z = 0;

	// Kill the gameplay now
	idelete(Gameplay);

	// Update the screen now
	Screen.scaleMode = kScreenscalemode_Expand;

	// Set up serialized state
	m_state = new AMapEditorState();

	EditorToolsSetup();

	m_currentMapName = "";

	// List of all layers currently used for the tiles and props.
	//intermediateLayers = [];
	solidsRenderer = null;
	
	// Rebuilds all the graphics for the map: props, tilemap, and splats
	MapRebuildGraphics = function()
	{
		// Delete existing renderers
		//idelete(o_tileset3DIze);
		//idelete(o_solids3DIze);
		//idelete(o_props3DIze2);
	
		// Delete all current intermediate layers
		MapFreeAllIntermediateLayers();
	
		// Set up the tiles
		//m_tilemap.BuildLayers(intermediateLayers);
	
		// Set up the props
		//m_propmap.RebuildPropLayer(intermediateLayers);
	
		// Create the 3d-ify chain
		//inew(o_tileset3DIze);
		
		//var solids = inew(o_solids3DIze);
		//solids.
		EditorSolidsRendererFree();
		EditorSolidsRendererCreate();
		
		
		MapRebuilPropsOnly();
	
		// Now that we have collision, recreate the splats
		MapRebuildSplats();
	}
	
	// Rebuilds only the solids graphics
	MapRebuildSolidsOnly = function()
	{
		//solids.
		EditorSolidsRendererFree();
		EditorSolidsRendererCreate();
	
		// Now that we have collision, recreate the splats
		MapRebuildSplats();
	}
	
	// Rebuilds all the grphics for the map: props only
	MapRebuilPropsOnly = function()
	{
		// Delete existing renderers
		idelete(o_props3DIze2);
	
		// Delete the matching intermediate layer
		/*for (var layerIndex = 0; layerIndex < array_length(intermediateLayers); ++layerIndex)
		{
			var layer_name = layer_get_name(intermediateLayers[layerIndex]);
			var layer_name_search_position = string_pos("props", layer_name);
			if (layer_name_search_position != 0)
			{
				layer_destroy(intermediateLayers[layerIndex]);
				array_delete(intermediateLayers, layerIndex, 1);
				break;
			}
		}*/
	
		// Set up the props
		//m_propmap.RebuildPropLayer(intermediateLayers);
		var props = inew(o_props3DIze2);
		props.SetMap(m_propmap);
		props.BuildMesh();
	
		// Create the missing part of the 3d-ify chain
		//inew(o_props3DIze);
	}
	
	// Rebuilds all the graphics for the map: splats only
	MapRebuildSplats = function()
	{
		// Delete all splats
		idelete(ob_splatter);
	
		// Trigger the splats
		m_splatmap.SpawnSplats();
	
		// Force splats to update
		if (instance_number(ob_splatter) == 0)
		{
			if (iexists(o_splatterRenderer))
			{
				o_splatterRenderer.update();
			}
		}
	
		// Done.
	}
	MapFreeAllIntermediateLayers = function()
	{
		// Delete all current intermediate layers
		//layer_destroy_list(intermediateLayers);
		//intermediateLayers = [];
	}

	EditorUIBitsSetup();
	EditorCameraSetup();
	EditorGizmoSetup();
	EditorSelectionSetup();
	EditorClipboardSetup();

	EditorTileMapSetup();
	EditorPropAndSplatSetup();
	m_entityInstList = new AEntityList();
	m_aimap = new AMapAiInfo();


	m_taskRebuildAi = null;
	m_taskRebuildLighting = null;
}

function EditorLevel_Cleanup()
{
	EditorSolidsRendererFree(); // TODO: Other
}

function EditorSolidsRendererFree()
{
	if (solidsRenderer != null && iexists(solidsRenderer))
	{
		meshB_Cleanup(solidsRenderer.m_mesh);
		idelete(solidsRenderer);
	}
}
function EditorSolidsRendererCreate()
{
	solidsRenderer = inew(ob_3DObject);
	solidsRenderer.lit = true; // TODO
	
	var mesh = meshb_Begin();
	for (var solidIndex = 0; solidIndex < array_length(m_state.map.solids); ++solidIndex)
	{
		var mapSolid = m_state.map.solids[solidIndex];
		for (var faceIndex = 0; faceIndex < array_length(mapSolid.faces); ++faceIndex)
		{
			var face = mapSolid.faces[faceIndex];
			var triangleList = mapSolid.TriangulateFace(faceIndex, false);
			
			// Get the atlas UVs used for this face
			var face_tex_uvs = sprite_get_uvs(face.texture.source, face.texture.index); // TODO: also account for different face.texture.type's
			
			// Now grab the vertices
			var faceMesh = array_create(array_length(triangleList) * 3);
			for (var triangleIndex = 0; triangleIndex < array_length(triangleList); ++triangleIndex)
			{
				var triIndices = triangleList[triangleIndex];
				
				// Create a plane for calculating UVs
				var facePlane = new Plane3(face.uvinfo.normal, new Vector3(0, 0, 0));
				
				// Set up the positions & uvs
				for (var triCorner = 0; triCorner < 3; ++triCorner)
				{
					var solidVertex = mapSolid.vertices[triIndices[triCorner]];
					
					var meshVert = MBVertexDefault();
					
					// Get position
					meshVert.position.x = solidVertex.position.x;
					meshVert.position.y = solidVertex.position.y;
					meshVert.position.z = solidVertex.position.z;
					
					// Get UVs
					var uvPoint = facePlane.flattenPoint(solidVertex.position);
					uvPoint.addSelf(face.uvinfo.offset).multiplyComponentSelf(face.uvinfo.scale).rotateSelf(face.uvinfo.rotation);
					// Bias to the UVs
					uvPoint.biasUVSelf(face_tex_uvs);
					meshVert.uv.x = uvPoint.x;
					meshVert.uv.y = uvPoint.y;
					
					// Save our new vertex!
					faceMesh[triangleIndex * 3 + triCorner] = meshVert;
				}
				
				// Calculate normal for this triangle
				var faceNormal = TriangleGetNormal([Vector3FromTranslation(faceMesh[0].position), Vector3FromTranslation(faceMesh[1].position), Vector3FromTranslation(faceMesh[2].position)]);
				for (var i = 0; i < 3; ++i)
				{
					faceMesh[triangleIndex * 3 + i].normal.x = faceNormal.x;
					faceMesh[triangleIndex * 3 + i].normal.y = faceNormal.y;
					faceMesh[triangleIndex * 3 + i].normal.z = faceNormal.z;
				}
			}
			// Now that everything fixed up, add the tri
			meshb_AddTris(mesh, faceMesh);
		}
	}
	
	meshb_End(mesh);
	
	solidsRenderer.m_mesh = mesh;
	solidsRenderer.m_renderEvent = method(solidsRenderer, function()
	{
		var shaderPrev = drawShaderGet();
		drawShaderSet(sh_editorSolidsDebug);
		
			vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(stl_lab0, 0));
			
		drawShaderSet(shaderPrev);
	});
}