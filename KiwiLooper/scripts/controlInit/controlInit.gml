#macro kControlUvStyle_Mouse 0
#macro kControlUvStyle_FakeMouse 1 
#macro kControlUvStyle_Unused 2

#macro kControlChoice_Margin 0.70

function controlInit()
{
	xAxis = _controlStructCreate();
	yAxis = _controlStructCreate();
	zAxis = _controlStructCreate();
	uAxis = _controlStructCreate();
	vAxis = _controlStructCreate();
	wAxis = _controlStructCreate();

	itemUseButton = _controlStructCreate();
	atkButton = _controlStructCreate();
	useButton = _controlStructCreate();
	dodgeButton = _controlStructCreate();
	keyItemUseButton = _controlStructCreate();
	runeButton = _controlStructCreate();
	journalButton = _controlStructCreate();
	yButton = _controlStructCreate();
	itemPrevButton = _controlStructCreate();
	itemNextButton = _controlStructCreate();
	itemUnequipButton = _controlStructCreate();
	itemsButton = _controlStructCreate();
	selectButton = _controlStructCreate();
	actUiButton = _controlStructCreate();
	cancelButton = _controlStructCreate();
	prevUiButton = _controlStructCreate();
	nextUiButton = _controlStructCreate();

	belt1Button = _controlStructCreate();
	belt2Button = _controlStructCreate();
	belt3Button = _controlStructCreate();
	belt4Button = _controlStructCreate();
	belt5Button = _controlStructCreate();
	belt6Button = _controlStructCreate();

	uPosition = GameCamera.width / 2;
	vPosition = GameCamera.height / 2;
	uPositionPrevious = uPosition;
	vPositionPrevious = vPosition;

	windowMouseXPrevious = 0.0;
	windowMouseYPrevious = 0.0;

	uPositionScreen = GameCamera.width / 2;
	vPositionScreen = GameCamera.height / 2;

	uvPositionStyle = kControlUvStyle_Mouse;

	lastControlType = kControlKB;
	lastGamepadName = gamepad_get_description(0);
	lastGamepadType = (string_count("xinput", string_lower(lastGamepadName)) > 0) ? kGamepadTypeXInput : kGamepadTypeGeneric;
	
	mouseWrapCallbackId = Screen.limitMouseWrapCallbacks.Add(method(id,
		function(offset_x, offset_y)
		{
			uPosition += offset_x / Screen.pixelScale;
			uPositionPrevious += offset_x / Screen.pixelScale;
			
			vPosition += offset_y / Screen.pixelScale;
			vPositionPrevious += offset_y / Screen.pixelScale;
		}));
}
