/// @function AEditorGizmoPointMove() constructor
/// @desc Editor gizmo for moving objects around.
function AEditorGizmoPointMove() : AEditorGizmoBase() constructor
{
	x = 32;
	y = 32;
	z = 32;
	
	m_mesh = meshb_Begin();
	meshb_End(m_mesh);
	
	m_mouseOverX = false;
	m_mouseOverY = false;
	m_mouseOverZ = false;
	
	m_dragX = false;
	m_dragY = false;
	m_dragZ = false;
	
	m_active = false;
	
	GetConsumingMouse = function()
	{
		return m_dragX || m_dragY || m_dragZ;
	}
	
	/// @function Cleanup()
	/// @desc Cleans up the mesh used for rendering.
	Cleanup = function()
	{
		meshB_Cleanup(m_mesh);
	};
	
	Step = function()
	{
		// Calculate the sizing based on the distance to the gizmo:
		var kScreensizeFactor = CalculateScreensizeFactor();
		var kBorderExpand = 1 * kScreensizeFactor;
		var kAxisLength = 32 * kScreensizeFactor;
		var kArrowHalfsize = 5 * kScreensizeFactor;
		
		var pixelX = m_editor.uPosition - GameCamera.view_x;
		var pixelY = m_editor.vPosition - GameCamera.view_y;
		
		// Get a ray
		var rayStart = new Vector3(o_Camera3D.x, o_Camera3D.y, o_Camera3D.z);
		var rayDir = Vector3FromArray(o_Camera3D.viewToRay(pixelX, pixelY));
		
		// Do some collision checks for mousing over the axes
		m_mouseOverX = false;
		m_mouseOverY = false;
		m_mouseOverZ = false;
		
		if (MouseAvailable())
		{
			// Sort these checks by screen depth
			var depthX = o_Camera3D.positionToView(x + kAxisLength, y, z)[2];
			var depthY = o_Camera3D.positionToView(x, y + kAxisLength, z)[2];
			var depthZ = o_Camera3D.positionToView(x, y, z + kAxisLength)[2];
		
			var check_depthOrder = [[0, depthX], [1, depthY], [2, depthZ]];
			if (check_depthOrder[0][1] > check_depthOrder[2][1]) CE_ArraySwap(check_depthOrder, 0, 2);
			if (check_depthOrder[0][1] > check_depthOrder[1][1]) CE_ArraySwap(check_depthOrder, 0, 1);
			if (check_depthOrder[1][1] > check_depthOrder[2][1]) CE_ArraySwap(check_depthOrder, 1, 2);
		
			// Check collision with each axis.
			for (var check_index = 0; check_index < 3; ++check_index)
			{
				var check_orderLookup = check_depthOrder[check_index][0];
				if (check_orderLookup == 0)
				{
					m_mouseOverX = raycast4_box(new Vector3(x + kAxisLength, y - kArrowHalfsize, z - kArrowHalfsize), new Vector3(x + kAxisLength + kArrowHalfsize*2, y + kArrowHalfsize, z + kArrowHalfsize), rayStart, rayDir);
					if (m_mouseOverX) break;
				}
				if (check_orderLookup == 1)
				{
					m_mouseOverY = raycast4_box(new Vector3(x - kArrowHalfsize, y + kAxisLength, z - kArrowHalfsize), new Vector3(x + kArrowHalfsize, y + kAxisLength + kArrowHalfsize*2, z + kArrowHalfsize), rayStart, rayDir);
					if (m_mouseOverY) break;
				}
				if (check_orderLookup == 2)
				{
					m_mouseOverZ = raycast4_box(new Vector3(x - kArrowHalfsize, y - kArrowHalfsize, z + kAxisLength), new Vector3(x + kArrowHalfsize, y + kArrowHalfsize, z + kAxisLength + kArrowHalfsize*2), rayStart, rayDir);
					if (m_mouseOverZ) break;
				}
			}
		}
		
		// Update active state based on editor using camera
		if (m_editor.toolCurrent == kEditorToolCamera)
		{
			m_active = false;
		}
		else
		{
			m_active = true;
		}
		
		// Update click states
		if (MouseCheckButtonPressed(mb_left))
		{
			if (m_mouseOverX)
				m_dragX = true;
			else if (m_mouseOverY)
				m_dragY = true;
			else if (m_mouseOverZ)
				m_dragZ = true;
		}
		
		if (m_dragX || m_dragY || m_dragZ)
		{
			if (m_dragX)
			{
				x += (m_editor.viewrayPixel[0] - m_editor.viewrayPixelPrevious[0]) * 1200 * kScreensizeFactor;
			}
			if (m_dragY)
			{
				y += (m_editor.viewrayPixel[1] - m_editor.viewrayPixelPrevious[1]) * 1200 * kScreensizeFactor;
			}
			if (m_dragZ)
			{
				z += (m_editor.viewrayPixel[2] - m_editor.viewrayPixelPrevious[2]) * 1200 * kScreensizeFactor;
			}
		}
		
		if (MouseCheckButtonReleased(mb_left) || !m_active)
		{
			m_dragX = false;
			m_dragY = false;
			m_dragZ = false;
		}
		
		// Update the visuals
		meshb_BeginEdit(m_mesh);
			if (m_active)
			{
				var xcolor = m_mouseOverX ? c_white : c_red;
				MeshbAddLine(m_mesh, xcolor, kBorderExpand, kAxisLength, new Vector3(1, 0, 0), new Vector3(x,y,z));
				MeshbAddBillboardTriangle(m_mesh, xcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(1, 0, 0), new Vector3(x + kAxisLength,y,z));
				var ycolor = m_mouseOverY ? c_white : c_midgreen;
				MeshbAddLine(m_mesh, ycolor, kBorderExpand, kAxisLength, new Vector3(0, 1, 0), new Vector3(x,y,z));
				MeshbAddBillboardTriangle(m_mesh, ycolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, 1, 0), new Vector3(x,y + kAxisLength,z));
				var zcolor = m_mouseOverZ ? c_white : c_midblue;
				MeshbAddLine(m_mesh, zcolor, kBorderExpand, kAxisLength, new Vector3(0, 0, 1), new Vector3(x,y,z));
				MeshbAddBillboardTriangle(m_mesh, zcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, 0, 1), new Vector3(x,y,z + kAxisLength));
			}
			else
			{
				MeshbAddLine(m_mesh, c_gray, kBorderExpand, kAxisLength, new Vector3(1, 0, 0), new Vector3(x,y,z));
				MeshbAddLine(m_mesh, c_gray, kBorderExpand, kAxisLength, new Vector3(0, 1, 0), new Vector3(x,y,z));
				MeshbAddLine(m_mesh, c_gray, kBorderExpand, kAxisLength, new Vector3(0, 0, 1), new Vector3(x,y,z));
			}
		meshb_End(m_mesh);
	};
	
	Draw = function()
	{
		var last_shader = drawShaderGet();
		var last_ztest = gpu_get_zfunc();
		var last_zwrite = gpu_get_zwriteenable();
			
		gpu_set_zwriteenable(false);
			
		drawShaderSet(sh_editorFlatShaded);
			
		gpu_set_zfunc(cmpfunc_greater);
		shader_set_uniform_f(global.m_editorFlatShaded_uFlatColor, 0.5, 0.5, 0.5, 1.0);
		vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
			
		gpu_set_zfunc(last_ztest);
		shader_set_uniform_f(global.m_editorFlatShaded_uFlatColor, 1.0, 1.0, 1.0, 1.0);
		vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
			
		drawShaderSet(last_shader);
		gpu_set_zwriteenable(last_zwrite);
	};
}

