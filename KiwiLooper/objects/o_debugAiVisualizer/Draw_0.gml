/// @description Draw UI in worldspace

draw_set_alpha(alpha);

with (o_chGobboTest)
{
	if (m_aiGobbo_state == kAiGobboPatrolState_WalkOut || m_aiGobbo_state == kAiGobboPatrolState_WalkIn)
	{
		var patrol_point = m_aiGobbo_patrol[m_aiGobbo_patrolWaypoint];
		draw_set_color(c_lime);
		draw_circle(patrol_point[0], patrol_point[1], 2, false);
	}
	draw_set_color(c_red);
	draw_arrow(x, y, x + lengthdir_x(16, facingDirection), y + lengthdir_y(16, facingDirection), 5);
	draw_pie(x - m_aiCombat_noticeDistance, y - m_aiCombat_noticeDistance,
			 x + m_aiCombat_noticeDistance, y + m_aiCombat_noticeDistance,
			 x + lengthdir_x(100, facingDirection - m_aiCombat_noticeAngle),
			 y + lengthdir_y(100, facingDirection - m_aiCombat_noticeAngle),
			 x + lengthdir_x(100, facingDirection + m_aiCombat_noticeAngle),
			 y + lengthdir_y(100, facingDirection + m_aiCombat_noticeAngle),
			 true);
			 
	/*draw_set_color(c_yellow);
	draw_arrow(x, y, x + lengthdir_x(8, aimingDirection), y + lengthdir_y(8, aimingDirection), 4);*/
}

with (ob_aiNode)
{
	event_user(0); // Render them nodes.
}

draw_set_alpha(1.0);