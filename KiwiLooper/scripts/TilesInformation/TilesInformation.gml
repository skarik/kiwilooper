function _TileIndexIsWall(tx, ty)
{
	gml_pragma("forceinline");
	return false
		// Walls A2:
		|| (ty == 0 && tx >= 4 && tx < 8)
		|| (ty == 1 && tx >= 4 && tx < 5)
		// Walls B4:
		|| (ty == 4 && tx >= 12 && tx < 14)
		;
}

function _TileIndexIsFloor(tx, ty)
{
	gml_pragma("forceinline");
	return false
		// Floors A1:
		|| (ty == 0 && tx >= 1 && tx < 4)
		|| (ty == 1 && tx >= 1 && tx < 4)
		// Floors A3:
		|| (tx >= 8 && tx < 12 && ty >= 0 && ty < 4)
		// Floors A4:
		|| (tx >= 12 && tx < 14 && ty >= 0 && ty < 2)
		// Floor B2 specials:
		|| (tx >= 4 && tx < 6 && ty >= 4 && ty < 6)
		
		// Floor C1 slice:
		|| (ty == 4 && tx >= 0 && tx < 3)
		// Floor C3 slice:
		|| (ty == 4 && tx >= 8 && tx < 11)
		// Floor D1 slice:
		|| (ty == 8 && tx >= 1 && tx < 4)
		|| (ty == 9 && tx >= 1 && tx < 4)
		|| (ty == 10 && tx >= 1 && tx < 4)
		|| (ty == 11 && tx >= 0 && tx < 3)
		;
}

/// @function TileGetName(tile)
function TileGetName(tile)
{
	var tx = tile % 16;
	var ty = int64(tile / 16);
	
	var bx = int64(tx / 4);
	var by = int64(ty / 4);
	
	if (bx == 1 && by == 0)
	{
		return "w_mtl" + string(tx - 12);
	}
	else if (bx == 3 && by == 1)
	{
		return "w_rct" + string(tx - 12);
	}
	else if (bx == 0 && by == 2)
	{
		return "felec" + string(tx + (ty - 8) * 4);
	}
	else if (bx == 1 && by == 1)
	{
		return "fspec" + string(tx + (ty - 4) * 4);
	}
	else if (_TileIndexIsFloor(tx, ty))
	{
		return "f_" + string(tile);
	}
	else if (_TileIndexIsWall(tx, ty))
	{
		return "w_" + string(tile);
	}
	
	return "type" + string(tile);
}

/// @function TileGetMaterial(tileIndex)
function TileGetMaterial(tileIndex)
{
	return null; // TODO: implement material types for the game
}

/// @function TileHasWall(tile)
function TileHasWall(tile)
{
	var tx = tile % 16;
	var ty = int64(tile / 16);
	
	if (_TileIndexIsWall(tx, ty))
	{
		return true;
	}
	
	return false;
}

/// @function TileIsValidToPlace(tile)
function TileIsValidToPlace(tile)
{
	var tx = tile % 16;
	var ty = int64(tile / 16);
	
	if (_TileIndexIsFloor(tx, ty)
		|| _TileIndexIsWall(tx, ty)
		)
	{
		return true;
	}
	return false;
}