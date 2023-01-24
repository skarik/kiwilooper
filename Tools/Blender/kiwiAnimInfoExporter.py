import bpy
import kiwiCommon

# ==================================================================================

console_print = kiwiCommon.console_print
register_class = kiwiCommon.register_class
unregister_class = kiwiCommon.unregister_class

# ==================================================================================

g_exportPathIsValid = False

def OnSet_export_path(self, value):
	g_exportPathIsValid
	return None

# ==================================================================================

class PropertyGroup_KiwiTools_Object(bpy.types.PropertyGroup):
	object: bpy.props.PointerProperty(
		type=bpy.types.ID,
		)

class PropertyGroup_KiwiTools_WeakMarker(bpy.types.PropertyGroup):
	frame: bpy.props.IntProperty(
		name="Frame",
		default=0,
		)
	name: bpy.props.StringProperty(
		name="Name",
		default="",
		)

class PropertyGroup_KiwiTools_MarkerEvent(bpy.types.PropertyGroup):
	# Marker events have a marker
	marker: bpy.props.PointerProperty(
		type=PropertyGroup_KiwiTools_WeakMarker,
		)
	# And an object to potentially pull transform from
	object: bpy.props.PointerProperty(
		type=bpy.types.Object,
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
		subtype="FILE_PATH",
		)

	export_events: bpy.props.BoolProperty(
		name="Export Events",
		description="If enabled, exports markers as events",
		default=False,
		)

	tracked_events: bpy.props.CollectionProperty(
		type=PropertyGroup_KiwiTools_MarkerEvent,
		name="Events",
		description="Events that will be exported"
		)
	tracked_events_index: bpy.props.IntProperty(
		name="Index for list",
		default=0,
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

class UIList_KiwiTools_MarkerEvents(bpy.types.UIList):
	def draw_item(self, context, layout, data, item, icon, active_data, active_propname, index):
		# We could write some code to decide which icon to use here...
		custom_icon = 'OBJECT_DATAMODE'

		# Make sure your code supports all 3 layout types
		if self.layout_type in {'DEFAULT', 'COMPACT'}:
			# Display the object & icon
			if item.marker is not None:
				row = layout.row(align=True)
				split = row.split(factor=0.2, align=True)
				split.label(text=f"{item.marker.frame:d}")
				split.label(text=item.marker.name)
				if item.object is not None:
					split.label(text=item.object.name, icon=item.object.bl_rna.properties['type'].enum_items[item.object.type].icon)
				else:
					split.label(text="<No Object>")
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
			context.scene.kiwitools_animinfo, "tracked_transforms_index",
			rows=4,
			)
		
		row = col.row(align=True)
		row.operator("kiwitools.animinfo_add_item", text="Selected", icon='ADD')
		row.operator("kiwitools.animinfo_delete_item", text="Delete Item", icon='REMOVE')
		
		#If exporting event data?
		col = layout.column()
		col.prop(context.scene.kiwitools_animinfo, "export_events")
		if context.scene.kiwitools_animinfo.export_events is True:
			# Show list
			col.template_list(
				"UIList_KiwiTools_MarkerEvents", "DEFAULT",
				context.scene.kiwitools_animinfo, "tracked_events",
				context.scene.kiwitools_animinfo, "tracked_events_index",
				rows=4,
				)
			# Show tools for editing the list
			row = col.row(align=True)
			row.operator("kiwitools.animinfo_add_event", text="Selected", icon='ADD')
			row.operator("kiwitools.animinfo_delete_event", text="Delete Item", icon='REMOVE')
			col.operator("kiwitools.animinfo_assign_object_to_event", text="Assign Selected", icon='EYEDROPPER')

		#If exporting marker data?
		col = layout.column()
		col.prop(context.scene.kiwitools_animinfo, "export_markers")
		
		# Need an "export file" filename
		layout.prop(context.scene.kiwitools_animinfo, "export_path", text="")
		
		# Need a button for "export"
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



class Operator_KiwiTools_ExportListNewEvent(bpy.types.Operator):
	bl_idname = "kiwitools.animinfo_add_event"
	bl_label = "Add new item to listng"
	
	def execute(self, context):
		# Grab the main selected marker
		selected_marker = None
		for marker in context.scene.timeline_markers:
			if marker.select:
				selected_marker = marker
				break
		
		if selected_marker is not None:
			# Save it
			tracked_item = context.scene.kiwitools_animinfo.tracked_events.add()
			tracked_item.marker.name = selected_marker.name
			tracked_item.marker.frame = selected_marker.frame
			return {'FINISHED'}
		return {'CANCELLED'}
		
