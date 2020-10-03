/// @function controlSettingGet(controlname)
/// @param controlname {String}
/// @returns Control Array
function controlSettingGet(argument0) {

	var controlname = argument0;

	switch (controlname)
	{
		case "moveleft": return Settings.ctMoveLeft;
			break;
		case "moveright": return Settings.ctMoveRight;
			break;
		case "moveup": return Settings.ctMoveUp;
			break;
		case "movedown": return Settings.ctMoveDown;
			break;
	
		case "aimleft": return Settings.ctAimLeft;
			break;
		case "aimright": return Settings.ctAimRight;
			break;
		case "aimup": return Settings.ctAimUp;
			break;
		case "aimdown": return Settings.ctAimDown;
			break;
	
		case "jump": return Settings.ctJump;
			break;
		case "attack": return Settings.ctAttack;
			break;
		case "use": return Settings.ctUse;
			break;
		case "useitem": return Settings.ctUseItem;
			break;
		case "usekeyitem": return Settings.ctUseKeyItem;
			break;
		case "usespecial": return Settings.ctUseSpecial;
			break;
		case "dodge": return Settings.ctDodge;
			break;
		
		case "inventory": return Settings.ctInventory;
			break;
		case "journal": return Settings.ctJournal;
			break;
		case "map": return Settings.ctMap;
			break;
	
		case "item1": return Settings.ctItem1;
			break;
		case "item2": return Settings.ctItem2;
			break;
		case "item3": return Settings.ctItem3;
			break;
		case "item4": return Settings.ctItem4;
			break;
		case "item5": return Settings.ctItem5;
			break;
		case "item6": return Settings.ctItem6;
			break;
		case "itemprevious": return Settings.ctItemPrevious;
			break;
		case "itemnext": return Settings.ctItemNext;
			break;
		case "itemunequip": return Settings.ctItemUnequip;
			break;
		
		case "uiprevious": return Settings.ctUiPrevious;
			break;
		case "uinext": return Settings.ctUiNext;
			break;
		case "uiselect": return Settings.ctUiSelect;
			break;
		case "uicancel": return Settings.ctUiCancel;
			break;
		
		default:
			return null;
	};



}
