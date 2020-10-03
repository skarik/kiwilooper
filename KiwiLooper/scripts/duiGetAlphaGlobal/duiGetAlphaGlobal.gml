function duiGetAlphaGlobal() {
	if (iexists(o_debugMenu))
	{
		return o_debugMenu.image_alpha;
	}
	else
	{
		return 1.0;
	}


}
