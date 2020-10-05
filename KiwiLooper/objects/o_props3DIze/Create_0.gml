/// @description Build all props into a single mesh

var all_layers = layer_get_all();

m_mesh = meshb_Begin();
{
	buildProps = function(layer)
	{
		var elements = layer_get_all_elements(layer);
		for (var i = 0; i < array_length(elements); ++i)
		{
			var element = elements[i];
			var element_type = layer_get_element_type(element);
			if (element_type == layerelementtype_sprite)
			{
				// Build a proper from this element
				buildProp(element);
			}
		}
	};
	
	buildProp = function(element)
	{
		// Each sprite needs fairly specific builders, so we switch-case on the builders
		var element_x = layer_sprite_get_x(element);
		var element_y = layer_sprite_get_y(element);
		var element_z = collision4_get_highest(element_x, element_y, 0);
		var element_sprite = layer_sprite_get_sprite(element);
		var element_index = layer_sprite_get_index(element);
		
		var element_width = sprite_get_width(element_sprite);
		var element_height = sprite_get_height(element_sprite);

		// Default is they make a quad on the ground
		switch (element_sprite)
		{
		case spr_metalBoard:
		case spr_metalScreen0:
		case spr_metalBottleStanding0:
		case spr_metalBody1:
			{
				var uvs = sprite_get_uvs(element_sprite, element_index);
				var scale = new Vector3(0.5 * layer_sprite_get_xscale(element), 0.5 * layer_sprite_get_yscale(element), 1.0);
				var position = new Vector3(element_x, element_y, element_z);
				var angle = layer_sprite_get_angle(element);
				
				var collider = inew(ob_propCollider);
					collider.x = element_x;
					collider.y = element_y;
					collider.z = element_z;
					collider.height = element_height;
					collider.image_angle = angle;
					collider.image_xscale = layer_sprite_get_xscale(element);
					collider.image_yscale = 4 / element_height;
					collider.sprite_index = element_sprite;
					collider.image_speed = 0;
				
				meshb_AddQuad(m_mesh, [
					new MBVertex(
						(new Vector3(-element_width, 0, element_height)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
						c_white, 1.0,
						(new Vector2(0.0, 0.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3( element_width, 0, element_height)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
						c_white, 1.0,
						(new Vector2(1.0, 0.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3(-element_width, 0, 0)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
						c_white, 1.0,
						(new Vector2(0.0, 1.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3( element_width, 0, 0)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
						c_white, 1.0,
						(new Vector2(1.0, 1.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1))
					]);
			}
			break;
			
		case spr_metalTable0:
		case spr_metalTable1:
		case spr_metalLocker0:
		case spr_metalCrate0:
			{
				var width = element_width;
				var height = element_height;
				var zheight = element_height;
				
				// Just going to hard-code the heights of props to avoid fiddling with the UV tools
				switch (element_sprite)
				{
				case spr_metalTable0:
				case spr_metalTable1:
					zheight = 6;
					break;
				case spr_metalLocker0:
					height = 12;
					break;
				case spr_metalCrate0: break; // Nothing needed to change here!
				}
				
				var scale = new Vector3(width * 0.5 * layer_sprite_get_xscale(element), height * 0.5 * layer_sprite_get_yscale(element), zheight);
				var position = new Vector3(element_x, element_y, element_z);
				var angle = layer_sprite_get_angle(element);
				
				var collider = inew(ob_propCollider);
					collider.x = element_x;
					collider.y = element_y;
					collider.z = element_z;
					collider.height = zheight;
					collider.image_angle = angle;
					collider.image_xscale = layer_sprite_get_xscale(element);
					collider.image_yscale = layer_sprite_get_yscale(element);
					collider.sprite_index = element_sprite;
					collider.image_speed = 0;
				
				// Crop the top texture if needed
				var uvs_top = sprite_get_uvs(element_sprite, 0);
				uvs_top[3] = lerp(uvs_top[1], uvs_top[3], height / element_height);
				// Add the top
				meshb_AddQuad(m_mesh, [
					new MBVertex(
						(new Vector3(-1, -1, 1)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
						c_white, 1.0,
						(new Vector2(0.0, 0.0)).biasUVSelf(uvs_top),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3( 1, -1, 1)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
						c_white, 1.0,
						(new Vector2(1.0, 0.0)).biasUVSelf(uvs_top),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3(-1,  1, 1)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
						c_white, 1.0,
						(new Vector2(0.0, 1.0)).biasUVSelf(uvs_top),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3( 1,  1, 1)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
						c_white, 1.0,
						(new Vector2(1.0, 1.0)).biasUVSelf(uvs_top),
						new Vector3(0, 0, 1))
					]);
					
				// Crop the front texture if needed
				var uvs_front = sprite_get_uvs(element_sprite, 1);
				uvs_front[3] = lerp(uvs_front[1], uvs_front[3], zheight / element_height);
				// Add the front/back
				for (var face = -1; face <= 1; face += 2)
				{
					meshb_AddQuad(m_mesh, [
						new MBVertex(
							(new Vector3(-1, face, 1)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
							c_white, 1.0,
							(new Vector2(0.0, 0.0)).biasUVSelf(uvs_front),
							(new Vector3(0, face, 0)).rotateZSelf(angle)),
						new MBVertex(
							(new Vector3( 1, face, 1)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
							c_white, 1.0,
							(new Vector2(1.0, 0.0)).biasUVSelf(uvs_front),
							(new Vector3(0, face, 0)).rotateZSelf(angle)),
						new MBVertex(
							(new Vector3(-1, face, 0)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
							c_white, 1.0,
							(new Vector2(0.0, 1.0)).biasUVSelf(uvs_front),
							(new Vector3(0, face, 0)).rotateZSelf(angle)),
						new MBVertex(
							(new Vector3( 1, face, 0)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
							c_white, 1.0,
							(new Vector2(1.0, 1.0)).biasUVSelf(uvs_front),
							(new Vector3(0, face, 0)).rotateZSelf(angle))
						]);
				}
				
				// Crop the left/right texture if needed
				var uvs_side = sprite_get_uvs(element_sprite, min(2, sprite_get_number(element_sprite) - 1));
				uvs_side[3] = lerp(uvs_side[1], uvs_side[3], zheight / element_height);
				// Add the front/back
				for (var face = -1; face <= 1; face += 2)
				{
					meshb_AddQuad(m_mesh, [
						new MBVertex(
							(new Vector3(face, -1, 1)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
							c_white, 1.0,
							(new Vector2(0.0, 0.0)).biasUVSelf(uvs_side),
							(new Vector3(face, 0, 0)).rotateZSelf(angle)),
						new MBVertex(
							(new Vector3(face,  1, 1)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
							c_white, 1.0,
							(new Vector2(1.0, 0.0)).biasUVSelf(uvs_side),
							(new Vector3(face, 0, 0)).rotateZSelf(angle)),
						new MBVertex(
							(new Vector3(face, -1, 0)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
							c_white, 1.0,
							(new Vector2(0.0, 1.0)).biasUVSelf(uvs_side),
							(new Vector3(face, 0, 0)).rotateZSelf(angle)),
						new MBVertex(
							(new Vector3(face,  1, 0)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
							c_white, 1.0,
							(new Vector2(1.0, 1.0)).biasUVSelf(uvs_side),
							(new Vector3(face, 0, 0)).rotateZSelf(angle))
						]);
				}
			}
			break;
		default:
			{
				var uvs = sprite_get_uvs(element_sprite, element_index);
				var scale = new Vector3(0.5 * layer_sprite_get_xscale(element), 0.5 * layer_sprite_get_yscale(element), 1.0);
				var position = new Vector3(element_x, element_y, element_z);
				var angle = layer_sprite_get_angle(element);
				
				var zoffset = 0.2;
				// Hard code offsets for sprites to fix z-fighting
				switch (element_sprite)
				{
				case spr_metalBed0:
					zoffset = 0.4;
					break;
				case spr_metalBottleGround0:
					zoffset = 1.0;
					break;
				}
				
				meshb_AddQuad(m_mesh, [
					new MBVertex(
						(new Vector3(-element_width, -element_height, zoffset)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
						c_white, 1.0,
						(new Vector2(0.0, 0.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3( element_width, -element_height, zoffset)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
						c_white, 1.0,
						(new Vector2(1.0, 0.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3(-element_width,  element_height, zoffset)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
						c_white, 1.0,
						(new Vector2(0.0, 1.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3( element_width,  element_height, zoffset)).multiplyComponentSelf(scale).rotateZSelf(angle).addSelf(position),
						c_white, 1.0,
						(new Vector2(1.0, 1.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1))
					]);
			}
			break;
		}
	}
	
	// Find prop layers
	for (var i = 0; i < array_length(all_layers); ++i)
	{
		var current_layer = all_layers[i];
	
		var layer_name = layer_get_name(current_layer);
		var layer_name_search_position = string_pos("props", layer_name);
		if (layer_name_search_position != 0)
		{
			buildProps(current_layer);
		}
	}
}
meshb_End(m_mesh);

// Define rendering
m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(spr_metalBed0, 0));
}