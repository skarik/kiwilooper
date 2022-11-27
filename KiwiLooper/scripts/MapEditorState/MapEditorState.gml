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
		
		mode: 0, // 0 for topdown, 1 for fps
	};
	
	view = {
		mode: kEditorViewMode_Lit,
		showmask: kEditorViewMask_GizmoIcons | kEditorViewMask_NodeLinks,
	};
	
	map = {
		solids: array_create(0),
		
		geometry_valid:	false,
		ai_valid:		false,
		lighting_valid:	false,
	};
	
	static serializeBuffer = function(version, buffer, ioMode, io_ser)
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
		
		if (version >= kMapEditorFeature_Solids)
		{
			if (ioMode == kIoRead)
			{
				var solid_count = buffer_read(buffer, buffer_s32);
				map.solids = array_create(solid_count);
				for (var solidIndex = 0; solidIndex < solid_count; ++solidIndex)
				{
					map.solids[solidIndex] = (new AMapSolid()).ReadFromBuffer(buffer);
				}
			}
			else if (ioMode = kIoWrite)
			{
				buffer_write(buffer, buffer_s32, array_length(map.solids));
				for (var solidIndex = 0; solidIndex < array_length(map.solids); ++solidIndex)
				{
					map.solids[solidIndex].WriteToBuffer(buffer);
				}
			}
		}
		
		if (version >= kMapEditorFeature_DirtyFlagsAndCamToggle)
		{
			io_ser(camera, "mode", buffer, buffer_u8);
			
			io_ser(map, "geometry_valid", buffer, buffer_bool);
			io_ser(map, "ai_valid", buffer, buffer_bool);
			io_ser(map, "lighting_valid", buffer, buffer_bool);
		}
	}
}