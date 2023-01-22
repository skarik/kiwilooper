# Originally sourced from https://blender.stackexchange.com/questions/356/how-to-lock-the-view-to-prevent-rotation-of-the-view-camera

bl_info = {
    "name": "Lock View Rotation",
    "blender": (2, 80, 0),
    "category": "View",
}

import bpy

def draw_lock_rotation(self, context):
    layout = self.layout
    view = context.space_data
    col = layout.column(align=True)
    col.prop(view.region_3d, "lock_rotation", text="Lock View Rotation")

def register():
    bpy.types.VIEW3D_PT_view3d_lock.append(draw_lock_rotation)


def unregister():
    bpy.types.VIEW3D_PT_view3d_lock.remove(draw_lock_rotation)

if __name__ == "__main__":
    register()