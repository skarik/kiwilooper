/// bouncestep(x)
function bouncestep(argument0) {


	var p;
	if (argument0 < 0) return 0;
	if (argument0 > 1) return 1;
	p = argument0;

	var pct = 0.83;
	var b = (-3*pct)/(2-3*pct);
	var a = 1-b;


	return (a * p * p * p + b * p * p);




}
