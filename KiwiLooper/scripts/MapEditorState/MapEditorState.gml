#macro kEditorViewMode_Lit		0
#macro kEditorViewMode_Textured	1

#macro kEditorViewMask_GizmoIcons	0x0001
#macro kEditorViewMask_NodeLinks	0x0002


/// @function AMapEditorState() constructor
function AMapEditorState() constructor
{
	camera = {
		position: new Vector3(0, 0, 0),
		rotation: new Vector3(0, 60, 45),
		zoom: 1.0,
		
		fp_ready: false,
		fp_rotation: new Vector3(0, 0, 0),
		fp_z: 0,
	};
	
	view = {
		mode: kEditorViewMode_Lit,
		showmask: kEditorViewMask_GizmoIcons | kEditorViewMask_NodeLinks,
	};
	
	static serializeBuffer = function(version, buffer, io_ser)
	{
		if (version >= kMapEditorFeature_None)
		{
			io_ser(camera.position, "x", buffer, buffer_f64);
			io_ser(camera.position, "y", buffer, buffer_f64);
			io_ser(camera.position, "z", buffer, buffer_f64);
			io_ser(camera.rotation, "x", buffer, buffer_f64);
			io_ser(camera.rotation, "y", buffer, buffer_f64);
			io_ser(camera.rotation, "z", buffer, buffer_f64);
			io_ser(camera, "zoom", buffer, buffer_f64);
		}
		if (version >= kMapEditorFeature_CameraFirstPerson)
		{
			io_ser(camera, "fp_ready", buffer, buffer_bool);
			io_ser(camera.fp_rotation, "x", buffer, buffer_f64);
			io_ser(camera.fp_rotation, "y", buffer, buffer_f64);
			io_ser(camera.fp_rotation, "z", buffer, buffer_f64);
			io_ser(camera, "fp_z", buffer, buffer_f64);
		}
	}
}