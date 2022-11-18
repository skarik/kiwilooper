function controlForward(targetControl, sourceControl)
{
	targetControl.value = sourceControl.value;
	targetControl.previous = sourceControl.previous;
	
	targetControl.down = sourceControl.down;
	targetControl.released = sourceControl.released;
	targetControl.pressed = sourceControl.pressed;
}