if (singleton_this()) exit; // Make this object a singleton

// This motherfucker best be alive at all times
persistent = true;

// Set up local variables
unscaled_dt = 0;
dt = 0;
scale = 1.0;
time = 0.0;

// Aliases
deltaTime = 0;
unscaledDeltaTime = 0;