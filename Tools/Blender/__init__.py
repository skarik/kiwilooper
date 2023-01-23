bl_info = {
	"name": "Kiwi Tools",
	"blender": (3, 3, 1),
	"category": "Gamedev",
}

import bpy
import importlib

# ==================================================================================

# In-dev helper
# Adds the dev directory to the path if it cannot find it
if __name__ == "__main__":
	import sys, os
	this_python_filepath = bpy.path.abspath(bpy.context.space_data.text.filepath)
	this_python_basename = os.path.basename(this_python_filepath)
	if (this_python_basename == "kiwiTools.py" or this_python_basename == "__init__.py"):
		new_path = os.path.dirname(this_python_filepath)
		if not (new_path in sys.path):
			sys.path.append(new_path)

import kiwiCommon
importlib.reload(kiwiCommon)

console_print = kiwiCommon.console_print
register_class = kiwiCommon.register_class
unregister_class = kiwiCommon.unregister_class

# ==================================================================================

class View3DPanel_KiwiTools(bpy.types.Panel):
	bl_space_type = 'VIEW_3D'
	bl_region_type = 'UI'
	bl_category = "Kiwi"
	bl_label = "General"
	
	def draw(self, context):
		layout = self.layout
		layout.use_property_split = True
		layout.use_property_decorate = False  # No animation.
		layout.label(text="Hello World 1")
		
		col = layout.column(align=True)
		sub = col.column(heading="Test")
		sub.label(text="Hello World 2")

# ==================================================================================

import kiwiAnimInfoExporter
import kiwiViewLock
importlib.reload(kiwiAnimInfoExporter)
importlib.reload(kiwiViewLock)

classes = (
	View3DPanel_KiwiTools,
	)

def register():
	# Register all classes
	for a_class in classes:
		register_class(a_class)
	# Setup other modules
	kiwiAnimInfoExporter.register()

def unregister():
	# Unregister all classes
	for a_class in classes:
		unregister_class(a_class)
	# Cleanup other modules	
	kiwiAnimInfoExporter.unregister()


if __name__ == "__main__":
	register()