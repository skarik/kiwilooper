/// @description Load mesh & set up render

var uvs = sprite_get_uvs(sfx_square, 0); // use a white texture for testing
m_texture = sprite_get_texture(sfx_square, 0);

/*
// load in the model
var parser = new AMD2FileParser();
//parser.OpenFile("models/default cube.md2");
//parser.OpenFile("models/boss1.md2"); // quake 2 boss 1 lmaoooo
//parser.OpenFile("models/gunner.md2");
parser.OpenFile("models/kiwi.md2");
//var parser = new AMDLFileParser();
//parser.OpenFile("models/shambler.mdl");
// decompress the model
if (!parser.ReadFrames() || !parser.ReadTextures())
{
	show_error("beansed it", true);
}
parser.CloseFile();

// pull the texture
if (array_length(parser.GetTextures()) > 0)
{
	uvs = sprite_get_uvs(parser.GetTextures()[0], 0);
	m_texture = sprite_get_texture(parser.GetTextures()[0], 0);
}

// create a render mesh
var frameCount = array_length(parser.GetFrames());
for (var iframe = 0; iframe < frameCount; ++iframe)
{
	var frame = parser.GetFrames()[iframe];
	var frame_mesh = meshb_Begin();
	for (var i = 0; i < array_length(frame.vertices); ++i)
	{
		meshb_PushVertex(frame_mesh, 
			new MBVertex(
				Vec3(frame.vertices[i][0], frame.vertices[i][1], frame.vertices[i][2]),
				c_white, 1.0,
				(new Vector2(frame.texcoords[i][0], frame.texcoords[i][1])).biasUVSelf(uvs),
				Vec3(frame.normals[i][0], frame.normals[i][1], frame.normals[i][2])
				)
			);
	}
	meshb_End(frame_mesh);
	
	mesh_frame[iframe] = frame_mesh;
}

// and we're done w/ parser
delete parser;
*/

mesh_frame = [];
var mesh_resource = ResourceLoadModel("models/kiwi.md2");
mesh_frame = mesh_resource.frames;
m_texture = sprite_get_texture(mesh_resource.textures[0], 0);

// set up rendering
m_renderEvent = function()
{
	var finalIndex = floor(abs(animationIndex)) % array_length(mesh_frame);
	m_mesh = mesh_frame[finalIndex];

	vertex_submit(m_mesh, pr_trianglelist, m_texture);
}


animationIndex = 0;