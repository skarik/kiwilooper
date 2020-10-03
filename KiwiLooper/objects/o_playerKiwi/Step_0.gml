/// @description Run input

PlayerControl_Step();

// Run the normal character step
event_inherited();

// Update camera after the motion has been done
PlayerControl_UpdateCamera();