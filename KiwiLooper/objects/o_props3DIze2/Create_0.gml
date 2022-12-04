/// @description Build all props into a single mesh

m_propmap = null;
m_mesh = meshb_CreateEmptyMesh();

SetMap = function(propmap)
{
	m_propmap = propmap;
}
BuildMesh = function()
{
	meshb_BeginEdit(m_mesh);

	buildProp = function(prop)
	{
		// Each sprite needs fairly specific builders, so we switch-case on the builders
		var element_width = sprite_get_width(prop.sprite);
		var element_height = sprite_get_height(prop.sprite);

		// Default is they make a quad on the ground
		switch (prop.sprite)
		{
			// Standing quads
		case spr_metalBoard:
		case spr_metalScreen0:
		case spr_metalBottleStanding0:
		case spr_metalBody1:
			{
				var uvs = sprite_get_uvs(prop.sprite, prop.index);
				var scale = new Vector3(0.5 * prop.xscale, 0.5 * prop.yscale, prop.zscale);
				var position = new Vector3(prop.x, prop.y, prop.z);
				var rotation = matrix_build_rotation(prop);
				
				var collider = inew(ob_propCollider);
					collider.x = prop.x;
					collider.y = prop.y;
					collider.z = prop.z;
					collider.height = element_height;
					collider.image_angle = prop.zrotation;
					collider.image_xscale = prop.xscale;
					collider.image_yscale = 4 / element_height;
					collider.sprite_index = prop.sprite;
					collider.image_speed = 0;
				
				meshb_AddQuad(m_mesh, [
					new MBVertex(
						(new Vector3(-element_width, 0, element_height)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
						c_white, 1.0,
						(new Vector2(0.0, 0.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3( element_width, 0, element_height)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
						c_white, 1.0,
						(new Vector2(1.0, 0.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3(-element_width, 0, 0)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
						c_white, 1.0,
						(new Vector2(0.0, 1.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3( element_width, 0, 0)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
						c_white, 1.0,
						(new Vector2(1.0, 1.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1))
					]);
			}
			break;
			
			// Flat cube quads
		case spr_metalTable0:
		case spr_metalTable1:
		case spr_metalLocker0:
		case spr_metalCrate0:
			{
				var width = element_width;
				var height = PropGetYHeight(prop.sprite);
				var zheight = PropGetZHeight(prop.sprite);
				
				var scale = new Vector3(width * 0.5 * prop.xscale, height * 0.5 * prop.yscale, zheight * prop.zscale);
				var position = new Vector3(prop.x, prop.y, prop.z);
				var rotation = matrix_build_rotation(prop);
				
				var collider = inew(ob_propCollider);
					collider.x = prop.x;
					collider.y = prop.y;
					collider.z = prop.z;
					collider.height = zheight;
					collider.image_angle = prop.zrotation;
					collider.image_xscale = prop.xscale;
					collider.image_yscale = prop.yscale;
					collider.sprite_index = prop.sprite;
					collider.image_speed = 0;
				
				// Crop the top texture if needed
				var uvs_top = sprite_get_uvs(prop.sprite, 0);
				uvs_top[3] = lerp(uvs_top[1], uvs_top[3], height / element_height);
				// Add the top
				meshb_AddQuad(m_mesh, [
					new MBVertex(
						(new Vector3(-1, -1, 1)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
						c_white, 1.0,
						(new Vector2(0.0, 0.0)).biasUVSelf(uvs_top),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3( 1, -1, 1)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
						c_white, 1.0,
						(new Vector2(1.0, 0.0)).biasUVSelf(uvs_top),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3(-1,  1, 1)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
						c_white, 1.0,
						(new Vector2(0.0, 1.0)).biasUVSelf(uvs_top),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3( 1,  1, 1)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
						c_white, 1.0,
						(new Vector2(1.0, 1.0)).biasUVSelf(uvs_top),
						new Vector3(0, 0, 1))
					]);
					
				// Crop the front texture if needed
				var uvs_front = sprite_get_uvs(prop.sprite, 1);
				uvs_front[3] = lerp(uvs_front[1], uvs_front[3], zheight / element_height);
				// Add the front/back
				for (var face = -1; face <= 1; face += 2)
				{
					meshb_AddQuad(m_mesh, [
						new MBVertex(
							(new Vector3(-1, face, 1)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
							c_white, 1.0,
							(new Vector2(0.0, 0.0)).biasUVSelf(uvs_front),
							(new Vector3(0, face, 0)).transformAMatrixSelf(rotation)),
						new MBVertex(
							(new Vector3( 1, face, 1)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
							c_white, 1.0,
							(new Vector2(1.0, 0.0)).biasUVSelf(uvs_front),
							(new Vector3(0, face, 0)).transformAMatrixSelf(rotation)),
						new MBVertex(
							(new Vector3(-1, face, 0)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
							c_white, 1.0,
							(new Vector2(0.0, 1.0)).biasUVSelf(uvs_front),
							(new Vector3(0, face, 0)).transformAMatrixSelf(rotation)),
						new MBVertex(
							(new Vector3( 1, face, 0)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
							c_white, 1.0,
							(new Vector2(1.0, 1.0)).biasUVSelf(uvs_front),
							(new Vector3(0, face, 0)).transformAMatrixSelf(rotation))
						]);
				}
				
				// Crop the left/right texture if needed
				var uvs_side = sprite_get_uvs(prop.sprite, min(2, sprite_get_number(prop.sprite) - 1));
				uvs_side[3] = lerp(uvs_side[1], uvs_side[3], zheight / element_height);
				// Add the front/back
				for (var face = -1; face <= 1; face += 2)
				{
					meshb_AddQuad(m_mesh, [
						new MBVertex(
							(new Vector3(face, -1, 1)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
							c_white, 1.0,
							(new Vector2(0.0, 0.0)).biasUVSelf(uvs_side),
							(new Vector3(face, 0, 0)).transformAMatrixSelf(rotation)),
						new MBVertex(
							(new Vector3(face,  1, 1)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
							c_white, 1.0,
							(new Vector2(1.0, 0.0)).biasUVSelf(uvs_side),
							(new Vector3(face, 0, 0)).transformAMatrixSelf(rotation)),
						new MBVertex(
							(new Vector3(face, -1, 0)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
							c_white, 1.0,
							(new Vector2(0.0, 1.0)).biasUVSelf(uvs_side),
							(new Vector3(face, 0, 0)).transformAMatrixSelf(rotation)),
						new MBVertex(
							(new Vector3(face,  1, 0)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
							c_white, 1.0,
							(new Vector2(1.0, 1.0)).biasUVSelf(uvs_side),
							(new Vector3(face, 0, 0)).transformAMatrixSelf(rotation))
						]);
				}
			}
			break;
			
			// Default cubes
		default:
			{
				var uvs = sprite_get_uvs(prop.sprite, prop.index);
				var scale = new Vector3(0.5 * prop.xscale, 0.5 * prop.yscale, prop.zscale);
				var position = new Vector3(prop.x, prop.y, prop.z);
				var rotation = matrix_build_rotation(prop);
				
				var zoffset = 0.2;
				// Hard code offsets for sprites to fix z-fighting
				switch (prop.sprite)
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
						(new Vector3(-element_width, -element_height, zoffset)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
						c_white, 1.0,
						(new Vector2(0.0, 0.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3( element_width, -element_height, zoffset)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
						c_white, 1.0,
						(new Vector2(1.0, 0.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3(-element_width,  element_height, zoffset)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
						c_white, 1.0,
						(new Vector2(0.0, 1.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1)),
					new MBVertex(
						(new Vector3( element_width,  element_height, zoffset)).multiplyComponentSelf(scale).transformAMatrixSelf(rotation).addSelf(position),
						c_white, 1.0,
						(new Vector2(1.0, 1.0)).biasUVSelf(uvs),
						new Vector3(0, 0, 1))
					]);
			}
			break;
		}
	}
	
	// Naively roll through the prop map and build mesh for all of em
	for (var propIndex = 0; propIndex < m_propmap.GetPropCount(); ++propIndex)
	{
		var prop = m_propmap.GetProp(propIndex);
		buildProp(prop);
	}
	
	meshb_End(m_mesh);
}

// Define rendering
m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(spr_metalBed0, 0));
}