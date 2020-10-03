/// @func controlUpdate(clearInputs)
/// @description Update inputs.
/// @param clear_input {boolean} If true, clears all input.
function controlUpdate(argument0) {
	if (argument0 == false && !(Debug.on && iexists(o_debugCmdline) && o_debugCmdline.focused))
	{
		//_controlStructUpdate(xAxis, -keyboard_check(ord("A")) + keyboard_check(ord("D")) + deadzone_bias(gamepad_axis_value(0, gp_axislh)));
		//_controlStructUpdate(yAxis, -keyboard_check(ord("W")) + keyboard_check(ord("S")) + deadzone_bias(gamepad_axis_value(0, gp_axislv)));
		//_controlStructUpdate(zAxis, keyboard_check(vk_space));
		_controlStructUpdate(xAxis, -controlParseAndPoll(Settings.ctMoveLeft) + controlParseAndPoll(Settings.ctMoveRight));
		_controlStructUpdate(yAxis, -controlParseAndPoll(Settings.ctMoveUp) + controlParseAndPoll(Settings.ctMoveDown));
		_controlStructUpdate(zAxis, controlParseAndPoll(Settings.ctJump));
	
		//_controlStructUpdate(uAxis, -keyboard_check(vk_left) + keyboard_check(vk_right));
		//_controlStructUpdate(vAxis, -keyboard_check(vk_up) + keyboard_check(vk_down));
		//_controlStructUpdate(wAxis, keyboard_check(vk_space));
		_controlStructUpdate(uAxis, -controlParseAndPoll(Settings.ctAimLeft) + controlParseAndPoll(Settings.ctAimRight));
		_controlStructUpdate(vAxis, -controlParseAndPoll(Settings.ctAimUp) + controlParseAndPoll(Settings.ctAimDown));
		_controlStructUpdate(wAxis, 0.0);

	//	_controlStructUpdate(itemUseButton, keyboard_check(ord("Z")));
		//_controlStructUpdate(atkButton, mouse_check_button(mb_left)   + gamepad_button_check(0, gp_face1) + gamepad_button_check(0, gp_shoulderr));
		//_controlStructUpdate(useButton, mouse_check_button(mb_left)   + gamepad_button_check(0, gp_face1) + gamepad_button_check(0, gp_shoulderr));
	//	_controlStructUpdate(bButton, keyboard_check(ord("X")));
		//_controlStructUpdate(itemUseButton, keyboard_check(ord("F"))      + gamepad_button_check(0, gp_face2));
		//_controlStructUpdate(dodgeButton, mouse_check_button(mb_right)  + gamepad_button_check(0, gp_shoulderl));
		//_controlStructUpdate(journalButton, keyboard_check(ord("Q")) || keyboard_check(vk_tab)  + gamepad_button_check(0, gp_start));
		_controlStructUpdate(yButton, keyboard_check(ord("E")));
		//_controlStructUpdate(itemPrevButton, keyboard_check(ord("K")) + mouse_wheel_down()   + gamepad_button_check(0, gp_padl));
		//_controlStructUpdate(itemNextButton, keyboard_check(ord("L")) + mouse_wheel_up()     + gamepad_button_check(0, gp_padr));
		//_controlStructUpdate(itemsButton, keyboard_check(ord("I"))                                   + gamepad_button_check(0, gp_select));
		//_controlStructUpdate(selectButton, mouse_check_button(mb_left) || keyboard_check(vk_enter)   + gamepad_button_check(0, gp_face1));
		//_controlStructUpdate(cancelButton, mouse_check_button(mb_right) || keyboard_check(vk_escape) + gamepad_button_check(0, gp_face2) + + gamepad_button_check(0, gp_face4));
		//_controlStructUpdate(prevUiButton, mouse_wheel_down()                               + gamepad_button_check(0, gp_shoulderl) );
		//_controlStructUpdate(nextUiButton, mouse_wheel_up() + mouse_check_button(mb_middle) + gamepad_button_check(0, gp_shoulderr) );
	
		_controlStructUpdate(atkButton, controlParseAndPoll(Settings.ctAttack));
		_controlStructUpdate(useButton, controlParseAndPoll(Settings.ctUse));
		_controlStructUpdate(itemUseButton, controlParseAndPoll(Settings.ctUseItem));
		_controlStructUpdate(dodgeButton, controlParseAndPoll(Settings.ctDodge));
		_controlStructUpdate(keyItemUseButton, controlParseAndPoll(Settings.ctUseKeyItem));
		_controlStructUpdate(runeButton, controlParseAndPoll(Settings.ctUseSpecial));
	
		_controlStructUpdate(journalButton, controlParseAndPoll(Settings.ctJournal));
		_controlStructUpdate(itemsButton, controlParseAndPoll(Settings.ctInventory));
	
		_controlStructUpdate(itemPrevButton, controlParseAndPoll(Settings.ctItemPrevious));
		_controlStructUpdate(itemNextButton, controlParseAndPoll(Settings.ctItemNext));
		_controlStructUpdate(itemUnequipButton, controlParseAndPoll(Settings.ctItemUnequip));
	
		_controlStructUpdate(selectButton, controlParseAndPoll(Settings.ctUiSelect));
		_controlStructUpdate(actUiButton, controlParseAndPoll(Settings.ctUiAction));
		_controlStructUpdate(cancelButton, controlParseAndPoll(Settings.ctUiCancel));
		_controlStructUpdate(prevUiButton, controlParseAndPoll(Settings.ctUiPrevious));
		_controlStructUpdate(nextUiButton, controlParseAndPoll(Settings.ctUiNext));
	
		//_controlStructUpdate(belt1Button, keyboard_check(ord("1")));
		//_controlStructUpdate(belt2Button, keyboard_check(ord("2")));
		//_controlStructUpdate(belt3Button, keyboard_check(ord("3")));
		//_controlStructUpdate(belt4Button, keyboard_check(ord("4")));
		//_controlStructUpdate(belt5Button, keyboard_check(ord("5")));
		//_controlStructUpdate(belt6Button, keyboard_check(ord("6")));
	
		_controlStructUpdate(belt1Button, controlParseAndPoll(Settings.ctItem1));
		_controlStructUpdate(belt2Button, controlParseAndPoll(Settings.ctItem2));
		_controlStructUpdate(belt3Button, controlParseAndPoll(Settings.ctItem3));
		_controlStructUpdate(belt4Button, controlParseAndPoll(Settings.ctItem4));
		_controlStructUpdate(belt5Button, controlParseAndPoll(Settings.ctItem5));
		_controlStructUpdate(belt6Button, controlParseAndPoll(Settings.ctItem6));
	
		//Check if the mouse has moved since the last check
		//var nextUPositionMouse = round(window_mouse_get_x() / Screen.pixelScale + GameCamera.view_x);
		//var nextVPositionMouse = round(window_mouse_get_y() / Screen.pixelScale + GameCamera.view_y);
		//var nextUPositionMouse = round(window_mouse_get_x() / Screen.pixelScale);
		//var nextVPositionMouse = round(window_mouse_get_y() / Screen.pixelScale);
		var windowMouseX = window_mouse_get_x();
		var windowMouseY = window_mouse_get_y();
		//if (nextUPositionMouse != prevUPositionMouse && nextVPositionMouse != prevVPositionMouse)
		if (windowMouseX != windowMouseXPrevious || windowMouseY != windowMouseYPrevious)
		{
			uvPositionStyle = kControlUvStyle_Mouse;
			//prevUPositionMouse = uPosition;
			//prevVPositionMouse = vPosition;
			windowMouseXPrevious = windowMouseX;
			windowMouseYPrevious = windowMouseY;
		}
	
		uPositionPrevious = uPosition;
		vPositionPrevious = vPosition;
	
		//Check if the analog stick was moved
		var analogX = uAxis.value;//deadzone_bias(gamepad_axis_value(0, gp_axisrh));
		var analogY = vAxis.value;//deadzone_bias(gamepad_axis_value(0, gp_axisrv));
		if (abs(analogX) > 0.3 || abs(analogY) > 0.3 || uvPositionStyle == kControlUvStyle_FakeMouse)
		{
			uvPositionStyle = kControlUvStyle_Unused;
		
			uPositionScreen += Time.deltaTime * analogX * 128.0;
			vPositionScreen += Time.deltaTime * analogY * 128.0;
			uPositionScreen = clamp(uPositionScreen, 0, GameCamera.width);
			vPositionScreen = clamp(vPositionScreen, 0, GameCamera.height);
		
			if (uvPositionStyle == kControlUvStyle_FakeMouse)
			{
				uPosition = round(uPositionScreen + GameCamera.view_x);
				vPosition = round(vPositionScreen + GameCamera.view_y);
			}
			else if (uvPositionStyle == kControlUvStyle_Unused)
			{
				uPosition = 0.0;
				vPosition = 0.0;
			}
		}
		else 
		{
			//If the mouse was last moved,
			if (uvPositionStyle == kControlUvStyle_Mouse)
			{
				//Move the cursor to the mouse
				//uPosition = nextUPositionMouse;
				//vPosition = nextVPositionMouse;
				uPosition = round(windowMouseXPrevious / Screen.pixelScale + GameCamera.view_x);
				vPosition = round(windowMouseYPrevious / Screen.pixelScale + GameCamera.view_y);
			}
		}
	}
	else
	{
		_controlStructUpdate(xAxis, 0.0);
		_controlStructUpdate(yAxis, 0.0);
		_controlStructUpdate(zAxis, 0.0);
	
		_controlStructUpdate(uAxis, 0.0);
		_controlStructUpdate(vAxis, 0.0);
		_controlStructUpdate(wAxis, 0.0);

		_controlStructUpdate(itemUseButton, 0.0);
		_controlStructUpdate(atkButton, 0.0);
		_controlStructUpdate(useButton, 0.0);
		_controlStructUpdate(journalButton, 0.0);
		_controlStructUpdate(yButton, 0.0);
		_controlStructUpdate(itemPrevButton, 0.0);
		_controlStructUpdate(itemNextButton, 0.0);
		_controlStructUpdate(itemsButton, 0.0);
		_controlStructUpdate(selectButton, 0.0);
		_controlStructUpdate(actUiButton, 0.0);
		_controlStructUpdate(cancelButton, 0.0);
		_controlStructUpdate(prevUiButton, 0.0);
		_controlStructUpdate(nextUiButton, 0.0);
	
		_controlStructUpdate(belt1Button, 0.0);
		_controlStructUpdate(belt2Button, 0.0);
		_controlStructUpdate(belt3Button, 0.0);
		_controlStructUpdate(belt4Button, 0.0);
		_controlStructUpdate(belt5Button, 0.0);
		_controlStructUpdate(belt6Button, 0.0);
	}


}
