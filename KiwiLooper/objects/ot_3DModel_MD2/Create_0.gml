/// @description Load mesh & set up render

bRenderOk = false;

// Render defualts
animationIndex = 0; // current frame
mesh_frame = [];
mesh_texture = nullptr;

// Load model
mesh_resource = ResourceLoadModel("models/kiwi.md2");
if (!is_undefined(mesh_resource))
{
	ResourceAddReference(mesh_resource);
	
	mesh_frame = mesh_resource.frames;
	mesh_texture = mesh_resource.textures[0].texture_ptr;
	
	bRenderOk = (array_length(mesh_frame) > 0) && (mesh_texture != nullptr);
}

// set up rendering
m_renderEvent = function()
{
	if (bRenderOk)
	{
		var finalIndex = floor(abs(animationIndex)) % array_length(mesh_frame);
		m_mesh = mesh_frame[finalIndex];

		vertex_submit(m_mesh, pr_trianglelist, mesh_texture);
	}
}
