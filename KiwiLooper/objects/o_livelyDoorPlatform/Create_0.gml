/// @description Make mesh

event_inherited();

// Set up initial state
opening = false;
closing = false;

openstate = 0.0;
doorheight = 16;
startz = z;

// Update mesh again
m_updateMesh();
