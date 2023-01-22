import bpy

# ==================================================================================

# Helper print
# Crabbed originally from https://blender.stackexchange.com/questions/93728/blender-script-run-print-to-console
def console_print(*args, **kwargs):
	context = bpy.context
	for a in context.screen.areas:
		if a.type == 'CONSOLE':
			c = {}
			c['area'] = a
			c['space_data'] = a.spaces.active
			c['region'] = a.regions[-1]
			c['window'] = context.window
			c['screen'] = context.screen
			s = " ".join([str(arg) for arg in args])
			for line in s.split("\n"):
				bpy.ops.console.scrollback_append(c, text=line)

# Wrapper for error-less class register
def register_class(classname):
	try:
		bpy.utils.unregister_class(classname)
		print("Unregistered class...")
	except:
		print("Could not unregister class")
		
	try:
		bpy.utils.register_class(classname)
	except:
		print("Could not register class")
	
	console_print("Registered \"" + str(classname) + "\"!")
	
# Wrapper for error-less class unregister
def unregister_class(classname):
	try:
		bpy.utils.unregister_class(classname)
	except:
		print("Could not unregister class")
	
	console_print("Deregistered \"" + str(classname) + "\"")
	
# ==================================================================================

