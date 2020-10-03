/// smoothstep(x)
function smoothstep(argument0) {
	//
	//  Returns 0 when (x < a), 1 when (x >= b), a smooth transition
	//  from 0 to 1 otherwise, or (-1) on error (a == b).
	//
	//      a           upper bound, real
	//      b           lower bound, real
	//      x           value, real
	//
	/// GMLscripts.com/license
	{
	    var p;
	    if (argument0 < 0) return 0;
	    if (argument0 > 1) return 1;
	    p = argument0;
	    return (p * p * (3 - 2 * p));
	}


}
