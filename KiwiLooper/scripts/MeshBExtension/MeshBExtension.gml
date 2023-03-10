///@function MeshbAddLine(mesh, color, width, length, normal, position)
function MeshbAddLine(mesh, color, width, length, normal, position)
{
	MeshbAddLine2(mesh, color, 1.0, width, length, normal, position);
};
///@function MeshbAddLine2(mesh, color, alpha, width, length, normal, position)
function MeshbAddLine2(mesh, color, alpha, width, length, normal, position)
{
	// Get the X and Y alternates to the normal
	var cross_x, cross_y;
	cross_x = normal.cross(new Vector3(1, 0, 0));
	if (cross_x.sqrMagnitude() <= KINDA_SMALL_NUMBER)
	{
		cross_y = normal.cross(new Vector3(0, 1, 0));
		cross_x = cross_y.cross(normal);
	}
	else
	{
		cross_y = cross_x.cross(normal);
	}
	cross_x.normalize();
	cross_y.normalize();
		
	// Add the X-alternate first
	meshb_AddQuad(mesh, [
		new MBVertex(
			position.add(cross_x.multiply(width)),
			color, alpha,
			new Vector2(0.5, -0.5),
			normal),
		new MBVertex(
			position.add(cross_x.multiply(width).add(normal.multiply(length))),
			color, alpha,
			new Vector2(0.5, -0.5),
			normal),
		new MBVertex(
			position.add(cross_x.multiply(-width)),
			color, alpha,
			new Vector2(0.5, 0.5),
			normal),
		new MBVertex(
			position.add(cross_x.multiply(-width).add(normal.multiply(length))),
			color, alpha,
			new Vector2(0.5, 0.5),
			normal),
		]);
	// Add the Y-alternate first
	meshb_AddQuad(mesh, [
		new MBVertex(
			position.add(cross_y.multiply(width)),
			color, alpha,
			new Vector2(0.5, -0.5),
			normal),
		new MBVertex(
			position.add(cross_y.multiply(width).add(normal.multiply(length))),
			color, alpha,
			new Vector2(0.5, -0.5),
			normal),
		new MBVertex(
			position.add(cross_y.multiply(-width)),
			color, alpha,
			new Vector2(0.5, 0.5),
			normal),
		new MBVertex(
			position.add(cross_y.multiply(-width).add(normal.multiply(length))),
			color, alpha,
			new Vector2(0.5, 0.5),
			normal),
		]);
};
///@function MeshbAddLine3(mesh, color, alpha, width, length, normal, position, uvs)
function MeshbAddLine3(mesh, color, alpha, width, length, normal, position, uvs)
{
	// Get the X and Y alternates to the normal
	var cross_x, cross_y;
	cross_x = normal.cross(new Vector3(1, 0, 0));
	if (cross_x.sqrMagnitude() <= KINDA_SMALL_NUMBER)
	{
		cross_y = normal.cross(new Vector3(0, 1, 0));
		cross_x = cross_y.cross(normal);
	}
	else
	{
		cross_y = cross_x.cross(normal);
	}
	cross_x.normalize();
	cross_y.normalize();
		
	// Add the X-alternate first
	meshb_AddQuad(mesh, [
		new MBVertex(
			position.add(cross_x.multiply(width)),
			color, alpha,
			(new Vector2(1, 0)).biasUVSelf(uvs),
			normal),
		new MBVertex(
			position.add(cross_x.multiply(width).add(normal.multiply(length))),
			color, alpha,
			(new Vector2(1, 0)).biasUVSelf(uvs),
			normal),
		new MBVertex(
			position.add(cross_x.multiply(-width)),
			color, alpha,
			(new Vector2(1, 1)).biasUVSelf(uvs),
			normal),
		new MBVertex(
			position.add(cross_x.multiply(-width).add(normal.multiply(length))),
			color, alpha,
			(new Vector2(1, 1)).biasUVSelf(uvs),
			normal),
		]);
	// Add the Y-alternate first
	meshb_AddQuad(mesh, [
		new MBVertex(
			position.add(cross_y.multiply(width)),
			color, alpha,
			(new Vector2(1, 0)).biasUVSelf(uvs),
			normal),
		new MBVertex(
			position.add(cross_y.multiply(width).add(normal.multiply(length))),
			color, alpha,
			(new Vector2(1, 0)).biasUVSelf(uvs),
			normal),
		new MBVertex(
			position.add(cross_y.multiply(-width)),
			color, alpha,
			(new Vector2(1, 1)).biasUVSelf(uvs),
			normal),
		new MBVertex(
			position.add(cross_y.multiply(-width).add(normal.multiply(length))),
			color, alpha,
			(new Vector2(1, 1)).biasUVSelf(uvs),
			normal),
		]);
};
///@function MeshbAddBillboardTriangle(mesh, color, width, length, normal, position)
function MeshbAddBillboardTriangle(mesh, color, width, length, normal, position)
{
	var frontface_direction = new Vector3(o_Camera3D.m_viewForward[0], o_Camera3D.m_viewForward[1], o_Camera3D.m_viewForward[2]);
	var cross_x = frontface_direction.cross(normal);
	cross_x.normalize();
		
	meshb_PushVertex(mesh, new MBVertex(
		position.add(cross_x.multiply(width)),
		color, 1.0,
		new Vector2(0.0, 0.0),
		normal));
	meshb_PushVertex(mesh, new MBVertex(
		position.add(cross_x.multiply(-width)),
		color, 1.0,
		new Vector2(0.0, 1.0),
		normal));
	meshb_PushVertex(mesh, new MBVertex(
		position.add(normal.multiply(length)),
		color, 1.0,
		new Vector2(1.0, 0.5),
		normal));
};
	
