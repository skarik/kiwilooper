/// @description Insert description here
// You can write your code in this editor
event_inherited();

facingVector = new Vector3(1, 0, 0);
upVector = new Vector3(0, 0, 1);
// Update the vectors for lighting.
UpdateVectors = function()
{
	var forwardAndUp = Vector3ForwardAndUpFromAngles(xrotation, yrotation, zrotation);
	facingVector.copyFrom(forwardAndUp[0]);
	upVector.copyFrom(forwardAndUp[1]);
	delete forwardAndUp[0];
	delete forwardAndUp[1];
	//debugMessage(upVector.toString());
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
