/// @function mt19937_init()
/// @description Initializes the Mersenne Twister with a default seed.
function mt19937_init() {
	global.rand_index = -1;
	mt19937_seed(4357);


}
