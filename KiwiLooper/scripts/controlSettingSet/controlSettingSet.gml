/// @function controlSettingSet(controlname, value)
/// @param controlname {String}
/// @param value {Control Array}
/// @returns True on proper set, false otherwise.
function controlSettingSet(argument0, argument1) {

	var controlname = argument0;
	var value = argument1;

	switch (controlname)
	{
		case "moveleft": Settings.ctMoveLeft = value;
			return true;
		case "moveright": Settings.ctMoveRight = value;
			return true;
		case "moveup": Settings.ctMoveUp = value;
			return true;
		case "movedown": Settings.ctMoveDown = value;
			return true;
	
		case "aimleft": Settings.ctAimLeft = value;
			return true;
		case "aimright": Settings.ctAimRight = value;
			return true;
		case "aimup": Settings.ctAimUp = value;
			return true;
		case "aimdown": Settings.ctAimDown = value;
			return true;
	
		case "jump": Settings.ctJump = value;
			return true;
		case "attack": Settings.ctAttack = value;
			return true;
		case "use": Settings.ctUse = value;
			return true;
		case "useitem": Settings.ctUseItem = value;
			return true;
		case "usekeyitem": Settings.ctUseKeyItem = value;
			return true;
		case "usespecial": Settings.ctUseSpecial = value;
			return true;
		case "dodge": Settings.ctDodge = value;
			return true;
		
		case "inventory": Settings.ctInventory = value;
			return true;
		case "journal": Settings.ctJournal = value;
			return true;
		case "map": Settings.ctMap = value;
			return true;
	
		case "item1": Settings.ctItem1 = value;
			return true;
		case "item2": Settings.ctItem2 = value;
			return true;
		case "item3": Settings.ctItem3 = value;
			return true;
		case "item4": Settings.ctItem4 = value;
			return true;
		case "item5": Settings.ctItem5 = value;
			return true;
		case "item6": Settings.ctItem6 = value;
			return true;
		case "itemprevious": Settings.ctItemPrevious = value;
			return true;
		case "itemnext": Settings.ctItemNext = value;
			return true;
		case "itemunequip": Settings.ctItemUnequip = value;
			return true;
		
		case "uiprevious": Settings.ctUiPrevious = value;
			return true;
		case "uinext": Settings.ctUiNext = value;
			return true;
		case "uiselect": Settings.ctUiSelect = value;
			return true;
		case "uicancel": Settings.ctUiCancel = value;
			return true;
		
		default:
			return false;
	};



}
