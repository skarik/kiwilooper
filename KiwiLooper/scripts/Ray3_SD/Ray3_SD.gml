/// @function Ray3(point, direction) struct;
/// @param {Vector3} point
/// @param {Vector3} direction (normalized)
function Ray3(n_point, n_direction) constructor
{
	point = n_point;
	direction = n_direction;
	
	/// @function getClosestOnRay(otherRay)
	static getClosestOnRay = function(otherRay)
	{
		var b_to_a_point	= point.subtract(otherRay.point);
		
		var a_to_b_projection	= self    .direction.dot(otherRay.direction);	// b
		var a_to_cmp_projection	= self    .direction.dot(b_to_a_point);			// d
		var b_to_cmp_projection = otherRay.direction.dot(b_to_a_point);			// e
		
		var cmp_distance = 1.0 - a_to_b_projection * a_to_b_projection; // ??? why does this work?
		
		a_length = 0.0;
		b_length = 0.0;
		if (cmp_distance <= KINDA_SMALL_NUMBER) // Lines are parallel
		{
			a_length = 0.0;
			b_length = (a_to_b_projection > 1.0) ? (a_to_cmp_projection / a_to_b_projection) : (b_to_cmp_projection / 1.0);
		}
		else
		{
			a_length = (a_to_b_projection * b_to_cmp_projection - a_to_cmp_projection) / cmp_distance;
			b_length = (b_to_cmp_projection - a_to_b_projection * a_to_cmp_projection) / cmp_distance;
		}
		
		return {a: a_length, b: b_length};
	}
}