function MeshbAddBillboardUVs(mesh, color, width, height, uvs, normal, position)
{ 
	var frontface_direction = new Vector3(o_Camera3D.m_viewForward[0], o_Camera3D.m_viewForward[1], o_Camera3D.m_viewForward[2]);
	// TODO: just pull this data from the camera matrix Left and Up itself
	var cross_x = frontface_direction.cross(new Vector3(0, 0, 1));
	var cross_y = frontface_direction.cross(cross_x);
	cross_x.normalize().multiplySelf(width * 0.5);
	cross_y.normalize().multiplySelf(height * 0.5);
		
	meshb_AddQuad(mesh, [
		new MBVertex(
			position.add(cross_x.multiply(1.0)).add(cross_y.multiply(-1.0)),
			color, 1.0,
			(new Vector2(0.0, 0.0)).biasUVSelf(uvs),
			normal),
		new MBVertex(
			position.add(cross_x.multiply(-1.0)).add(cross_y.multiply(-1.0)),
			color, 1.0,
			(new Vector2(1.0, 0.0)).biasUVSelf(uvs),
			normal),
		new MBVertex(
			position.add(cross_x.multiply(1.0)).add(cross_y.multiply(1.0)),
			color, 1.0,
			(new Vector2(0.0, 1.0)).biasUVSelf(uvs),
			normal),
		new MBVertex(
			position.add(cross_x.multiply(-1.0)).add(cross_y.multiply(1.0)),
			color, 1.0,
			(new Vector2(1.0, 1.0)).biasUVSelf(uvs),
			normal),
			]);
};
	
function MeshbAddQuad(mesh, color, xsize, ysize, position)
{
	var normal = xsize.cross(ysize);
	normal.normalize();
		
	meshb_AddQuad(mesh, [
		new MBVertex(
			position,
			color, 1.0,
			new Vector2(0.0, 0.0),
			normal),
		new MBVertex(
			position.add(xsize),
			color, 1.0,
			new Vector2(1.0, 0.0),
			normal),
		new MBVertex(
			position.add(ysize),
			color, 1.0,
			new Vector2(0.0, 1.0),
			normal),
		new MBVertex(
			position.add(xsize).add(ysize),
			color, 1.0,
			new Vector2(1.0, 1.0),
			normal),
		]);
};
	
function MeshbAddQuadUVs(mesh, color, alpha, xsize, ysize, uvs, position)
{
	var normal = xsize.cross(ysize);
	normal.normalize();
		
	meshb_AddQuad(mesh, [
		new MBVertex(
			position,
			color, alpha,
			(new Vector2(0.0, 0.0)).biasUVSelf(uvs),
			normal),
		new MBVertex(
			position.add(xsize),
			color, alpha,
			(new Vector2(1.0, 0.0)).biasUVSelf(uvs),
			normal),
		new MBVertex(
			position.add(ysize),
			color, alpha,
			(new Vector2(0.0, 1.0)).biasUVSelf(uvs),
			normal),
		new MBVertex(
			position.add(xsize).add(ysize),
			color, alpha,
			(new Vector2(1.0, 1.0)).biasUVSelf(uvs),
			normal),
		]);
}
	
