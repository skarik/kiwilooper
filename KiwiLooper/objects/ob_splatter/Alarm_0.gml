/// @description Delayed render creation

if (!iexists(o_splatterRenderer))
{
	inew(o_splatterRenderer);
}

// Update on self
if (!updated)
{
	o_splatterRenderer.update();
	updated = true;
}