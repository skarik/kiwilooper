/// @description Check for other music on room start

// Hack to get around an obscure OGG crash
if (instance_number(o_musicMain) > 1 || instance_exists(o_musicStop) || instance_exists(o_musicEngine))
{
	instance_destroy();
	exit;
}