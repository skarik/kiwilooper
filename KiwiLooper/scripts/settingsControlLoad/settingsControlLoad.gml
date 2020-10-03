function settingsControlLoad() {
	with (Settings)
	{
	    ini_open("settings.ini");
    
		ctMoveLeft		= _settingsControlLoadArray("moveleft", ctMoveLeft);
		ctMoveRight		= _settingsControlLoadArray("moveright", ctMoveRight);
		ctMoveUp		= _settingsControlLoadArray("moveup", ctMoveUp);
		ctMoveDown		= _settingsControlLoadArray("movedown", ctMoveDown);
		ctJump			= _settingsControlLoadArray("jump", ctJump);
	
		ctAimLeft		= _settingsControlLoadArray("aimleft", ctAimLeft);
		ctAimRight		= _settingsControlLoadArray("aimright", ctAimRight);
		ctAimUp			= _settingsControlLoadArray("aimup", ctAimUp);
		ctAimDown		= _settingsControlLoadArray("aimdown", ctAimDown);
	
		ctAttack		= _settingsControlLoadArray("attack", ctAttack);
		ctUse			= _settingsControlLoadArray("use", ctUse);
		ctUseItem		= _settingsControlLoadArray("useitem", ctUseItem);
		ctUseKeyItem	= _settingsControlLoadArray("usekeyitem", ctUseKeyItem);
		ctUseSpecial	= _settingsControlLoadArray("usespecial", ctUseSpecial);
		ctDodge			= _settingsControlLoadArray("dodge", ctDodge);
	
		ctInventory		= _settingsControlLoadArray("inventory", ctInventory);
		ctJournal		= _settingsControlLoadArray("journal", ctJournal);
		ctMap			= _settingsControlLoadArray("map", ctMap);
	
		ctItem1			= _settingsControlLoadArray("item1", ctItem1);
		ctItem2			= _settingsControlLoadArray("item2", ctItem2);
		ctItem3			= _settingsControlLoadArray("item3", ctItem3);
		ctItem4			= _settingsControlLoadArray("item4", ctItem4);
		ctItem5			= _settingsControlLoadArray("item5", ctItem5);
		ctItem6			= _settingsControlLoadArray("item6", ctItem6);
		ctItemPrevious	= _settingsControlLoadArray("itemprevious", ctItemPrevious);
		ctItemNext		= _settingsControlLoadArray("itemnext", ctItemNext);
		ctItemUnequip	= _settingsControlLoadArray("itemunequip", ctItemUnequip);
	
		ctUiPrevious	= _settingsControlLoadArray("uiprevious", ctUiPrevious);
		ctUiNext		= _settingsControlLoadArray("uinext", ctUiNext);
		ctUiSelect		= _settingsControlLoadArray("uiselect", ctUiSelect);
		ctUiAction		= _settingsControlLoadArray("uiaction", ctUiAction);
		ctUiCancel		= _settingsControlLoadArray("uicancel", ctUiCancel);

	    ini_close();
	}




}
