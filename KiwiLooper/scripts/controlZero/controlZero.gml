/// @function controlZero(clear_all)
/// @description Zero out inputs
/// @param clear_all {boolean} If true, re-inits entire state.
function controlZero(argument0) {
	if (argument0 == false)
	{
		xAxis.value = 0.0;
		yAxis.value = 0.0;
		zAxis.value = 0.0;
	
		uAxis.value = 0.0;
		vAxis.value = 0.0;
		wAxis.value = 0.0;

		itemUseButton.value = 0.0;
		atkButton.value = 0.0;
		useButton.value = 0.0;
		dodgeButton.value = 0.0;
		keyItemUseButton.value = 0.0;
		runeButton.value = 0.0;
		journalButton.value = 0.0;
		yButton.value = 0.0;
		itemPrevButton.value = 0.0;
		itemNextButton.value = 0.0;
		itemUnequipButton.value = 0.0;
		itemsButton.value = 0.0;
		selectButton.value = 0.0;
		actUiButton.value = 0.0;
		cancelButton.value = 0.0;
		prevUiButton.value = 0.0;
		nextUiButton.value = 0.0;
	
		belt1Button.value = 0.0;
		belt2Button.value = 0.0;
		belt3Button.value = 0.0;
		belt4Button.value = 0.0;
		belt5Button.value = 0.0;
		belt6Button.value = 0.0;
	}
	else
	{
		var l_uvPositionStyle = uvPositionStyle;
	
		controlCleanup();
		controlInit();
	
		uvPositionStyle = l_uvPositionStyle;
	}


}
