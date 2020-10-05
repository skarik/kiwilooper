/// @description Reset state

// Current music state
m_state = 0;

// Hack to get around an obscure OGG crash
if (instance_number(o_musicEngine) > 1 || instance_exists(o_musicStop) || room != rm_Ship5)
{
	instance_destroy();
	exit;
}