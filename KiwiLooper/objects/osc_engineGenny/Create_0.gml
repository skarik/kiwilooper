/// @description Genny count

m_gennyCount = instance_number(o_charaPowercell);

// Make all the spinner genny
var spinny;

spinny = inew(ot_3DSpinnaz);
spinny.x = x;
spinny.y = y;
spinny.z = 16 + 32;
spinny.xspeed_spin = 180;
spinny.yspeed_spin = 190;
spinny.zspeed_spin = 200;

spinny = inew(ot_3DSpinnaz);
spinny.x = x;
spinny.y = y;
spinny.z = 16 + 32;
spinny.xspeed_spin = -320;
spinny.yspeed_spin = -480;
spinny.zspeed_spin = -750;

spinny = inew(ot_3DSpinnaz);
spinny.x = x;
spinny.y = y;
spinny.z = 16 + 32;
spinny.xspeed_spin = -600;
spinny.yspeed_spin =  100;
spinny.zspeed_spin = -450;

for (var i = 0; i < 4; ++i)
{
	spinny = inew(ot_3DSpinnaz);
	spinny.x = x;
	spinny.y = y;
	spinny.z = 16 + 32;
	spinny.xspeed_spin = 105 * (i - 2.5);
	spinny.yspeed_spin = 95 * (3.5 - i);
	spinny.zspeed_spin = 180 * (i - 0.5);
}