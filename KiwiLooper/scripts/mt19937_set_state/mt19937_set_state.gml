function mt19937_set_state(argument0) {
	var state = argument0;
	array_copy(global.rand_mt, 0, state, 0, STATE_VECTOR_LENGTH);
	global.rand_index = state[STATE_VECTOR_LENGTH];


}
