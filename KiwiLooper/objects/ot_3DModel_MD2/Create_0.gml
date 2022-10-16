/// @description Load mesh & set up render

var uvs = sprite_get_uvs(sfx_square, 0); // use a white texture for testing

// load in the model
var parser = new AMD2FileParser();
//parser.OpenFile("models/default cube.md2");
parser.OpenFile("models/boss1.md2"); // quake 2 boss 1 lmaoooo
// decompress the model
if (!parser.ReadFrames())
{
	show_error("beansed it", true);
}
parser.CloseFile();

// create a render mesh
var frame = parser.GetFrames()[0];
m_mesh = meshb_Begin();
for (var i = 0; i < array_length(frame.vertices); ++i)
{
	meshb_PushVertex(m_mesh, 
		new MBVertex(
			Vec3(frame.vertices[i][0], frame.vertices[i][1], frame.vertices[i][2]),
			c_white, 1.0,
			(new Vector2(frame.texcoords[i][0], frame.texcoords[i][1])).biasUVSelf(uvs),
			Vec3(frame.normals[i][0], frame.normals[i][1], frame.normals[i][2])
			)
		);
}
meshb_End(m_mesh);

// and we're done w/ parser
delete parser;

// set up rendering
m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
}
