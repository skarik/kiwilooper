/// @description Load mesh & set up render

bRenderOk = false;

// Render defualts
/*animationIndex = 0; // current frame
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
}*/

// set up editor stuff
{
	// If in editor, set up editor state & conditional render event
	if (Game_IsInEditor())
	{
		modelFilePrevious = "";
		
		animationIndex = 0; // current frame
		mesh_resource = undefined;
		mesh_frame = [];
		mesh_texture = nullptr;
	
		m_renderEvent = function()
		{
			if (bRenderOk)
			{
				var finalIndex = floor(abs(animationIndex)) % array_length(mesh_frame);
				m_mesh = mesh_frame[finalIndex];

				vertex_submit(m_mesh, pr_trianglelist, mesh_texture);
			}
		}
	}

	// each step, we want to load the model specified
	onEditorStep = function()
	{
		if (modelFilePrevious != modelFile)
		{
			// free the old model
			if (!is_undefined(mesh_resource))
			{
				ResourceRemoveReference(mesh_resource);
				mesh_resource = undefined;
			}
			
			// attempt load
			mesh_resource = ResourceLoadModel(modelFile);
			if (!is_undefined(mesh_resource))
			{
				ResourceAddReference(mesh_resource);
	
				mesh_frame = mesh_resource.frames;
				mesh_texture = mesh_resource.textures[0].texture_ptr;
	
				bRenderOk = (array_length(mesh_frame) > 0) && (mesh_texture != nullptr);
			}
			// load failed
			else
			{
				bRenderOk = false;
			}
		}
	}
}

// set up game stuff
{
	// actually called on load
	onPostLevelLoad = function()
	{
		// Load model
		mesh_resource = ResourceLoadModel(modelFile);
		if (!is_undefined(mesh_resource))
		{
			ResourceAddReference(mesh_resource);
	
			animationIndex = 0; // current frame
			mesh_frame = mesh_resource.frames;
			mesh_texture = mesh_resource.textures[0].texture_ptr;
	
			bRenderOk = (array_length(mesh_frame) > 0) && (mesh_texture != nullptr);
		}
	
		// set up rendering
		if (bRenderOk)
		{
			m_renderEvent = function()
			{
				var finalIndex = floor(abs(animationIndex)) % array_length(mesh_frame);
				m_mesh = mesh_frame[finalIndex];

				vertex_submit(m_mesh, pr_trianglelist, mesh_texture);
			}
		}
		else
		{
			// todo: proper error model here
			delete(this);
		}
	}
}