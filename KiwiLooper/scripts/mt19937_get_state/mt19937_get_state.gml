function mt19937_get_state() {
	var state = array_create(STATE_VECTOR_LENGTH + 1);
	array_copy(state, 0, global.rand_mt, 0, STATE_VECTOR_LENGTH);
	state[STATE_VECTOR_LENGTH] = global.rand_index;
	return state;


}