///@function MeshbAddArc(mesh, color, width, radius, startAngle, endAngle, angleDiv, planarX, planarY, center)
function MeshbAddArc(mesh, color, width, radius, startAngle, endAngle, angleDiv, planarX, planarY, center)
{
	for (var i = startAngle; i < endAngle; i += angleDiv)
	{
		MeshbAddLine(
			mesh, color,
			width,
			radius * 2 * pi * (angleDiv / 360),
			planarX.multiply(lengthdir_x(1, i + 90 + angleDiv * 0.5)).add(planarY.multiply(lengthdir_y(1, i + 90 + angleDiv * 0.5))),
			center.add(planarX.multiply(lengthdir_x(radius, i))).add(planarY.multiply(lengthdir_y(radius, i)))
			);
	}
}
///@function MeshbAddArc3(mesh, color, alpha, width, radius, startAngle, endAngle, angleDiv, planarX, planarY, center, uvs)
function MeshbAddArc3(mesh, color, alpha, width, radius, startAngle, endAngle, angleDiv, planarX, planarY, center, uvs)
{
	for (var i = startAngle; i < endAngle; i += angleDiv)
	{
		MeshbAddLine3(
			mesh, color, alpha,
			width,
			radius * 2 * pi * (angleDiv / 360),
			planarX.multiply(lengthdir_x(1, i + 90 + angleDiv * 0.5)).add(planarY.multiply(lengthdir_y(1, i + 90 + angleDiv * 0.5))),
			center.add(planarX.multiply(lengthdir_x(radius, i))).add(planarY.multiply(lengthdir_y(radius, i))),
			uvs
			);
	}
}
	
///@function MeshbAddFlatArc(mesh, color, alpha, width, radius, startAngle, endAngle, angleDiv, planarX, planarY, center)
function MeshbAddFlatArc(mesh, color, alpha, width, radius, startAngle, endAngle, angleDiv, planarX, planarY, center)
{
	var normal = planarX.cross(planarY);
	for (var i = startAngle; i < endAngle; i += angleDiv)
	{
		var offset_a = planarX.multiply(lengthdir_x(1, i)).add(planarY.multiply(lengthdir_y(1, i)));
		var offset_b = planarX.multiply(lengthdir_x(1, i + angleDiv)).add(planarY.multiply(lengthdir_y(1, i + angleDiv)));
						
		var u_a = (i - startAngle) / (endAngle - startAngle);
		var u_b = ((i + angleDiv) - startAngle) / (endAngle - startAngle);
						
		meshb_AddQuad(mesh, [
			new MBVertex(
				center.add(offset_a.multiply(radius - width)),
				color, alpha,
				new Vector2(u_a, 0),
				normal),
			new MBVertex(
				center.add(offset_a.multiply(radius)),
				color, alpha,
				new Vector2(u_a, 1),
				normal),
			new MBVertex(
				center.add(offset_b.multiply(radius - width)),
				color, alpha,
				new Vector2(u_b, 0),
				normal),
			new MBVertex(
				center.add(offset_b.multiply(radius)),
				color, alpha,
				new Vector2(u_b, 1),
				normal),
			]);
	}
}

///@function MeshbAddStandingFlatArc(mesh, color, alpha, height, radius, startAngle, endAngle, angleDiv, planarX, planarY, uvs, center)
function MeshbAddStandingFlatArc(mesh, color, alpha, height, radius, startAngle, endAngle, angleDiv, planarX, planarY, uvs, center)
{
	var normal = planarX.cross(planarY);
	var offset_height = new Vector3(0, 0, height);
	//for (var i = startAngle; i < endAngle; i += angleDiv)
	var segment_count = ceil(abs(endAngle - startAngle) / angleDiv);
	for (var i = 0; i < segment_count; ++i)
	{
		var angle_i1 = lerp(startAngle, endAngle, (i+0)/segment_count);
		var angle_i2 = lerp(startAngle, endAngle, (i+1)/segment_count);
		
		var offset_a = planarX.multiply(lengthdir_x(1, angle_i1)).add(planarY.multiply(lengthdir_y(1, angle_i1)));
		var offset_b = planarX.multiply(lengthdir_x(1, angle_i2)).add(planarY.multiply(lengthdir_y(1, angle_i2)));
						
		var u_a = (angle_i1 - startAngle) / (endAngle - startAngle);
		var u_b = (angle_i2 - startAngle) / (endAngle - startAngle);
						
		meshb_AddQuad(mesh, [
			new MBVertex(
				center.add(offset_a.multiply(radius)),
				color, alpha,
				new Vector2(u_a, 0).biasUVSelf(uvs),
				normal),
			new MBVertex(
				center.add(offset_a.multiply(radius)).addSelf(offset_height),
				color, alpha,
				new Vector2(u_a, 1).biasUVSelf(uvs),
				normal),
			new MBVertex(
				center.add(offset_b.multiply(radius)),
				color, alpha,
				new Vector2(u_b, 0).biasUVSelf(uvs),
				normal),
			new MBVertex(
				center.add(offset_b.multiply(radius)).addSelf(offset_height),
				color, alpha,
				new Vector2(u_b, 1).biasUVSelf(uvs),
				normal),
			]);
	}
}