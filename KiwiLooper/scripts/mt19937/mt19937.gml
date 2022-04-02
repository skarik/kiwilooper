#macro STATE_VECTOR_LENGTH	624
#macro STATE_VECTOR_M		397

/// @function mt19937_seed(argument0)
/// @description Set up the global mersenne twister state
/// @param {Int} Input seed
function mt19937_seed(seed)
{
	global.rand_mt[0] = seed & 0xffffffff;
	for (global.rand_index = 1; global.rand_index < STATE_VECTOR_LENGTH; global.rand_index++)
	{
		global.rand_mt[global.rand_index] = (6069 * global.rand_mt[global.rand_index - 1]) & 0xffffffff;
	}
}

/// @function mt19937_init()
/// @description Initializes the Mersenne Twister with a default seed.
function mt19937_init()
{
	global.rand_index = -1;
	mt19937_seed(4357);
}

#macro UPPER_MASK		0x80000000
#macro LOWER_MASK		0x7fffffff
#macro TEMPERING_MASK_B	0x9d2c5680
#macro TEMPERING_MASK_C	0xefc60000
#macro LIMITING_MASK	0xffffffff

/// @function mt19937_rand()
/// @description Returns a random number
function mt19937_rand()
{
	var rs = 0;
	var mag = [0x0, 0x9908b0df]; // mag[x] = x * 0x9908b0df for x = 0,1

	// If we're starting in an invalid state, we need to generate a new table:
	if (global.rand_index >= STATE_VECTOR_LENGTH || global.rand_index < 0)
	{
		// generate STATE_VECTOR_LENGTH words at a time
		var kk = 0;
		if (global.rand_index >= STATE_VECTOR_LENGTH+1 || global.rand_index < 0)
		{
			mt19937_seed(4357);
		}
		for (kk = 0; kk < STATE_VECTOR_LENGTH-STATE_VECTOR_M; kk++)
		{
		    rs = (global.rand_mt[kk] & UPPER_MASK) | (global.rand_mt[kk+1] & LOWER_MASK);
		    global.rand_mt[kk] = global.rand_mt[kk+STATE_VECTOR_M] ^ (rs >> 1) ^ mag[rs & 0x1];
		}
		for (; kk < STATE_VECTOR_LENGTH-1; kk++)
		{
		    rs = (global.rand_mt[kk] & UPPER_MASK) | (global.rand_mt[kk+1] & LOWER_MASK);
		    global.rand_mt[kk] = global.rand_mt[kk+(STATE_VECTOR_M-STATE_VECTOR_LENGTH)] ^ (rs >> 1) ^ mag[rs & 0x1];
		}
		rs = (global.rand_mt[STATE_VECTOR_LENGTH-1] & UPPER_MASK) | (global.rand_mt[0] & LOWER_MASK);
		global.rand_mt[STATE_VECTOR_LENGTH-1] = global.rand_mt[STATE_VECTOR_M-1] ^ (rs >> 1) ^ mag[rs & 0x1];
		global.rand_index = 0;
	}

	// Perform the actual randomizing
	rs = global.rand_mt[global.rand_index++];
	rs ^= (rs >> 11);
	rs ^= (rs << 7) & TEMPERING_MASK_B;
	rs ^= (rs << 15) & TEMPERING_MASK_C;
	rs ^= (rs >> 18);

	return rs & LIMITING_MASK;
}

/// @function mt19937_get_state()
function mt19937_get_state()
{
	var state = array_create(STATE_VECTOR_LENGTH + 1);
	array_copy(state, 0, global.rand_mt, 0, STATE_VECTOR_LENGTH);
	state[STATE_VECTOR_LENGTH] = global.rand_index;
	return state;
}

/// @function mt19937_set_state(state)
function mt19937_set_state(state)
{
	array_copy(global.rand_mt, 0, state, 0, STATE_VECTOR_LENGTH);
	global.rand_index = state[STATE_VECTOR_LENGTH];
}

/// @function mt19937_random_range(min, max)
/// @param min : Min value to get (inclusive)
/// @param max : Max value to get (exclusive)
/// @description Returns a random double value in the given range.
function mt19937_random_range(minimum, maximum)
{
	var random_value = mt19937_rand();

	var delta = maximum - minimum;
	var random_value_rescaled = (random_value / (0xffffffff + 1.0)) * delta;

	return random_value_rescaled + minimum;
}
