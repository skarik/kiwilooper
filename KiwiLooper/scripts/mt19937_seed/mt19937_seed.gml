function mt19937_seed(argument0) {
#macro STATE_VECTOR_LENGTH	624
#macro STATE_VECTOR_M		397

	var seed = argument0;

	global.rand_mt[0] = seed & 0xffffffff;
	for (global.rand_index = 1; global.rand_index < STATE_VECTOR_LENGTH; global.rand_index++)
	{
		global.rand_mt[global.rand_index] = (6069 * global.rand_mt[global.rand_index - 1]) & 0xffffffff;
	}


}