/// @function AEditorGizmoAxesMove() constructor
/// @desc Editor gizmo for moving objects around.
function AEditorGizmoAxesMove() : AEditorGizmoBase() constructor
{
	x = 32;
	y = 32;
	z = 32;
	
	m_mesh = meshb_Begin();
	meshb_End(m_mesh);
	
	m_mouseOverX = false;
	m_mouseOverY = false;
	m_mouseOverZ = false;
	
	m_dragX = false;
	m_dragY = false;
	m_dragZ = false;
	
	m_active = false;
	
	GetConsumingMouse = function()
	{
		return m_dragX || m_dragY || m_dragZ;
	}
	
	/// @function Cleanup()
	/// @desc Cleans up the mesh used for rendering.
	Cleanup = function()
	{
		meshB_Cleanup(m_mesh);
	};
	
	Step = function()
	{
		// Calculate the sizing based on the distance to the gizmo:
		var kScreensizeFactor = CalculateScreensizeFactor();
		var kBorderExpand = 0.5 * kScreensizeFactor;
		var kAxisLength = 32 * kScreensizeFactor;
		var kArrowHalfsize = 4 * kScreensizeFactor;
		var kScreenLength = 500 * kScreensizeFactor;
		
		var pixelX = m_editor.uPosition - GameCamera.view_x;
		var pixelY = m_editor.vPosition - GameCamera.view_y;
		
		// Get a ray
		var rayStart = new Vector3(o_Camera3D.x, o_Camera3D.y, o_Camera3D.z);
		var rayDir = Vector3FromArray(o_Camera3D.viewToRay(pixelX, pixelY));
		
		// Do some collision checks for mousing over the axes
		m_mouseOverX = false;
		m_mouseOverY = false;
		m_mouseOverZ = false;
		
		if (MouseAvailable())
		{
			// Sort these checks by screen depth
			var depthX = o_Camera3D.positionToView(x + kAxisLength, y, z)[2];
			var depthY = o_Camera3D.positionToView(x, y + kAxisLength, z)[2];
			var depthZ = o_Camera3D.positionToView(x, y, z + kAxisLength)[2];
		
			var check_depthOrder = [[0, depthX], [1, depthY], [2, depthZ]];
			if (check_depthOrder[0][1] > check_depthOrder[2][1]) CE_ArraySwap(check_depthOrder, 0, 2);
			if (check_depthOrder[0][1] > check_depthOrder[1][1]) CE_ArraySwap(check_depthOrder, 0, 1);
			if (check_depthOrder[1][1] > check_depthOrder[2][1]) CE_ArraySwap(check_depthOrder, 1, 2);
		
			// Check collision with each axis.
			for (var check_index = 0; check_index < 3; ++check_index)
			{
				var check_orderLookup = check_depthOrder[check_index][0];
				if (check_orderLookup == 0)
				{
					m_mouseOverX = 
						raycast4_box(new Vector3(x + kAxisLength, y - kArrowHalfsize, z - kArrowHalfsize), new Vector3(x + kAxisLength + kArrowHalfsize*2, y + kArrowHalfsize, z + kArrowHalfsize), rayStart, rayDir)
						|| raycast4_box(new Vector3(x - kAxisLength, y - kArrowHalfsize, z - kArrowHalfsize), new Vector3(x - kAxisLength - kArrowHalfsize*2, y + kArrowHalfsize, z + kArrowHalfsize), rayStart, rayDir);
					if (m_mouseOverX) break;
				}
				if (check_orderLookup == 1)
				{
					m_mouseOverY =
						raycast4_box(new Vector3(x - kArrowHalfsize, y + kAxisLength, z - kArrowHalfsize), new Vector3(x + kArrowHalfsize, y + kAxisLength + kArrowHalfsize*2, z + kArrowHalfsize), rayStart, rayDir)
						|| raycast4_box(new Vector3(x - kArrowHalfsize, y - kAxisLength, z - kArrowHalfsize), new Vector3(x + kArrowHalfsize, y - kAxisLength - kArrowHalfsize*2, z + kArrowHalfsize), rayStart, rayDir);
					if (m_mouseOverY) break;
				}
				if (check_orderLookup == 2)
				{
					m_mouseOverZ =
						raycast4_box(new Vector3(x - kArrowHalfsize, y - kArrowHalfsize, z + kAxisLength), new Vector3(x + kArrowHalfsize, y + kArrowHalfsize, z + kAxisLength + kArrowHalfsize*2), rayStart, rayDir)
						|| raycast4_box(new Vector3(x - kArrowHalfsize, y - kArrowHalfsize, z - kAxisLength), new Vector3(x + kArrowHalfsize, y + kArrowHalfsize, z - kAxisLength - kArrowHalfsize*2), rayStart, rayDir);
					if (m_mouseOverZ) break;
				}
			}
		}
		
		// Update active state based on editor using camera
		if (m_editor.toolCurrent == kEditorToolCamera)
		{
			m_active = false;
		}
		else
		{
			m_active = true;
		}
		
		// Update click states
		if (MouseCheckButtonPressed(mb_left))
		{
			if (m_mouseOverX)
				m_dragX = true;
			else if (m_mouseOverY)
				m_dragY = true;
			else if (m_mouseOverZ)
				m_dragZ = true;
		}
		
		if (m_dragX || m_dragY || m_dragZ)
		{
			if (m_dragX)
			{
				x += (m_editor.viewrayPixel[0] - m_editor.viewrayPixelPrevious[0]) * 1200 * kScreensizeFactor;
			}
			if (m_dragY)
			{
				y += (m_editor.viewrayPixel[1] - m_editor.viewrayPixelPrevious[1]) * 1200 * kScreensizeFactor;
			}
			if (m_dragZ)
			{
				z += (m_editor.viewrayPixel[2] - m_editor.viewrayPixelPrevious[2]) * 1200 * kScreensizeFactor;
			}
		}
		
		if (MouseCheckButtonReleased(mb_left) || !m_active)
		{
			m_dragX = false;
			m_dragY = false;
			m_dragZ = false;
		}
		
		// Update the visuals
		meshb_BeginEdit(m_mesh);
			if (m_active)
			{
				var xcolor = merge_color(c_red, c_white, m_dragX ? 1.0 : (m_mouseOverX ? 0.7 : 0.0));
				MeshbAddLine(m_mesh, xcolor, kBorderExpand, kScreenLength*2, new Vector3(1, 0, 0), new Vector3(x-kScreenLength,y,z));
				MeshbAddBillboardTriangle(m_mesh, xcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(1, 0, 0), new Vector3(x + kAxisLength,y,z));
				MeshbAddBillboardTriangle(m_mesh, xcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(-1, 0, 0), new Vector3(x - kAxisLength,y,z));
				var ycolor = merge_color(c_midgreen, c_white, m_dragY ? 1.0 : (m_mouseOverY ? 0.7 : 0.0));
				MeshbAddLine(m_mesh, ycolor, kBorderExpand, kScreenLength*2, new Vector3(0, 1, 0), new Vector3(x,y-kScreenLength,z));
				MeshbAddBillboardTriangle(m_mesh, ycolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, 1, 0), new Vector3(x,y + kAxisLength,z));
				MeshbAddBillboardTriangle(m_mesh, ycolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, -1, 0), new Vector3(x,y - kAxisLength,z));
				var zcolor = merge_color(c_midblue, c_white, m_dragZ ? 1.0 : (m_mouseOverZ ? 0.7 : 0.0));
				MeshbAddLine(m_mesh, zcolor, kBorderExpand, kScreenLength*2, new Vector3(0, 0, 1), new Vector3(x,y,z-kScreenLength));
				MeshbAddBillboardTriangle(m_mesh, zcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, 0, 1), new Vector3(x,y,z + kAxisLength));
				MeshbAddBillboardTriangle(m_mesh, zcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, 0, -1), new Vector3(x,y,z - kAxisLength));
			
				/*var xycolor = c_yellow;
				MeshbAddQuad(m_mesh, xycolor, new Vector3(kArrowHalfsize * 2, 0, 0), new Vector3(0, kArrowHalfsize * 2, 0), new Vector3(x + 4,y + 4,z));
				//MeshbAddBillboardTriangle(m_mesh, xycolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0.707, 0.707, 0), new Vector3(x + kAxisLength,y + kAxisLength,z));
				//MeshbAddBillboardTriangle(m_mesh, xycolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0.707, -0.707, 0), new Vector3(x + kAxisLength,y - kAxisLength,z));
				//MeshbAddBillboardTriangle(m_mesh, xycolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(-0.707, 0.707, 0), new Vector3(x - kAxisLength,y + kAxisLength,z));
				//MeshbAddBillboardTriangle(m_mesh, xycolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(-0.707, -0.707, 0), new Vector3(x - kAxisLength,y - kAxisLength,z));
				
				var xzcolor = c_fuchsia;
				//MeshbAddBillboardTriangle(m_mesh, xzcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0.707, 0, 0.707), new Vector3(x + kAxisLength,y,z + kAxisLength));
				//MeshbAddBillboardTriangle(m_mesh, xzcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0.707, 0, -0.707), new Vector3(x + kAxisLength,y,z - kAxisLength));
				//MeshbAddBillboardTriangle(m_mesh, xzcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(-0.707, 0, 0.707), new Vector3(x - kAxisLength,y,z + kAxisLength));
				//MeshbAddBillboardTriangle(m_mesh, xzcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(-0.707, 0, -0.707), new Vector3(x - kAxisLength,y,z - kAxisLength));
				
				var yzcolor = c_aqua;
				//MeshbAddBillboardTriangle(m_mesh, yzcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, 0.707, 0.707), new Vector3(x,y + kAxisLength,z + kAxisLength));
				//MeshbAddBillboardTriangle(m_mesh, yzcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, 0.707, -0.707), new Vector3(x,y + kAxisLength,z - kAxisLength));
				//MeshbAddBillboardTriangle(m_mesh, yzcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, -0.707, 0.707), new Vector3(x,y - kAxisLength,z + kAxisLength));
				//MeshbAddBillboardTriangle(m_mesh, yzcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, -0.707, -0.707), new Vector3(x,y - kAxisLength,z - kAxisLength));
				*/
			}
			else
			{
				MeshbAddLine(m_mesh, c_gray, kBorderExpand, kScreenLength*2, new Vector3(1, 0, 0), new Vector3(x-kScreenLength,y,z));
				MeshbAddLine(m_mesh, c_gray, kBorderExpand, kScreenLength*2, new Vector3(0, 1, 0), new Vector3(x,y-kScreenLength,z));
				MeshbAddLine(m_mesh, c_gray, kBorderExpand, kScreenLength*2, new Vector3(0, 0, 1), new Vector3(x,y,z-kScreenLength));
			}
		meshb_End(m_mesh);
	};
	
	Draw = function()
	{
		var last_shader = drawShaderGet();
		var last_ztest = gpu_get_zfunc();
		var last_zwrite = gpu_get_zwriteenable();
			
		gpu_set_zwriteenable(false);
			
		drawShaderSet(sh_editorFlatShaded);
			
		gpu_set_zfunc(cmpfunc_greater);
		shader_set_uniform_f(global.m_editorFlatShaded_uFlatColor, 0.5, 0.5, 0.5, 1.0);
		vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
			
		gpu_set_zfunc(last_ztest);
		shader_set_uniform_f(global.m_editorFlatShaded_uFlatColor, 1.0, 1.0, 1.0, 1.0);
		vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
			
		drawShaderSet(last_shader);
		gpu_set_zwriteenable(last_zwrite);
	};
}

