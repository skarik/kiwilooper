/// @description OnClick - Kill player

var pl = getPlayer();
if (iexists(pl))
{
	//damageTarget(pl, pl.stats.m_healthMax, kDamageTypeBlunt, false, true);
	pl.stats.m_health -= pl.stats.m_healthMax;
}