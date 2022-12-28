/// @function AToolbarTop() constructor
/// @notes A toolbar for rendering a horizontal general menu.
function AToolbarTop() : AToolbar() constructor
{
	static kButtonSize		= 18;
	static kButtonPadding	= 3;
	static kButtonMargin	= 0;
	static kSpacerSize		= 7;
	static kTooltipShowTime	= 0.25;
	static kTextPadding		= 1;
	static kBarDirection	= kDirRight;
}

/// @function AToolbarElementAsButtonInfo2(sprite, spriteIndex, tooltip, text, onClick, onCheckDown, onCanClick)
/// @param {Sprite} UI Icon
/// @param {Real} UI Icon image_index
/// @param {String} Hover tooltip
/// @param {String} Text to add
/// @param {Function} onClick callback
/// @param {Function} onCheckDown callback
function AToolbarElementAsButtonInfo2(sprite, spriteIndex, tooltip, text, onClick, onCheckDown, onCanClick=null)
{
	element = new AToolbarElement();
	element.m_isButton = true;
	element.m_onClick = onClick;
	element.m_onCheckDown = onCheckDown;
	element.m_onCanClick = onCanClick;
	element.m_sprite = sprite;
	element.m_spriteIndex = spriteIndex;
	element.m_tooltip = tooltip;
	element.m_text = text;
	return element;
}