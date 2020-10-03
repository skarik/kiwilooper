if (singleton_this()) exit;

width = Screen.width / Screen.pixelScale;
height = Screen.height / Screen.pixelScale;
index = camera_create_view(0, 0, width, height);

view_x = 0;
view_y = 0;