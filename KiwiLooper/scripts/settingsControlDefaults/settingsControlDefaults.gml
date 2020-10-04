function settingsControlDefaults() {
#macro kControlKB 0
#macro kControlMouse 1 
#macro kControlGamepad 2

#macro kMouseWheelUp 0x101
#macro kMouseWheelDown 0x102

#macro kGamepadTypeXInput		0
#macro kGamepadTypeDualshock	1
#macro kGamepadTypeGeneric		2

	with (Settings)
	{
		ctMoveLeft		= [kControlKB, ord("A"),	kControlGamepad, -gp_axislh];
		ctMoveRight		= [kControlKB, ord("D"),	kControlGamepad, gp_axislh];
		ctMoveUp		= [kControlKB, ord("W"),	kControlGamepad, -gp_axislv];
		ctMoveDown		= [kControlKB, ord("S"),	kControlGamepad, gp_axislv];
		ctJump			= [kControlKB, vk_space];
	
		ctAimLeft		= [kControlKB, vk_left,		kControlGamepad, -gp_axisrh];
		ctAimRight		= [kControlKB, vk_right,	kControlGamepad, gp_axisrh];
		ctAimUp			= [kControlKB, vk_up,		kControlGamepad, -gp_axisrv];
		ctAimDown		= [kControlKB, vk_down,		kControlGamepad, gp_axisrv];
	
		ctAttack		= [kControlKB, vk_control,	kControlMouse, mb_left,			kControlGamepad, gp_face3];
		ctUse			= [kControlKB, vk_space,	kControlGamepad, gp_face1];
		ctUseItem		= [kControlKB, ord("F"),	kControlGamepad, gp_shoulderrb, kControlGamepad, gp_face2];
		ctUseKeyItem	= [kControlKB, ord("E"),	kControlGamepad, gp_face3];
		ctUseSpecial	= [kControlKB, ord("V"),	kControlGamepad, gp_face4];
		ctDodge			= [kControlMouse, mb_right,	kControlGamepad, gp_shoulderl];
	
		ctInventory		= [kControlKB, ord("I"),	kControlGamepad, gp_select, kControlGamepad, gp_padu];
		ctJournal		= [kControlKB, ord("Q"),	kControlKB, vk_tab, kControlGamepad, gp_start];
		ctMap			= [kControlKB, ord("M")];
	
		ctItem1			= [kControlKB, ord("1")];
		ctItem2			= [kControlKB, ord("2")];
		ctItem3			= [kControlKB, ord("3")];
		ctItem4			= [kControlKB, ord("4")];
		ctItem5			= [kControlKB, ord("5")];
		ctItem6			= [kControlKB, ord("6")];
		ctItemPrevious	= [kControlMouse, kMouseWheelDown,	kControlGamepad, gp_padl];
		ctItemNext		= [kControlMouse, kMouseWheelUp,	kControlGamepad, gp_padr];
		ctItemUnequip	= [kControlKB, ord("7"),	kControlGamepad, gp_padd];
	
		ctUiPrevious	= [kControlKB, vk_pageup,	kControlGamepad, gp_shoulderl,	kControlMouse, kMouseWheelDown];
		ctUiNext		= [kControlKB, vk_pagedown,	kControlGamepad, gp_shoulderr,	kControlMouse, kMouseWheelUp,	kControlMouse, mb_middle];
		ctUiSelect		= [kControlMouse, mb_left,	kControlKB, vk_enter,			kControlGamepad, gp_face1];
		ctUiAction		= [kControlMouse, mb_right,	kControlGamepad, gp_face3];
		ctUiCancel		= [kControlKB, vk_escape,	kControlGamepad, gp_face2,		kControlGamepad, gp_face4];
	}


}
