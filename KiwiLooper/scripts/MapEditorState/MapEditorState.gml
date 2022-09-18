/// @function AMapEditorState() constructor
function AMapEditorState() constructor
{
	camera = {
		position: new Vector3(0, 0, 0),
		rotation: new Vector3(0, 60, 45),
		zoom: 1.0,
	};
	
	
	static serializeBuffer = function(buffer, io_ser)
	{
		io_ser(camera.position, "x", buffer, buffer_f64);
		io_ser(camera.position, "y", buffer, buffer_f64);
		io_ser(camera.position, "z", buffer, buffer_f64);
		io_ser(camera.rotation, "x", buffer, buffer_f64);
		io_ser(camera.rotation, "y", buffer, buffer_f64);
		io_ser(camera.rotation, "z", buffer, buffer_f64);
		io_ser(camera, "zoom", buffer, buffer_f64);
	}
}