class Operator_KiwiTools_ExportListDeleteEvent(bpy.types.Operator):
	bl_idname = "kiwitools.animinfo_delete_event"
	bl_label = "Remove highlighted list item"
	
	def execute(self, context):
		animinfo = context.scene.kiwitools_animinfo
		# Remove highlighted object
		if animinfo.tracked_events_index is not None:
			animinfo.tracked_events.remove(animinfo.tracked_events_index)
			animinfo.tracked_events_index = min(max(0, animinfo.tracked_events_index - 1), len(animinfo.tracked_events) - 1)
		return {'FINISHED'}

class Operator_KiwiTools_ExportListAssignObjectToEvent(bpy.types.Operator):
	bl_idname = "kiwitools.animinfo_assign_object_to_event"
	bl_label = "Remove highlighted list item"
	
	def execute(self, context):
		animinfo = context.scene.kiwitools_animinfo
		# Associate selected object (or deselect if no selection)
		if animinfo.tracked_events_index is not None:
			# Assign an object
			if len(context.selected_objects) > 0 and context.selected_objects[0] is not None:
				new_object = context.selected_objects[0]
				animinfo.tracked_events[animinfo.tracked_events_index].object = new_object
			# Unassign and object
			else:
				animinfo.tracked_events[animinfo.tracked_events_index].object = None
			console_print("TODO")
		return {'FINISHED'}



class Operator_KiwiTools_AnimInfoExport(bpy.types.Operator):
	bl_idname = "kiwitools.animinfo_export"
	bl_label = "Animation Info Export"
	bl_description = "Export marker data and selected objects' animation transformation."

	@classmethod
	def poll(cls, context):
		import os
		try:
			# Check if the export path is a vaid filename
			path_blender = bpy.path.abspath(context.scene.kiwitools_animinfo.export_path)
			path_check = os.path.realpath(path_blender, strict=False)
			base_name = os.path.basename(path_check)

			if (path_check is not None) and (base_name is not None) and (not os.path.isdir(path_check)):
				return True
			else:
				return False
		except:
			return False

	def execute(self, context):
		#from . import export
		#ret = export.write_mesh(context, self.report)
		# Call into the exporter now
		ret = ExportAnimationInfo(
			scene=context.scene,
			context=context,
			export_filepath=context.scene.kiwitools_animinfo.export_path,
			markers_enabled=context.scene.kiwitools_animinfo.export_markers,
			events_enabled=context.scene.kiwitools_animinfo.export_events,
			)

		if ret:
			return {'FINISHED'}

		return {'CANCELLED'}
		
# ==================================================================================

