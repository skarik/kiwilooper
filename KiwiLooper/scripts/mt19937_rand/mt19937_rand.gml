function mt19937_rand() {
#macro UPPER_MASK		0x80000000
#macro LOWER_MASK		0x7fffffff
#macro TEMPERING_MASK_B	0x9d2c5680
#macro TEMPERING_MASK_C	0xefc60000
#macro LIMITING_MASK	0xffffffff

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
