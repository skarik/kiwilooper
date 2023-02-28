/// @description Insert description here
// You can write your code in this editor
event_inherited();

facingVector = new Vector3(1, 0, 0);
upVector = new Vector3(0, 0, 1);
innerAngleCos = 1.0;
outerAngleCos = 1.0;

// Update the vectors for lighting.
UpdateVectors = function()
{
	// Update vectors
	var forwardAndUp = Vector3ForwardAndUpFromAngles(xrotation, yrotation, zrotation);
	facingVector.copyFrom(forwardAndUp[0]);
	upVector.copyFrom(forwardAndUp[1]);
	delete forwardAndUp[0];
	delete forwardAndUp[1];
	// Z is reversed since Vector3ForwardAndUpFromAngles is used for camera. Fix it.
	facingVector.z = -facingVector.z;
	upVector.z = -upVector.z;
	
	// Update angle precomputation
	innerAngleCos = cos(degtorad(inner_angle));
	outerAngleCos = cos(degtorad(outer_angle));
}

parent_onPostLevelLoad = onPostLevelLoad;
onPostLevelLoad = function() 
{
	parent_onPostLevelLoad();
	UpdateVectors();
}

parent_onEditorStep = onEditorStep;
onEditorStep = function()
{
	parent_onEditorStep();
	UpdateVectors();
};