def ExportAnimationInfo(export_filepath, scene: bpy.types.Scene=None, context: bpy.types.Context=None, markers_enabled=False, events_enabled=False):
	import os
	import math

	# Generate the filename first
	export_absfilepath = bpy.path.abspath(export_filepath)
	export_basename = str(os.path.basename(export_absfilepath)).rsplit('.', 1)[0]
	export_filename = os.path.realpath(os.path.dirname(export_absfilepath) + "/" + export_basename + ".kai")
	export_path = os.path.dirname(export_filename)

	# first ensure the path is created
	if export_path:
		# this can fail with strange errors,
		# if the dir can't be made then we get an error later.
		try:
			os.makedirs(export_path, exist_ok=True)
		except:
			import traceback
			traceback.print_exc()

	# Open the output file
	fout = open(export_filename, mode="wt")
	if fout is None:
		return False

	# Export the animation info
	fout.write(f"begin {scene.frame_start}\n")
	fout.write(f"end {scene.frame_end}\n")

	# If markers are enabled, then roll through the animation and output begin & end based on markers.
	if markers_enabled:
		fout.write("subanims\n")
		fout.write("{\n")

		# Loop through all markers to get the subanims. There's specific naming requirements.
		bInSubAnimation = False
		subAnimationName = ""
		subAnimationStart = 0

		marker: bpy.types.TimelineMarker
		for marker in sorted(scene.timeline_markers, key=lambda marker: marker.frame):
			# If any marker is noted as an "event" ignore it.
			if "event" in marker.name:
				continue
			
			# Otherwise, our marker marks an animation
			if not bInSubAnimation:
				# Save animation start
				subAnimationName = marker.name
				subAnimationStart = marker.frame
				bInSubAnimation = True
			elif "end" in marker.name or subAnimationName in marker.name:
				bInSubAnimation = False
				# If we found the end of the anim, we write it out
				fout.write(f"\t{subAnimationName} {subAnimationStart} {marker.frame}\n")
		fout.write("}\n")

	# Since we're about to mess with time, save original state
	frame_old = scene.frame_current

	# If events are enabled, then roll through the animation and output those
	if events_enabled:
		fout.write("events\n")
		fout.write("{\n")

		event_ref: PropertyGroup_KiwiTools_MarkerEvent
		for event_ref in scene.kiwitools_animinfo.tracked_events:
			# For each one, output the event information
			if event_ref.object is None:
				fout.write(f"\t{event_ref.marker.frame} {event_ref.marker.name}")
			else:
				# Set frame & evaluate the frame
				scene.frame_set(event_ref.marker.frame)
				depsgraph = context.evaluated_depsgraph_get()
				evaluated_object = event_ref.object.evaluated_get(depsgraph)

				translation	= evaluated_object.matrix_world.to_translation()
				rotation	= evaluated_object.matrix_world.to_euler('XYZ')
				scale		= evaluated_object.matrix_world.to_scale()

				# Write out the event w/ transform data
				fout.write(f"\t{event_ref.marker.frame} {event_ref.marker.name}")
				fout.write(f" {translation.x:0.12f} {translation.y:0.12f} {translation.z:0.12f}")
				fout.write(f" {math.degrees(rotation.x):0.12f} {math.degrees(rotation.y):0.12f} {math.degrees(rotation.z):0.12f}")
				fout.write(f" {scale.x:0.12f} {scale.y:0.12f} {scale.z:0.12f}\n")
		fout.write("}\n")

	# Export the transform info
	object_ref: PropertyGroup_KiwiTools_Object
	for object_ref in scene.kiwitools_animinfo.tracked_transforms:
		# For each one, roll through frame-by-frame and export TRS information
		tracked_object = object_ref.object
		tracked_object_converted = bpy.props.PointerProperty(type=bpy.types.Object)
		tracked_object_converted = tracked_object

		fout.write(f"attachment {tracked_object_converted.name}\n")
		fout.write("{\n")
		for frame in range(scene.frame_start, scene.frame_end):
			# Set frame & prep to evaluate the frame
			scene.frame_set(frame)
			depsgraph = context.evaluated_depsgraph_get()
			evaluated_object = tracked_object_converted.evaluated_get(depsgraph)

			translation	= evaluated_object.matrix_world.to_translation()
			rotation	= evaluated_object.matrix_world.to_euler('XYZ')
			scale		= evaluated_object.matrix_world.to_scale()

			fout.write(f"\t{frame}")
			fout.write(f" {translation.x:0.12f} {translation.y:0.12f} {translation.z:0.12f}")
			fout.write(f" {math.degrees(rotation.x):0.12f} {math.degrees(rotation.y):0.12f} {math.degrees(rotation.z):0.12f}")
			fout.write(f" {scale.x:0.12f} {scale.y:0.12f} {scale.z:0.12f}\n")

		fout.write("}\n")

	# Restore scene state
	scene.frame_set(frame_old)

	# Close file now that we're done
	fout.close()

	# We did it!
	return True

# ==================================================================================

classes = (
	PropertyGroup_KiwiTools_Object,
	PropertyGroup_KiwiTools_WeakMarker,
	PropertyGroup_KiwiTools_MarkerEvent,
	SceneProperties_KiwiTools_AnimInfoExport,

	UIList_KiwiTools_Objects,
	UIList_KiwiTools_MarkerEvents,
	View3DPanel_KiwiTools_AnimInfoExporter,
	Operator_KiwiTools_ExportListNewItem,
	Operator_KiwiTools_ExportListDeleteItem,
	Operator_KiwiTools_ExportListNewEvent,
	Operator_KiwiTools_ExportListDeleteEvent,
	Operator_KiwiTools_ExportListAssignObjectToEvent,
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