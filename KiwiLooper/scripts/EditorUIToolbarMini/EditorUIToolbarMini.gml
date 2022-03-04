/// @function AToolbarMini() constructor
/// @notes A toolbar for rendering the tiny horizontal general menu.
function AToolbarMini() : AToolbarTop() constructor
{
	static kButtonSize		= 13;
	static kButtonPadding	= 1;
	
	static cx = 0;
	static cy = 0;
	static cz = 0;
	static c3d = false;
	static cvis = false;
	
	static _Parent_Step = Step;
	static Step = function(mouseX, mouseY)
	{
		// Update position
		if (cvis)
		{
			if (c3d)
			{
				var pos = o_Camera3D.positionToView(cx, cy, cz);
				if (pos[2] > 0)
				{
					UpdatePosition(pos[0], pos[1]);
				}
				else
				{
					UpdatePosition(-10000, -10000);
				}
			}
			else
			{
				UpdatePosition(cx, cy);
			}
		}
		
		// Update step
		_Parent_Step(mouseX, mouseY);
	}
	
	static UpdatePosition = function(center_x, center_y)
	{
		x = round(center_x - m_elementsWidth / 2);
		y = round(center_y + kButtonSize + 4);
	}
	
	static SetCenterPosition = function(n_x, n_y)
	{
		cx = n_x; 
		cy = n_y;
		c3d = false;
		cvis = true;
	}
	static SetCenterPosition3D = function(n_x, n_y, n_z)
	{
		cx = n_x;
		cy = n_y;
		cz = n_z;
		c3d = true;
		cvis = true;
	}
	static Hide = function()
	{
		cvis = false;
		
		// Ensure is offscreen
		x = -100000;
		y = -100000;
	}
	static Show = function()
	{
		cvis = true;
	}
	
	static Initialize = function()
	{
		CE_ArrayForEach(m_elements, function(element, index) { delete element; });
		
		m_elements = [];
		m_elementsCount = 0;
	}
}