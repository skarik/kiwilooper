function deadzone_bias(argument0) {
	var val = argument0;
	var deadzone = 0.22;
	var deadzone_top = 0.1;
	var bias = 0.4;
	return biasStep(
		clamp(
			(abs(val) - deadzone) / ((1.0 - deadzone) / (1.0 - deadzone_top)),
			0.0, 1.0 ),
		bias) * sign(val);



}
