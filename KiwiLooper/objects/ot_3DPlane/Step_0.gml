/// @description Update camerea

o_Camera3D.z = 16;
//o_Camera3D.zrotation = 45;
o_Camera3D.zrotation += Time.deltaTime * 45;
o_Camera3D.yrotation += Time.deltaTime * 22.5;

o_Camera3D.x = lengthdir_x(-64, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
o_Camera3D.y = lengthdir_y(-64, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
o_Camera3D.z = lengthdir_y(-64, o_Camera3D.yrotation);

o_Camera3D.orthographic = true;