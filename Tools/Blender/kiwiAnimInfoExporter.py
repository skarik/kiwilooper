import bpy
import kiwiCommon

# ==================================================================================

console_print = kiwiCommon.console_print
register_class = kiwiCommon.register_class
unregister_class = kiwiCommon.unregister_class

# ==================================================================================

class PropertyGroup_KiwiTools_Object(bpy.types.PropertyGroup):
	object: bpy.props.PointerProperty(
		type=bpy.types.ID,
		)

class SceneProperties_KiwiTools_AnimInfoExport(bpy.types.PropertyGroup):
	tracked_transforms: bpy.props.CollectionProperty(
		type=PropertyGroup_KiwiTools_Object,
		name="Tracked Transforms",
		description="Transforms that will be tracked and exported",
		)
	
	tracked_transforms_index: bpy.props.IntProperty(
		name="Index for list",
		default=0,
		)
		
	export_markers: bpy.props.BoolProperty(
		name="Use Markers",
		description="If enabled, exports animation",
		default=True,
		)
	
	export_path: bpy.props.StringProperty(
		name="Export Directory",
		description="Path to directory where the files are created",
		default="//",
		maxlen=1024,
		subtype="DIR_PATH",
		)

# ==================================================================================

class UIList_KiwiTools_Objects(bpy.types.UIList):
	def draw_item(self, context, layout, data, item, icon, active_data, active_propname, index):
		# We could write some code to decide which icon to use here...
		custom_icon = 'OBJECT_DATAMODE'
		

		# Make sure your code supports all 3 layout types
		if self.layout_type in {'DEFAULT', 'COMPACT'}:
			# Display the object & icon
			if item.object is not None:
				#classname = item.object.bl_rna.properties['type'].enum_items[item.object.type].name
				#classtype = getattr(bpy.types, classname)
				#layout.label(text=item.object.name, icon=item.object.type)
				#layout.label(text=item.object.name, icon_value=layout.icon(classtype))
				layout.label(text=item.object.name, icon=item.object.bl_rna.properties['type'].enum_items[item.object.type].icon)
			else:
				layout.label(text="<Invalid>", icon=custom_icon)

		elif self.layout_type in {'GRID'}:
			layout.alignment = 'CENTER'
			layout.label(text="", icon=custom_icon)

class View3DPanel_KiwiTools_AnimInfoExporter(bpy.types.Panel):
	bl_space_type = 'VIEW_3D'
	bl_region_type = 'UI'
	bl_category = "Kiwi"
	bl_label = "Export Info"
	
	def draw(self, context):
		layout = self.layout
		layout.use_property_split = True
		layout.use_property_decorate = False  # No animation.
		
		# Need a layout list of objects w/ transforms
		col = layout.column()
		col.label(text="Tracks to Export")
		col.template_list(
			"UIList_KiwiTools_Objects", "DEFAULT",
			context.scene.kiwitools_animinfo, "tracked_transforms",
			context.scene.kiwitools_animinfo, "tracked_transforms_index"
			)
		
		row = col.row(align=True)
		row.operator("kiwitools.animinfo_add_item", text="Selected", icon='ADD')
		row.operator("kiwitools.animinfo_delete_item", text="Delete Item", icon='REMOVE')
		
		#If exporting marker data?
		col = layout.column()
		col.prop(context.scene.kiwitools_animinfo, "export_markers")
		
		# Need an "export file" filename
		layout.prop(context.scene.kiwitools_animinfo, "export_path", text="")
		
		# Need a button for "export"
		
		# Looping thru animation, also check Markers
		layout.operator("kiwitools.animinfo_export", text="Export", icon='EXPORT')
		

class Operator_KiwiTools_ExportListNewItem(bpy.types.Operator):
	bl_idname = "kiwitools.animinfo_add_item"
	bl_label = "Add new item to listng"
	
	def execute(self, context):
		if len(context.selected_objects) > 0:
			# Grab the main selected object
			new_object = context.selected_objects[0]
			if new_object is not None:
				# Save it
				tracked_item = context.scene.kiwitools_animinfo.tracked_transforms.add()
				tracked_item.object = new_object
			return {'FINISHED'}
		return {'CANCELLED'}
		
class Operator_KiwiTools_ExportListDeleteItem(bpy.types.Operator):
	bl_idname = "kiwitools.animinfo_delete_item"
	bl_label = "Remove highlighted list item"
	
	def execute(self, context):
		animinfo = context.scene.kiwitools_animinfo
		# Remove highlighted object
		if animinfo.tracked_transforms_index is not None:
			animinfo.tracked_transforms.remove(animinfo.tracked_transforms_index)
			animinfo.tracked_transforms_index = min(max(0, animinfo.tracked_transforms_index - 1), len(animinfo.tracked_transforms) - 1)
		return {'FINISHED'}

class Operator_KiwiTools_AnimInfoExport(bpy.types.Operator):
	bl_idname = "kiwitools.animinfo_export"
	bl_label = "Animation Info Export"
	bl_description = "Export marker data and selected objects' animation transformation."

	def execute(self, context):
		#from . import export
		#ret = export.write_mesh(context, self.report)
		ret = 0

		if ret:
			return {'FINISHED'}

		return {'CANCELLED'}

# ==================================================================================

classes = (
	PropertyGroup_KiwiTools_Object,
	SceneProperties_KiwiTools_AnimInfoExport,

	UIList_KiwiTools_Objects,
	View3DPanel_KiwiTools_AnimInfoExporter,
	Operator_KiwiTools_ExportListNewItem,
	Operator_KiwiTools_ExportListDeleteItem,
	Operator_KiwiTools_AnimInfoExport,
	)

def register():
	# Register all classes in this file first
	for a_class in classes:
		register_class(a_class)

	# Free structure for scene state
	try:
		del bpy.types.Scene.kiwitools_animinfo
		console_print("Cleared off old scene state")
	except:
		console_print("Could not unregister scene props")
	
	# Create structure for global state
	bpy.types.Scene.kiwitools_animinfo = bpy.props.PointerProperty(type=SceneProperties_KiwiTools_AnimInfoExport)
	
	console_print("registered kiwiAnimInfoExporter.py")
	
def unregister():
	# Free structure for scene state
	del bpy.types.Scene.kiwitools_animinfo
	
	# Unregister all classes in this file last
	for a_class in classes:
		unregister_class(a_class)
	
	console_print("unregistered kiwiAnimInfoExporter.py")