/// @function AEditorGizmoPointRotate() constructor
/// @desc Editor gizmo for rotating objects around.
function AEditorGizmoPointRotate() : AEditorGizmoPointMove() constructor
{
	xrotation = 0;
	yrotation = 0;
	zrotation = 0;
	
	Step = function()
	{
		// Calculate the sizing based on the distance to the gizmo:
		var kScreensizeFactor = CalculateScreensizeFactor();
		var kBorderExpand = 1 * kScreensizeFactor;
		var kAxisLength = 32 * kScreensizeFactor;
		var kArrowHalfsize = 5 * kScreensizeFactor;
		var kInnerWidth = 8 * kScreensizeFactor;
		var kInnerLength = kAxisLength - kInnerWidth;
		
		var pixelX = m_editor.uPosition - GameCamera.view_x;
		var pixelY = m_editor.vPosition - GameCamera.view_y;
		
		// Get a ray
		var rayStart = new Vector3(o_Camera3D.x, o_Camera3D.y, o_Camera3D.z);
		var rayDir = Vector3FromArray(o_Camera3D.viewToRay(pixelX, pixelY));
		
		// Do some collision checks for mousing over the axes
		m_mouseOverX = false;
		m_mouseOverY = false;
		m_mouseOverZ = false;
		
		if (MouseAvailable())
		{
			// Sort these checks by screen depth
			var depthX = o_Camera3D.positionToView(x + kAxisLength, y, z)[2];
			var depthY = o_Camera3D.positionToView(x, y + kAxisLength, z)[2];
			var depthZ = o_Camera3D.positionToView(x, y, z + kAxisLength)[2];
		
			var check_depthOrder = [[0, depthX], [1, depthY], [2, depthZ]];
			if (check_depthOrder[0][1] > check_depthOrder[2][1]) CE_ArraySwap(check_depthOrder, 0, 2);
			if (check_depthOrder[0][1] > check_depthOrder[1][1]) CE_ArraySwap(check_depthOrder, 0, 1);
			if (check_depthOrder[1][1] > check_depthOrder[2][1]) CE_ArraySwap(check_depthOrder, 1, 2);
		
			// Check collision with each axis, finding closest one
			var min_hit_distance = null;
			for (var check_index = 0; check_index < 3; ++check_index)
			{
				var hasHit = false;
			
				var check_orderLookup = check_depthOrder[check_index][0];
				if (check_orderLookup == 0)
				{
					hasHit = raycast4_box(new Vector3(x - 2, y - kAxisLength, z - kAxisLength), new Vector3(x + 2, y + kAxisLength, z + kAxisLength), rayStart, rayDir);
				}
				if (check_orderLookup == 1)
				{
					hasHit = raycast4_box(new Vector3(x - kAxisLength, y - 2, z - kAxisLength), new Vector3(x + kAxisLength, y + 2, z + kAxisLength), rayStart, rayDir);
				}
				if (check_orderLookup == 2)
				{
					hasHit = raycast4_box(new Vector3(x - kAxisLength, y - kAxisLength, z - 2), new Vector3(x + kAxisLength, y + kAxisLength, z + 2), rayStart, rayDir);
				}
			
				if (hasHit)
				{
					if (min_hit_distance == null || raycast4_get_hit_distance() < min_hit_distance)
					{
						min_hit_distance = raycast4_get_hit_distance();
						m_mouseOverX = false;
						m_mouseOverY = false;
						m_mouseOverZ = false;
						if (check_orderLookup == 0)
							m_mouseOverX = true;
						else if (check_orderLookup == 1)
							m_mouseOverY = true;
						else if (check_orderLookup == 2)
							m_mouseOverZ = true;
					}
				}
			}
		}
		
		// Update active state based on editor using camera
		if (m_editor.toolCurrent == kEditorToolCamera)
		{
			m_active = false;
		}
		else
		{
			m_active = true;
		}
		
		// Update click states
		if (MouseCheckButtonPressed(mb_left))
		{
			if (m_mouseOverX)
				m_dragX = true;
			else if (m_mouseOverY)
				m_dragY = true;
			else if (m_mouseOverZ)
				m_dragZ = true;
		}
		
		if (m_dragX || m_dragY || m_dragZ)
		{
			if (m_dragX)
			{
				xrotation += (m_editor.viewrayPixel[0] - m_editor.viewrayPixelPrevious[0]) * 1200 * kScreensizeFactor;
			}
			if (m_dragY)
			{
				yrotation += (m_editor.viewrayPixel[1] - m_editor.viewrayPixelPrevious[1]) * 1200 * kScreensizeFactor;
			}
			if (m_dragZ)
			{
				zrotation += (m_editor.viewrayPixel[2] - m_editor.viewrayPixelPrevious[2]) * 1200 * kScreensizeFactor;
			}
		}
		
		if (MouseCheckButtonReleased(mb_left) || !m_active)
		{
			m_dragX = false;
			m_dragY = false;
			m_dragZ = false;
		}
		
		// If dragging, override the hover states for rendering
		if (m_dragX)
		{
			m_mouseOverX = true;
			m_mouseOverY = false;
			m_mouseOverZ = false;
		}
		else if (m_dragY)
		{
			m_mouseOverX = false;
			m_mouseOverY = true;
			m_mouseOverZ = false;
		}
		else if (m_dragZ)
		{
			m_mouseOverX = false;
			m_mouseOverY = false;
			m_mouseOverZ = true;
		}
		
		// Update the visuals
		meshb_BeginEdit(m_mesh);
			if (m_active)
			{
				/*var xcolor = m_mouseOverX ? c_white : c_red;
				MeshbAddLine(m_mesh, xcolor, kBorderExpand, kAxisLength, new Vector3(1, 0, 0), new Vector3(x,y,z));
				MeshbAddBillboardTriangle(m_mesh, xcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(1, 0, 0), new Vector3(x + kAxisLength,y,z));
				var ycolor = m_mouseOverY ? c_white : c_midgreen;
				MeshbAddLine(m_mesh, ycolor, kBorderExpand, kAxisLength, new Vector3(0, 1, 0), new Vector3(x,y,z));
				MeshbAddBillboardTriangle(m_mesh, ycolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, 1, 0), new Vector3(x,y + kAxisLength,z));
				var zcolor = m_mouseOverZ ? c_white : c_midblue;
				MeshbAddLine(m_mesh, zcolor, kBorderExpand, kAxisLength, new Vector3(0, 0, 1), new Vector3(x,y,z));
				MeshbAddBillboardTriangle(m_mesh, zcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, 0, 1), new Vector3(x,y,z + kAxisLength));*/
				
				
				var kAngleDiv = 180 / 10;
				
				var kAngleMinZ = (m_editor.viewrayForward[1] > 0) ? 0 : 180;
				var kAngleMaxZ = kAngleMinZ + 180;
				var zcolor = m_mouseOverZ ? c_white : c_midblue;
				
				// Draw the Z rotation axes
				for (var i = kAngleMinZ; i < kAngleMaxZ; i += kAngleDiv)
				{
					if (m_mouseOverZ)
					{
						MeshbAddLine(
							m_mesh, c_midblue,
							kBorderExpand * 0.5,
							kInnerLength * 2 * pi * (kAngleDiv / 360),
							new Vector3(lengthdir_x(1, i + 90 + kAngleDiv * 0.5), lengthdir_y(1, i + 90 + kAngleDiv * 0.5), 0),
							new Vector3(x + lengthdir_x(kInnerLength, i), y + lengthdir_y(kInnerLength, i), z)
							);
					}
					MeshbAddLine(
						m_mesh, zcolor,
						kBorderExpand * 0.5,
						kAxisLength * 2 * pi * (kAngleDiv / 360),
						new Vector3(lengthdir_x(1, i + 90 + kAngleDiv * 0.5), lengthdir_y(1, i + 90 + kAngleDiv * 0.5), 0),
						new Vector3(x + lengthdir_x(kAxisLength, i), y + lengthdir_y(kAxisLength, i), z)
						);
				}
				
				var kAngleMinX = (m_editor.viewrayForward[2] > 0) ? 0 : 180;
				var kAngleMaxX = kAngleMinX + 180;
				var xcolor = m_mouseOverX ? c_white : c_red;
				
				// Draw the X rotation axes
				for (var i = kAngleMinX; i < kAngleMaxX; i += kAngleDiv)
				{
					if (m_mouseOverX)
					{
						MeshbAddLine(
							m_mesh, c_red,
							kBorderExpand * 0.5,
							kInnerLength * 2 * pi * (kAngleDiv / 360),
							new Vector3(0, lengthdir_x(1, i + 90 + kAngleDiv * 0.5), lengthdir_y(1, i + 90 + kAngleDiv * 0.5)),
							new Vector3(x, y + lengthdir_x(kInnerLength, i), z + lengthdir_y(kInnerLength, i))
							);
					}
					MeshbAddLine(
						m_mesh, xcolor,
						kBorderExpand * 0.5,
						kAxisLength * 2 * pi * (kAngleDiv / 360),
						new Vector3(0, lengthdir_x(1, i + 90 + kAngleDiv * 0.5), lengthdir_y(1, i + 90 + kAngleDiv * 0.5)),
						new Vector3(x, y + lengthdir_x(kAxisLength, i), z + lengthdir_y(kAxisLength, i))
						);
				}
				
				var kAngleMinY = (m_editor.viewrayForward[0] > 0) ? 0 : 180;
				var kAngleMaxY = kAngleMinY + 180;
				var ycolor = m_mouseOverY ? c_white : c_midgreen;
				
				// Draw the Z rotation axes
				for (var i = kAngleMinY; i < kAngleMaxY; i += kAngleDiv)
				{
					if (m_mouseOverY)
					{
						MeshbAddLine(
							m_mesh, c_midgreen,
							kBorderExpand * 0.5,
							kInnerLength * 2 * pi * (kAngleDiv / 360),
							new Vector3(lengthdir_y(1, i + 90 + kAngleDiv * 0.5), 0, lengthdir_x(1, i + 90 + kAngleDiv * 0.5)),
							new Vector3(x + lengthdir_y(kInnerLength, i), y, z + lengthdir_x(kInnerLength, i))
							);
					}
					MeshbAddLine(
						m_mesh, ycolor,
						kBorderExpand * 0.5,
						kAxisLength * 2 * pi * (kAngleDiv / 360),
						new Vector3(lengthdir_y(1, i + 90 + kAngleDiv * 0.5), 0, lengthdir_x(1, i + 90 + kAngleDiv * 0.5)),
						new Vector3(x + lengthdir_y(kAxisLength, i), y, z + lengthdir_x(kAxisLength, i))
						);
				}
			}
			else
			{
				MeshbAddLine(m_mesh, c_gray, kBorderExpand, kAxisLength, new Vector3(1, 0, 0), new Vector3(x,y,z));
				MeshbAddLine(m_mesh, c_gray, kBorderExpand, kAxisLength, new Vector3(0, 1, 0), new Vector3(x,y,z));
				MeshbAddLine(m_mesh, c_gray, kBorderExpand, kAxisLength, new Vector3(0, 0, 1), new Vector3(x,y,z));
			}
		meshb_End(m_mesh);
	};
}