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
	m_mouseOverC = false;
	
	m_dragX = false;
	m_dragY = false;
	m_dragZ = false;
	m_dragC = false; // Is the center circle being dragged? Will toggle X/Y/Z drag depending on mode.
	
	/// @function IsDraggingAny()
	IsDraggingAny = function()
	{
		gml_pragma("forceinline");
		return m_dragX || m_dragY || m_dragZ || m_dragC;
	}
	
	m_active = false;
	
	m_dragStart = [];
	m_dragViewrayStart = [];
	m_snapOffset = [0, 0, 0];
	m_collisionDragOffset = [0, 0, 0];
	
	/// @function GetConsumingMouse()
	GetConsumingMouse = function()
	{
		return IsDraggingAny();
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
		var kArrowHalfsize = 5 * kScreensizeFactor;
		var kScreenLength = 500 * kScreensizeFactor;
		var kCircleRadius = 8 * kScreensizeFactor;
		
		var pixelX = m_editor.uPosition - GameCamera.view_x;
		var pixelY = m_editor.vPosition - GameCamera.view_y;
		
		// Get a ray
		var rayStart = new Vector3(o_Camera3D.x, o_Camera3D.y, o_Camera3D.z);
		var rayDir = Vector3FromArray(o_Camera3D.viewToRay(pixelX, pixelY));
		
		// Do some collision checks for mousing over the axes
		m_mouseOverX = false;
		m_mouseOverY = false;
		m_mouseOverZ = false;
		m_mouseOverC = false;
		
		if (MouseAvailable())
		{
			// Sort these checks by screen depth
			var depthX = o_Camera3D.positionToView(x + kAxisLength, y, z)[2];
			var depthY = o_Camera3D.positionToView(x, y + kAxisLength, z)[2];
			var depthZ = o_Camera3D.positionToView(x, y, z + kAxisLength)[2];
			var depthC = o_Camera3D.positionToView(x, y, z)[2];
		
			var check_depthOrder = [[0, depthX], [1, depthY], [2, depthZ], [3, depthC]];
			if (check_depthOrder[0][1] > check_depthOrder[2][1]) CE_ArraySwap(check_depthOrder, 0, 2);
			if (check_depthOrder[0][1] > check_depthOrder[1][1]) CE_ArraySwap(check_depthOrder, 0, 1);
			if (check_depthOrder[1][1] > check_depthOrder[2][1]) CE_ArraySwap(check_depthOrder, 1, 2);
		
			// Check collision with each axis.
			for (var check_index = 0; check_index < 4; ++check_index)
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
				if (check_orderLookup == 3)
				{
					m_mouseOverC = raycast4_box(new Vector3(x - kCircleRadius, y - kCircleRadius, z - kCircleRadius), new Vector3(x + kCircleRadius, y + kCircleRadius, z + kCircleRadius), rayStart, rayDir);
					if (m_mouseOverC) break;
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
			else if (m_mouseOverC)
				m_dragC = true;
				
			if (m_dragX || m_dragY || m_dragZ || m_dragC)
			{
				m_dragStart = [x, y, z];
				m_dragViewrayStart = CE_ArrayClone(m_editor.viewrayPixel);
			}
		}
		
		var bLocalSnap = m_editor.toolGrid && !m_editor.toolGridTemporaryDisable;
		if (m_dragX || m_dragY || m_dragZ || m_dragC)
		{
			if (m_dragC)
			{
				//TODO: use m_collisionDragOffset
				// Using the camera, raycast against the world
				var l_currentPosition = m_editor.toolWorldValid ? [m_editor.toolWorldX, m_editor.toolWorldY, m_editor.toolWorldZ] : [m_editor.toolFlatX, m_editor.toolFlatY, 0];
				
				x = l_currentPosition[0];
				y = l_currentPosition[1];
				z = l_currentPosition[2];
				
				if (bLocalSnap)
				{
					x = round_nearest(x - m_snapOffset[0], m_editor.toolGridSize) + m_snapOffset[0];
					y = round_nearest(y - m_snapOffset[1], m_editor.toolGridSize) + m_snapOffset[1];
					z = round_nearest(z - m_snapOffset[2], m_editor.toolGridSize) + m_snapOffset[2];
				}
			}
			else if (m_dragX)
			{
				x = m_dragStart[0] + (m_editor.viewrayPixel[0] - m_dragViewrayStart[0]) * 1200 * kScreensizeFactor;
				if (bLocalSnap) x = round_nearest(x - m_snapOffset[0], m_editor.toolGridSize) + m_snapOffset[0];
			}
			else if (m_dragY)
			{
				y = m_dragStart[1] + (m_editor.viewrayPixel[1] - m_dragViewrayStart[1]) * 1200 * kScreensizeFactor;
				if (bLocalSnap) y = round_nearest(y - m_snapOffset[0], m_editor.toolGridSize) + m_snapOffset[1];
			}
			else if (m_dragZ)
			{
				z = m_dragStart[2] + (m_editor.viewrayPixel[2] - m_dragViewrayStart[2]) * 1200 * kScreensizeFactor;
				if (bLocalSnap) z = round_nearest(z - m_snapOffset[0], m_editor.toolGridSize) + m_snapOffset[2];
			}
		}
		
		if (MouseCheckButtonReleased(mb_left) || !m_active)
		{
			m_dragX = false;
			m_dragY = false;
			m_dragZ = false;
			m_dragC = false;
		}
		
		// Update the visuals
		meshb_BeginEdit(m_mesh);
			if (m_active)
			{
				var xshouldfade = (m_dragX || m_dragY || m_dragZ) && !m_dragX;
				var xcolor = merge_color(c_red, c_white, m_dragX ? 1.0 : (m_mouseOverX ? 0.7 : 0.0));
				if (!xshouldfade && !m_dragX)
				{
					MeshbAddLine2(m_mesh, xcolor, 1.0, kBorderExpand, kAxisLength, new Vector3(1, 0, 0), new Vector3(x,y,z));
					MeshbAddBillboardTriangle(m_mesh, xcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(1, 0, 0), new Vector3(x + kAxisLength,y,z));
				}
				else
				{
					MeshbAddLine2(m_mesh, xcolor, xshouldfade ? 0.5 : 1.0, kBorderExpand/2, kScreenLength*2, new Vector3(1, 0, 0), new Vector3(x-kScreenLength,y,z));
				}
				
				var yshouldfade = (m_dragX || m_dragY || m_dragZ) && !m_dragY;
				var ycolor = merge_color(c_midgreen, c_white, m_dragY ? 1.0 : (m_mouseOverY ? 0.7 : 0.0));
				if (!yshouldfade && !m_dragY)
				{
					MeshbAddLine2(m_mesh, ycolor, 1.0, kBorderExpand, kAxisLength, new Vector3(0, 1, 0), new Vector3(x,y,z));
					MeshbAddBillboardTriangle(m_mesh, ycolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, 1, 0), new Vector3(x,y + kAxisLength,z));
				}
				else
				{
					MeshbAddLine2(m_mesh, ycolor, yshouldfade ? 0.5 : 1.0, kBorderExpand/2, kScreenLength*2, new Vector3(0, 1, 0), new Vector3(x,y-kScreenLength,z));
				}
				
				var zshouldfade = (m_dragX || m_dragY || m_dragZ) && !m_dragZ;
				var zcolor = merge_color(c_midblue, c_white, m_dragZ ? 1.0 : (m_mouseOverZ ? 0.7 : 0.0));
				if (!zshouldfade && !m_dragZ)
				{
					MeshbAddLine2(m_mesh, zcolor, 1.0, kBorderExpand, kAxisLength, new Vector3(0, 0, 1), new Vector3(x,y,z));
					MeshbAddBillboardTriangle(m_mesh, zcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, 0, 1), new Vector3(x,y,z + kAxisLength));
				}
				else
				{
					MeshbAddLine2(m_mesh, zcolor, zshouldfade ? 0.5 : 1.0, kBorderExpand/2, kScreenLength*2, new Vector3(0, 0, 1), new Vector3(x,y,z-kScreenLength));
				}
				
				// draw the circle in center
				
				// Create the forward vector
				var cameraDir = Vector3FromArray(o_Camera3D.m_viewForward);
				var cameraTop = Vector3FromArray(o_Camera3D.m_viewUp);
				var cameraSide = cameraDir.cross(cameraTop).normal();
				var ccolor = merge_color(c_yellow, c_white, m_dragC ? 1.0 : (m_mouseOverC ? 0.7 : 0.0));
				MeshbAddArc(m_mesh, ccolor, kBorderExpand, kCircleRadius, 0, 360, 20, cameraSide, cameraTop, new Vector3(x,y,z));
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
	
	m_dragStart = [];
	m_dragViewrayStart = [];
	
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
				
			if (m_dragX || m_dragY || m_dragZ)
			{
				m_dragStart = [x, y, z];
				m_dragViewrayStart = CE_ArrayClone(m_editor.viewrayPixel);
			}
		}
		
		var bLocalSnap = m_editor.toolGrid && !m_editor.toolGridTemporaryDisable;
		if (m_dragX || m_dragY || m_dragZ)
		{
			if (m_dragX)
			{
				x = m_dragStart[0] + (m_editor.viewrayPixel[0] - m_dragViewrayStart[0]) * 1200 * kScreensizeFactor;
				if (bLocalSnap) x = round_nearest(x, m_editor.toolGridSize);
			}
			if (m_dragY)
			{
				y = m_dragStart[1] + (m_editor.viewrayPixel[1] - m_dragViewrayStart[1]) * 1200 * kScreensizeFactor;
				if (bLocalSnap) y = round_nearest(y, m_editor.toolGridSize);
			}
			if (m_dragZ)
			{
				z = m_dragStart[2] + (m_editor.viewrayPixel[2] - m_dragViewrayStart[2]) * 1200 * kScreensizeFactor;
				if (bLocalSnap) z = round_nearest(z, m_editor.toolGridSize);
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
				var xshouldfade = (m_dragX || m_dragY || m_dragZ) && !m_dragX;
				var xcolor = merge_color(c_red, c_white, m_dragX ? 1.0 : (m_mouseOverX ? 0.7 : 0.0));
				MeshbAddLine2(m_mesh, xcolor, xshouldfade ? 0.5 : 1.0, kBorderExpand, kScreenLength*2, new Vector3(1, 0, 0), new Vector3(x-kScreenLength,y,z));
				if (!xshouldfade)
				{
					MeshbAddBillboardTriangle(m_mesh, xcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(1, 0, 0), new Vector3(x + kAxisLength,y,z));
					MeshbAddBillboardTriangle(m_mesh, xcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(-1, 0, 0), new Vector3(x - kAxisLength,y,z));
				}
				
				var yshouldfade = (m_dragX || m_dragY || m_dragZ) && !m_dragY;
				var ycolor = merge_color(c_midgreen, c_white, m_dragY ? 1.0 : (m_mouseOverY ? 0.7 : 0.0));
				MeshbAddLine2(m_mesh, ycolor, yshouldfade ? 0.5 : 1.0, kBorderExpand, kScreenLength*2, new Vector3(0, 1, 0), new Vector3(x,y-kScreenLength,z));
				if (!yshouldfade)
				{
					MeshbAddBillboardTriangle(m_mesh, ycolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, 1, 0), new Vector3(x,y + kAxisLength,z));
					MeshbAddBillboardTriangle(m_mesh, ycolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, -1, 0), new Vector3(x,y - kAxisLength,z));
				}
				
				var zshouldfade = (m_dragX || m_dragY || m_dragZ) && !m_dragZ;
				var zcolor = merge_color(c_midblue, c_white, m_dragZ ? 1.0 : (m_mouseOverZ ? 0.7 : 0.0));
				MeshbAddLine2(m_mesh, zcolor, zshouldfade ? 0.5 : 1.0, kBorderExpand, kScreenLength*2, new Vector3(0, 0, 1), new Vector3(x,y,z-kScreenLength));
				if (!zshouldfade)
				{
					MeshbAddBillboardTriangle(m_mesh, zcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, 0, 1), new Vector3(x,y,z + kAxisLength));
					MeshbAddBillboardTriangle(m_mesh, zcolor, kArrowHalfsize, kArrowHalfsize*2, new Vector3(0, 0, -1), new Vector3(x,y,z - kAxisLength));
				}
				
				// 2D-axis colors
				/*
				var xycolor = c_yellow;
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
				
			if (m_dragX || m_dragY || m_dragZ)
			{
				m_dragStart = [xrotation, yrotation, zrotation];
				m_dragViewrayStart = CE_ArrayClone(m_editor.viewrayPixel);
			}
		}
		
		var bEnableAngleSnaps = keyboard_check(vk_shift);
		var bLocalSnap = bEnableAngleSnaps;//m_editor.toolGrid && !m_editor.toolGridTemporaryDisable;
		if (m_dragX || m_dragY || m_dragZ)
		{
			if (m_dragX)
			{
				xrotation += (m_editor.viewrayPixel[0] - m_editor.viewrayPixelPrevious[0]) * 1200 * kScreensizeFactor;
				if (bLocalSnap) xrotation = round_nearest(xrotation, 15);
			}
			if (m_dragY)
			{
				yrotation += (m_editor.viewrayPixel[1] - m_editor.viewrayPixelPrevious[1]) * 1200 * kScreensizeFactor;
				if (bLocalSnap) yrotation = round_nearest(yrotation, 15);
			}
			if (m_dragZ)
			{
				static kRotateInScreenspace = false; // toggle this
				if (kRotateInScreenspace)
				{
					var l_screenCenter = o_Camera3D.positionToView(x, y, z);
					var l_screenStart = o_Camera3D.positionToView(o_Camera3D.x + m_dragViewrayStart[0], o_Camera3D.y + m_dragViewrayStart[1], o_Camera3D.z + m_dragViewrayStart[2]);
					var l_screenCurrent = o_Camera3D.positionToView(o_Camera3D.x + m_editor.viewrayPixel[0], o_Camera3D.y + m_editor.viewrayPixel[1], o_Camera3D.z + m_editor.viewrayPixel[2]);
					
					zrotation = m_dragStart[2] - angle_difference(
						point_direction(l_screenCenter[0], l_screenCenter[1], l_screenStart[0], l_screenStart[1]),
						point_direction(l_screenCenter[0], l_screenCenter[1], l_screenCurrent[0], l_screenCurrent[1]));
				}
				else
				{
					var rayStart = Vector3FromTranslation(o_Camera3D);
					var rayDirStart = Vector3FromArray(m_dragViewrayStart);
					var rayDirCurrent = Vector3FromArray(m_editor.viewrayPixel);
					// project onto the XY plane
					assert(raycast4_axisplane(kAxisZ, z, rayStart, rayDirStart));
					var l_worldStart = rayStart.add(rayDirStart.multiply(raycast4_get_hit_distance()));
					assert(raycast4_axisplane(kAxisZ, z, rayStart, rayDirCurrent));
					var l_worldCurrent = rayStart.add(rayDirCurrent.multiply(raycast4_get_hit_distance()));
				
					// calculate angle difference in the world
					zrotation = m_dragStart[2] - angle_difference(point_direction(x, y, l_worldStart.x, l_worldStart.y), point_direction(x, y, l_worldCurrent.x, l_worldCurrent.y));
				}
				if (bLocalSnap) zrotation = round_nearest(zrotation, 15);
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
				// Can likely generalize by having an "X" vector and a "Y" vector.
				// ie, z rotation would be x (1,0,0) and y (0,1,0)
				//		x rotation would be x (0,1,0) and y (0,0,1)
				
				var kGizmoCenter = new Vector3(x, y, z);
				var kAngleDiv = 180 / 10;
				
				// Draw order:
				var kAxisListing = [kAxisZ, kAxisX, kAxisY];
				
				// Following listings are in XYZ order:
				var kPlanarListing = [
					[new Vector3(0, 1, 0), new Vector3(0, 0, 1)],
					[new Vector3(0, 0, 1), new Vector3(1, 0, 0)],
					[new Vector3(1, 0, 0), new Vector3(0, 1, 0)],
					];
				var kDragListing = [
					[m_dragX, m_mouseOverX],
					[m_dragY, m_mouseOverY],
					[m_dragZ, m_mouseOverZ],
					];
				var kColorListing = [c_red, c_midgreen, c_midblue];
				
				// Loop through each axis as it's a lot of repeated code
				for (var axisIndex = 0; axisIndex < 3; ++axisIndex)
				{
					var currentAxis = kAxisListing[axisIndex];
					
					var bDrag = kDragListing[currentAxis][0];
					var bMouseOver = kDragListing[currentAxis][1];
					var kPlanarX = kPlanarListing[currentAxis][0];
					var kPlanarY = kPlanarListing[currentAxis][1];
					var bcolor = kColorListing[currentAxis];
					
					var kAngleMin, kAngleMax;
					if (currentAxis == kAxisZ)
					{
						kAngleMin = (m_editor.viewrayForward[1] > 0) ? 0 : 180;
						kAngleMax = kAngleMin + 180;
					}
					else if (currentAxis == kAxisX)
					{
						kAngleMin = (m_editor.viewrayForward[2] > 0) ? 0 : 180;
						kAngleMax = kAngleMin + 180;
					}
					else if (currentAxis == kAxisY)
					{
						kAngleMin = (m_editor.viewrayForward[0] > 0) ? 0 : 180;
						kAngleMax = kAngleMin + 180;
					}
					
					var acolor;
					acolor = bMouseOver ? c_white : bcolor;

					if ((!m_dragX && !m_dragY && !m_dragZ) || bDrag)
					{
						// If we're dragging, we change the angle to be full circle
						if (bDrag)
						{
							kAngleMin = 0;
							kAngleMax = 360;
						}
						
						// Draw the rotation axes
						//if (bMouseOver) MeshbAddArc(m_mesh, acolor, kBorderExpand * 0.5, kInnerLength, kAngleMin, kAngleMax, kAngleDiv, kPlanarX, kPlanarY, kGizmoCenter);
						if (bMouseOver && !bDrag) MeshbAddFlatArc(m_mesh, acolor, 0.5, kAxisLength - kInnerLength, kAxisLength, kAngleMin, kAngleMax, kAngleDiv, kPlanarX, kPlanarY, kGizmoCenter);
						MeshbAddArc(m_mesh, bcolor, kBorderExpand * 0.5, kAxisLength, kAngleMin, kAngleMax, kAngleDiv, kPlanarX, kPlanarY, kGizmoCenter);
						
						if (bDrag)
						{
							MeshbAddArc(m_mesh, bcolor, kBorderExpand * 0.5, kInnerLength, kAngleMin, kAngleMax, kAngleDiv, kPlanarX, kPlanarY, kGizmoCenter);
							
							MeshbAddLine(m_mesh, bcolor, kBorderExpand, kAxisLength - kInnerLength,
								kPlanarX.multiply(lengthdir_x(1, m_dragStart[currentAxis])).add(kPlanarY.multiply(lengthdir_y(1, m_dragStart[currentAxis]))),
								kGizmoCenter.add(kPlanarX.multiply(lengthdir_x(kInnerLength, m_dragStart[currentAxis]))).add(kPlanarY.multiply(lengthdir_y(kInnerLength, m_dragStart[currentAxis])))
								);
								
							var angle = m_dragX ? xrotation : (m_dragY ? yrotation : zrotation);
							var angleDivCount = max(1, ceil(abs(angle - m_dragStart[currentAxis]) / kAngleDiv));
								
							MeshbAddLine(m_mesh, bcolor, kBorderExpand, kAxisLength - kInnerLength,
								kPlanarX.multiply(lengthdir_x(1, angle)).add(kPlanarY.multiply(lengthdir_y(1, angle))),
								kGizmoCenter.add(kPlanarX.multiply(lengthdir_x(kInnerLength, angle))).add(kPlanarY.multiply(lengthdir_y(kInnerLength, angle)))
								);
								
							MeshbAddFlatArc(m_mesh, acolor, 0.5,
								kAxisLength - kInnerLength, kAxisLength,
								min(m_dragStart[currentAxis], angle),
								max(m_dragStart[currentAxis], angle),
								abs(angle - m_dragStart[currentAxis]) / angleDivCount,
								kPlanarX, kPlanarY, kGizmoCenter);
						}
					}
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

/// @function AEditorGizmoPointScale() constructor
/// @desc Editor gizmo for scaling objects around.
function AEditorGizmoPointScale() : AEditorGizmoPointMove() constructor
{
	xrotation = 0;
	yrotation = 0;
	zrotation = 0;
	
	xscale = 1.0;
	yscale = 1.0;
	zscale = 1.0;
	
	bbox = new BBox3(new Vector3(), new Vector3());
	
	Step = function()
	{
		// Calculate the sizing based on the distance to the gizmo:
		var kScreensizeFactor = CalculateScreensizeFactor();
		var kBorderExpand = 0.5 * kScreensizeFactor;
		var kAxisLength = 32 * kScreensizeFactor;
		var kArrowHalfsize = 4 * kScreensizeFactor;
		var kScreenLength = 500 * kScreensizeFactor;
		
		// Setup local XYZ as it's needed for both collisions and gizmos
		var kRotation = matrix_build_rotation(self);
		var kX = (new Vector3(1, 0, 0)).transformAMatrixSelf(kRotation);
		var kY = (new Vector3(0, 1, 0)).transformAMatrixSelf(kRotation);
		var kZ = (new Vector3(0, 0, 1)).transformAMatrixSelf(kRotation);
		var kOffset = bbox.center.transformAMatrix(kRotation);
		
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
				
			if (m_dragX || m_dragY || m_dragZ)
			{
				m_dragStart = [xscale, yscale, zscale];
				m_dragViewrayStart = CE_ArrayClone(m_editor.viewrayPixel);
			}
		}
		
		var bEnableAngleSnaps = keyboard_check(vk_shift);
		var bLocalSnap = bEnableAngleSnaps;//m_editor.toolGrid && !m_editor.toolGridTemporaryDisable;
		if (m_dragX || m_dragY || m_dragZ)
		{
			if (m_dragX)
			{
				xscale = m_dragStart[0] + (m_editor.viewrayPixel[0] - m_dragViewrayStart[0]) * 120 * kScreensizeFactor;
				if (bLocalSnap) xscale = round_nearest(xscale, 0.1);
			}
			if (m_dragY)
			{
				yscale = m_dragStart[1] + (m_editor.viewrayPixel[1] - m_dragViewrayStart[1]) * 120 * kScreensizeFactor;
				if (bLocalSnap) yscale = round_nearest(yscale, 0.1);
			}
			if (m_dragZ)
			{
				zscale = m_dragStart[2] + (m_editor.viewrayPixel[2] - m_dragViewrayStart[2]) * 120 * kScreensizeFactor;
				if (bLocalSnap) zscale = round_nearest(zscale, 0.1);
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
				var kPos = (new Vector3(x, y, z)).add(kOffset);
				
				var xshouldfade = (m_dragX || m_dragY || m_dragZ) && !m_dragX;
				var xcolor = merge_color(c_red, c_white, m_dragX ? 1.0 : (m_mouseOverX ? 0.7 : 0.0));
				if (!xshouldfade)
				{
					MeshbAddBillboardTriangle(m_mesh, xcolor, kArrowHalfsize, kArrowHalfsize*2, kX, kPos.add(kX.multiply(bbox.extents.x)) );
					MeshbAddBillboardTriangle(m_mesh, xcolor, kArrowHalfsize, kArrowHalfsize*2, kX.negate(), kPos.add(kX.multiply(-bbox.extents.x)) );
				}
				
				var yshouldfade = (m_dragX || m_dragY || m_dragZ) && !m_dragY;
				var ycolor = merge_color(c_midgreen, c_white, m_dragY ? 1.0 : (m_mouseOverY ? 0.7 : 0.0));
				if (!yshouldfade)
				{
					MeshbAddBillboardTriangle(m_mesh, ycolor, kArrowHalfsize, kArrowHalfsize*2, kY, kPos.add(kY.multiply(bbox.extents.y)) );
					MeshbAddBillboardTriangle(m_mesh, ycolor, kArrowHalfsize, kArrowHalfsize*2, kY.negate(), kPos.add(kY.multiply(-bbox.extents.y)) );
				}
				
				var zshouldfade = (m_dragX || m_dragY || m_dragZ) && !m_dragZ;
				var zcolor = merge_color(c_midblue, c_white, m_dragZ ? 1.0 : (m_mouseOverZ ? 0.7 : 0.0));
				if (!zshouldfade)
				{
					MeshbAddBillboardTriangle(m_mesh, zcolor, kArrowHalfsize, kArrowHalfsize*2, kZ, kPos.add(kZ.multiply(bbox.extents.z)) );
					MeshbAddBillboardTriangle(m_mesh, zcolor, kArrowHalfsize, kArrowHalfsize*2, kZ.negate(), kPos.add(kZ.multiply(-bbox.extents.z)) );
				}
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
