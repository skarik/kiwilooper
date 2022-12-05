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
	solidsRenderer = null;
	
	// Rebuilds all the graphics for the map: props, tilemap, and splats
	MapRebuildGraphics = function()
	{
		// Delete existing renderers
		idelete(o_tileset3DIze2);
	
		// Delete all current intermediate layers
		MapFreeAllIntermediateLayers();
	
		// Build tilemap rendering
		var tilemap_renderer = inew(o_tileset3DIze2);
		tilemap_renderer.SetTilemap(m_tilemap);
		tilemap_renderer.BuildMesh();
		
		// Build solids
		EditorSolidsRendererFree();
		EditorSolidsRendererCreate();
		
		// Rebuild props now
		MapRebuilPropsOnly();
	
		// Now that we have collision, recreate the splats
		MapRebuildSplats();
	}
	
	// Rebuilds only the solids graphics
	MapRebuildSolidsOnly = function(solid_id = null)
	{
		// Delete existing renderers
		idelete(o_tileset3DIze2);
		
		// Delete all current intermediate layers
		MapFreeAllIntermediateLayers();
		
		// Build tilemap rendering
		var tilemap_renderer = inew(o_tileset3DIze2);
		tilemap_renderer.SetTilemap(m_tilemap);
		tilemap_renderer.BuildMesh();
		
		// Build solids
		EditorSolidsRendererFree();
		EditorSolidsRendererCreate(); // TODO
	
		// Now that we have collision, recreate the splats
		MapRebuildSplats();
	}
	
	// Rebuilds all the grphics for the map: props only
	MapRebuilPropsOnly = function()
	{
		// Delete existing renderers
		idelete(o_props3DIze2);
	
		// Set up the props
		var props = inew(o_props3DIze2);
		props.SetMap(m_propmap);
		props.BuildMesh();
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
	}
	MapFreeAllIntermediateLayers = function()
	{
		// Done.
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
	m_mapgeometry = new AMapGeometry();

	m_taskRebuildAi = null;
	m_taskRebuildLighting = null;

	// TODO: combine with [m_solidUpdateRequestList]
	m_wantRebuildSolids = false;
}

function EditorLevel_Cleanup()
{
	EditorSolidsRendererFree(); // TODO: Other
}

//=============================================================================

function EditorSolidsUpdate()
{
	if (m_wantRebuildSolids)
	{
		m_wantRebuildSolids = false;
		MapRebuildSolidsOnly();
	}
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
	// TODO: Batch solids into 4-solid groups (or just about that)
	// For that, we'd just mark all solid groups as "dirty" then go about rebuilding.

	solidsRenderer = inew(ob_3DObject);
	solidsRenderer.lit = true; // TODO
	
	var mesh = meshb_Begin(MapGeometry_CreateVertexFormat());
	for (var solidIndex = 0; solidIndex < array_length(m_state.map.solids); ++solidIndex)
	{
		var mapSolid = m_state.map.solids[solidIndex];
		for (var faceIndex = 0; faceIndex < array_length(mapSolid.faces); ++faceIndex)
		{
			var face = mapSolid.faces[faceIndex];
			var triangleList = mapSolid.TriangulateFace(faceIndex, false);
			
			// Get the atlas UVs used for this face
			var atlasInfo = face.texture.GetTextureUVs();
			
			// Create a plane for calculating UVs
			var facePlane = Plane3FromNormalOffset(face.uvinfo.normal, new Vector3(0, 0, 0));
			
			// Now grab the vertices
			var faceMesh = array_create(array_length(triangleList) * 3);
			for (var triangleIndex = 0; triangleIndex < array_length(triangleList); ++triangleIndex)
			{
				var triIndices = triangleList[triangleIndex];
				
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
					face.uvinfo.TransformPoint(uvPoint, face.texture);
					
					meshVert.uv.x = uvPoint.x;
					meshVert.uv.y = uvPoint.y;
					
					// Save our new vertex!
					faceMesh[triangleIndex * 3 + triCorner] = meshVert;
				}
				
				// Calculate normal for this triangle
				var faceNormal = TriangleGetNormal([Vector3FromTranslation(faceMesh[0].position), Vector3FromTranslation(faceMesh[1].position), Vector3FromTranslation(faceMesh[2].position)]);
				
				// Write normals + uvs
				for (var i = 0; i < 3; ++i)
				{
					faceMesh[triangleIndex * 3 + i].normal.x = faceNormal.x;
					faceMesh[triangleIndex * 3 + i].normal.y = faceNormal.y;
					faceMesh[triangleIndex * 3 + i].normal.z = faceNormal.z;
					
					faceMesh[triangleIndex * 3 + i].atlas = atlasInfo;
				}
			}
			// Now that everything fixed up, add the tri
			//meshb_AddTris(mesh, faceMesh);
			for (var i = 0; i < array_length(faceMesh); ++i)
			{
				MapGeometry_PushVertex(mesh, faceMesh[i]);
			}
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