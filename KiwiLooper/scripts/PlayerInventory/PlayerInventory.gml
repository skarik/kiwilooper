///@function AKiwiInventory() constructor
function AKiwiInventory() constructor
{
	is_big = true;
	
	max_width = 9;
	max_height = 8;
	
	width = max_width;
	height = max_height;
	
	m_money = 1261;
	m_items = [];
	m_cached_blocks = array_create(max_width * max_height);
	for (var i = 0; i < array_length(m_cached_blocks); ++i)
	{
		m_cached_blocks[i] = new AKiwiInventoryCachedBlock();
	}
	m_cached_blocks_dirty = true;
	
	// Recache all blocks now that initial setup is done.
	RecacheBlocks();
	
	static GetMaxWidth = function()
	{
		return max_width;
	}
	static GetMaxHeight = function()
	{
		return max_height;
	}
	
	static GetMoney = function()
	{
		return m_money;
	}
	
	static AddItem = function(item)
	{
		var blocks = GetCachedBlocks();
		var bPlaced = false;
		// Loop through all open spots
		for (var i = 0; i < max_width * max_height; ++i)
		{
			if (blocks[i].available && !blocks[i].filled)
			{
				var ix = i % max_width;
				var iy = floor(i / max_width);
				
				// Check if the spots for the item are OK
				for (var i_itemi = 0; i_itemi < item.width * item.height; ++i_itemi)
				{
					var i_itemx = i_itemi % item.width;
					var i_itemy = floor(i_itemi / item.width);
					
					var test_x = ix + i_itemx;
					var test_y = iy + i_itemy;
					var test_index = test_x + test_y * max_width;
					
					if (test_x >= 0 && test_x < max_width
						&& test_y >= 0 && test_y < max_height
						&& blocks[test_index].available && !blocks[test_index].filled)
					{
						// Found a spot!
						item.x = ix;
						item.y = iy;
						
						// Add it to our items!
						array_push(m_items, item);
						
						//  We can break out of this loop.
						bPlaced = true;
						break;
					}
				}
				
				// Placed, break out of loop.
				if (bPlaced)
				{
					break;
				}
			}
		}
		
		// Need to regen the blocks dirtiness when placed
		if (bPlaced)
		{
			debugLog(kLogVerbose, "Added item @" + string(item.x) + "," + string(item.y));
			m_cached_blocks_dirty = true;
		}
		
		return bPlaced;
	}
	
	static GetCachedBlocks = function()
	{
		if (m_cached_blocks_dirty)
		{
			RecacheBlocks();
		}
		return m_cached_blocks;
	}
	
	static RecacheBlocks = function()
	{
		// Default blocks
		for (var i = 0; i < max_width * max_height; ++i)
		{
			m_cached_blocks[i].defaultSelf();
		}
		
		// Block off all item blocks
		for (var itemIndex = 0; itemIndex < array_length(m_items); ++itemIndex)
		{
			var item = m_items[itemIndex];
			for (var i_itemx = 0; i_itemx < item.width; ++i_itemx)
			{
				for (var i_itemy = 0; i_itemy < item.height; ++i_itemy)
				{
					var block_x = item.x + i_itemx;
					var block_y = item.y + i_itemy;
					var block_index = block_x + block_y * max_width;
					var block = m_cached_blocks[block_index];
					
					// Fill in block & point it to the item.
					block.filled = true;
					block.item = item;
				}
			}
		}
		
		m_cached_blocks_dirty = false;
	}
	
	static GetItems = function()
	{
		return m_items;
	}
}

function AKiwiInventoryCachedBlock() constructor
{
	available = true;
	filled = false;
	item = undefined;
	defaultSelf();
	
	static defaultSelf = function()
	{
		available = true;
		filled = false;
		item = undefined;
	}
}

function AKiwiInventoryItem() constructor
{
	width = 2;
	height = 2;
	
	x = 0;
	y = 0;
	
	name = "Unknown";
}