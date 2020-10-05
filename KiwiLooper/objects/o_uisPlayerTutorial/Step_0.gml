/// @description Kill after time

m_life -= Time.deltaTime;
if (m_life <= 0.0)
{
	m_alpha -= 3.0 * Time.deltaTime;
	if (m_alpha <= 0.0)
	{
		instance_destroy();
		exit;
	}
}