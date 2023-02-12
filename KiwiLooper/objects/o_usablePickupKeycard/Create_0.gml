/// @description Setup
// Inherit the parent event
event_inherited();

m_priority = 2;

// Set up persistence
PersistentStateExistence();

m_onActivation = function(activatedBy)
{
	if (iexists(activatedBy) && Game_IsPlayer_safe(activatedBy))
	{
		o_playerKiwi.m_inventory.keys[m_lockChannel] = 1;
		if (o_playerKiwi.m_inventory.is_big)
		{
			var item = new AKiwiInventoryItem();
			item.name = "Keycard";
			o_playerKiwi.m_inventory.AddItem(item);
		}
		idelete_delay(this, 0);
	}
}

// Set up mesh
m_mesh = meshb_CreateEmptyMesh();

// Define the sprite update function
m_updateMesh = function()
{
	var width = xscale * sprite_width * 0.5;
	var height = yscale * sprite_height * 0.5;
	
	var uvs = sprite_get_uvs(sprite_index, image_index);
	meshb_BeginEdit(m_mesh);
	meshb_AddQuad(m_mesh, [
		new MBVertex(new Vector3(-width,-height, 0.7), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3( width,-height, 0.7), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3(-width, height, 0.7), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3( width, height, 0.7), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1))
		]);
	meshb_End(m_mesh);
}
m_updateMesh(); // Update mesh now!

m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sprite_index, image_index));
}
