function settingsControlSave() {
	with (Settings)
	{
	    ini_open("settings.ini");
    
		ctMoveLeft		= _settingsControlSaveArray("moveleft", ctMoveLeft);
		ctMoveRight		= _settingsControlSaveArray("moveright", ctMoveRight);
		ctMoveUp		= _settingsControlSaveArray("moveup", ctMoveUp);
		ctMoveDown		= _settingsControlSaveArray("movedown", ctMoveDown);
	
		ctAimLeft		= _settingsControlSaveArray("aimleft", ctAimLeft);
		ctAimRight		= _settingsControlSaveArray("aimright", ctAimRight);
		ctAimUp			= _settingsControlSaveArray("aimup", ctAimUp);
		ctAimDown		= _settingsControlSaveArray("aimdown", ctAimDown);
	
		ctJump			= _settingsControlSaveArray("jump", ctJump);
		ctAttack		= _settingsControlSaveArray("attack", ctAttack);
		ctUse			= _settingsControlSaveArray("use", ctUse);
		ctUseItem		= _settingsControlSaveArray("useitem", ctUseItem);
		ctUseKeyItem	= _settingsControlSaveArray("usekeyitem", ctUseKeyItem);
		ctUseSpecial	= _settingsControlSaveArray("usespecial", ctUseSpecial);
		ctDodge			= _settingsControlSaveArray("dodge", ctDodge);
	
		ctInventory		= _settingsControlSaveArray("inventory", ctInventory);
		ctJournal		= _settingsControlSaveArray("journal", ctJournal);
		ctMap			= _settingsControlSaveArray("map", ctMap);
	
		ctItem1			= _settingsControlSaveArray("item1", ctItem1);
		ctItem2			= _settingsControlSaveArray("item2", ctItem2);
		ctItem3			= _settingsControlSaveArray("item3", ctItem3);
		ctItem4			= _settingsControlSaveArray("item4", ctItem4);
		ctItem5			= _settingsControlSaveArray("item5", ctItem5);
		ctItem6			= _settingsControlSaveArray("item6", ctItem6);
		ctItemPrevious	= _settingsControlSaveArray("itemprevious", ctItemPrevious);
		ctItemNext		= _settingsControlSaveArray("itemnext", ctItemNext);
		ctItemUnequip	= _settingsControlSaveArray("itemunequip", ctItemUnequip);
	
		ctUiPrevious	= _settingsControlSaveArray("uiprevious", ctUiPrevious);
		ctUiNext		= _settingsControlSaveArray("uinext", ctUiNext);
		ctUiSelect		= _settingsControlSaveArray("uiselect", ctUiSelect);
		ctUiAction		= _settingsControlSaveArray("uiaction", ctUiAction);
		ctUiCancel		= _settingsControlSaveArray("uicancel", ctUiCancel);

	    ini_close();
	}




}
