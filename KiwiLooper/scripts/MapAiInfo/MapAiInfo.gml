/// @function AMapAiInfo() constructor
function AMapAiInfo() constructor
{
	// Flag for if needs rebuild.
	bNeedsRebuild = false;
	
	// List of all nodes in the ai net
	nodes = [];
	
	static saveToBuffer = function(version, buffer)
	{
		if (version >= kMapAiFeature_None)
		{
			buffer_write(buffer, buffer_bool, bNeedsRebuild);
			
			// Write nodes:
			buffer_write(buffer, buffer_s16, array_length(nodes));
			for (var iNode = 0; iNode < array_length(nodes); ++iNode)
			{
				var current_node = nodes[iNode];
				
				// Build array of plain indices based on connections:
				var flat_connections = [];
				for (var iConnection = 0; iConnection < array_length(current_node.connections); ++iConnection)
				{
					var connection = current_node.connections[iConnection];
					flat_connections[iConnection] = {index: array_get_index(nodes, connection.node), source: connection};
				}
				
				// Write node information
				buffer_write(buffer, buffer_f64, current_node.position.x);
				buffer_write(buffer, buffer_f64, current_node.position.y);
				buffer_write(buffer, buffer_f64, current_node.position.z);
				buffer_write(buffer, buffer_f64, current_node.rotation.x);
				buffer_write(buffer, buffer_f64, current_node.rotation.y);
				buffer_write(buffer, buffer_f64, current_node.rotation.z);
				buffer_write(buffer, buffer_bool, current_node.bGround);
				// Write node connection array
				buffer_write(buffer, buffer_s8, array_length(flat_connections));
				for (var iConnection = 0; iConnection < array_length(flat_connections); ++iConnection)
				{
					buffer_write(buffer, buffer_s16, flat_connections[iConnection].index);
					buffer_write(buffer, buffer_s8, flat_connections[iConnection].connection.size);
					buffer_write(buffer, buffer_bool, flat_connections[iConnection].connection.dynamic);
					buffer_write(buffer, buffer_bool, false); // Reserved
					buffer_write(buffer, buffer_bool, false); // Reserved
					buffer_write(buffer, buffer_bool, false); // Reserved
				}
			}
			
			// Write others:
			buffer_write(buffer, buffer_s16, 0);
			buffer_write(buffer, buffer_s16, 0);
			buffer_write(buffer, buffer_s16, 0);
			buffer_write(buffer, buffer_s16, 0);
		}
	}
	
	static loadFromBuffer = function(version, buffer)
	{
		if (version >= kMapAiFeature_None)
		{
			bNeedsRebuild = buffer_read(buffer, buffer_bool);
			
			// Read nodes:
			var node_count = buffer_read(buffer, buffer_s16);
			nodes = array_create(node_count);
			for (var iNode = 0; iNode < node_count; ++iNode)
			{
				var current_node = new AAiNode();
				
				// Read node information
				current_node.position.x = buffer_read(buffer, buffer_f64);
				current_node.position.y = buffer_read(buffer, buffer_f64);
				current_node.position.z = buffer_read(buffer, buffer_f64);
				current_node.rotation.x = buffer_read(buffer, buffer_f64);
				current_node.rotation.y = buffer_read(buffer, buffer_f64);
				current_node.rotation.z = buffer_read(buffer, buffer_f64);
				current_node.bGround = buffer_read(buffer, buffer_bool);
				// Read node connection array
				var connection_count = buffer_read(buffer, buffer_s8);
				for (var iConnection = 0; iConnection < connection_count; ++iConnection)
				{
					var connection = current_node.addUnresolvedConnection(buffer_read(buffer, buffer_s16));
					connection.size = buffer_read(buffer, buffer_s8);
					connection.dynamic = buffer_read(buffer, buffer_bool);
					buffer_read(buffer, buffer_bool);
					buffer_read(buffer, buffer_bool);
					buffer_read(buffer, buffer_bool);
				}
				
				// Save partial node we just loaded
				nodes[iNode] = current_node;
			}
			// Fix up the node links now that we have all of them
			for (var iNode = 0; iNode < node_count; ++iNode)
			{
				var current_node = nodes[iNode];
				for (var iConnection = 0; iConnection < array_length(current_node.connections); ++iConnection)
				{
					current_node.connections[iConnection].node = nodes[current_node.connections[iConnection].node];
				}
			}
			
			// Read others:
			buffer_read(buffer, buffer_s16);
			buffer_read(buffer, buffer_s16);
			buffer_read(buffer, buffer_s16);
			buffer_read(buffer, buffer_s16);
		}
	}
}

#macro kNodeSizeSmall 4
#macro kNodeSizeMedium 12
#macro kNodeSizeLarge 24

function AAiNode() constructor
{
	// position & rotation (rotation for key angles, likely unused?)
	position = new Vector3(0, 0, 0);
	rotation = new Vector3(0, 0, 0);
	// is this a ground-traversal node?
	bGround = true;
	
	// Connections are a structure: {node, dynamic, size}
	// Dynamic connections can turn on and off depending on doors.
	connections = [];
	
	/// @function addConnection(node)
	static addConnection = function(in_node)
	{
		array_push(connections, {node: in_node, dynamic: false, size: kNodeSizeMedium});
		return connections[array_length(connections) - 1];
	}
	/// @function addUnresolvedConnection(node_index)
	static addUnresolvedConnection = function(node_index)
	{
		array_push(connections, {node: node_index, dynamic: false, size: kNodeSizeMedium});
		return connections[array_length(connections) - 1];
	}
	
	/// @function findConnection(node)
	static findConnection = function(in_node)
	{
		var index = array_get_index_pred(connections, in_node, function(connection, in_node) { return connection.node == in_node; });
		if (index != null)
			return connections[index];
		else
			return undefined;
	}
}

function AiRebuildPathing(ai_map)
{
	// Loop through every node & walk a tree?
	
	// nah, loop thru every node, do collision super-cool-like prolly
}

/// @function AiCanPathNodes(start_node, end_node)
/// @returns Struct {bPathable, bGroundMovement, bGroundFall}
function AiCanPathNodes(start_node, end_node)
{
	var pathResult = {bPathable: false, bGroundMovement: false, bGroundFall: false};
	
	// TODO: raytrace paths
	
	return pathResult;
}