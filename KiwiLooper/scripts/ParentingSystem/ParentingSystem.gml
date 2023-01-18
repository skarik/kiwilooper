function AParentingChildNode(in_instance) constructor
{
	instance = in_instance;
	offset = new Vector3(0, 0, 0);
	children = [];
	
	static AddChildNode = function(node)
	{
		array_push(children, node);
	}
	static RemoveChildInstance = function(in_instance)
	{
		var index_to_remove = array_get_index_pred(global.parenting_nodes, instance, Parenting_NodeMatchesInstance);
		if (index_to_remove != null)
		{
			array_delete(children, index_to_remove, 1);
		}
	}
}

function Parenting_NodeMatchesInstance(node, instance)
{
	return node.instance == instance;
}

/// @function Parenting_Initialize()
function Parenting_Initialize()
{
	global.parenting_root = new AParentingChildNode(null);
	global.parenting_nodes = [];
}


/// @function Parenting_BuildHeirarchy(entlist)
/// @params entlist {AEntityList}
function Parenting_BuildHeirarchy(entlist)
{
	global.parenting_root = new AParentingChildNode(null);
	global.parenting_nodes = [];
	
	// Loop through all items in the entlist and find those with parents set.
	for (var entIndex = 0; entIndex < entlist.GetEntityCount(); ++entIndex)
	{
		var entInstance = entlist.GetEntity(entIndex);
		
		// Skip if entity was deleted by persistence (TODO: should this be done AFTER?)
		if (!iexists(entInstance))
		{
			continue;
		}
		
		var ent = entInstance.entity;
		
		if (entPropertyExists(ent, "parent", kValueTypeLively))
		{
			var parent_target = entInstance.parent;
			if (!is_undefined(parent_target) && iexists(parent_target))
			{
				// We want to find the node for the parent on our tree - and if there isn't one, we create one.
				var parent_node = null;
				var parent_index = array_get_index_pred(global.parenting_nodes, parent_target, Parenting_NodeMatchesInstance);
				if (parent_index != null)
				{
					parent_node = global.parenting_nodes[parent_index];
				}
				else
				{
					// Create a new root-level node
					parent_node = new AParentingChildNode(parent_target);
					array_push(global.parenting_nodes, parent_node);
					global.parenting_root.AddChildNode(parent_node);
				}
				
				// Now that we have the parent node, we can get/make the node for ourselves and move it to our parent:
				var child_node = null;
				var child_index = array_get_index_pred(global.parenting_nodes, entInstance, Parenting_NodeMatchesInstance);
				if (child_index != null)
				{
					child_node = global.parenting_nodes[child_index];
					// We have to remove the child node from our current parent (the world) and move it to our correct parent:
					global.parenting_root.RemoveChildInstance(entInstance);
					parentNode.AddChildNode(child_node);
				}
				else
				{
					// Create a new node & add to parent
					child_node = new AParentingChildNode(entInstance);
					array_push(global.parenting_nodes, child_node);
					parent_node.AddChildNode(child_node);
				}
				
				// Set up the child node's offset against the parent & we're done
				child_node.offset = Vector3FromTranslation(child_node.instance).subtract(Vector3FromTranslation(parent_node.instance));
			}
		}
	}
}

/// @function Parenting_NeedsPerStepUpdate()
function Parenting_NeedsPerStepUpdate()
{
	return array_length(global.parenting_nodes) > 0;
}

/// @function Parenting_UpdateHeirarchy()
/// @desc Updates the positions of all the objects within the heirarchy
function Parenting_UpdateHeirarchy()
{
	var child_count = array_length(global.parenting_root.children);
	for (var i = 0; i < child_count; ++i)
	{
		// Update the children heirarchy
		_Parenting_UpdateHeirarchy_Internal(global.parenting_root.children[i]);
	}
}
function _Parenting_UpdateHeirarchy_Internal(node)
{
	var child_count = array_length(node.children);
	for (var i = 0; i < child_count; ++i)
	{
		var child = node.children[i];
		
		// Update the children position
		var child_position = Vector3FromTranslation(node.instance).add(child.offset);
		child.instance.x = child_position.x;
		child.instance.y = child_position.y;
		child.instance.z = child_position.z;
		
		// Update the children heirarchy
		_Parenting_UpdateHeirarchy_Internal(child);
	}
}