if (singleton_this()) exit;

persistent = true;

/*music = [];
music_filename = [];
music_creation_time = [];*/

faudioInitialize(1);
faudioSetSoundSpeed(1125 * 10 * 2); // Assuming each 10 pixels is about a foot + the coolness factor of 3

mainListener = faudioListenerCreate();


/*
// Spinwait for the debugger to attach....
var time = get_timer();
while (get_timer() - time < 10 * 1000 * 1000)
{
	; // Speen
}*/