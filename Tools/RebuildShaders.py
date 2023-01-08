#!python3
## go to ../Kiwilooper
## let's just make a list of xshader -> shader path for rebuilding

g_shaders = [
	("SolidsReference_vv.glsl", "sh_editorSolidsDebug.vsh", ""),
	("SolidsReference_p.glsl", "sh_editorSolidsDebug.fsh", ""),
	("LightingGeneral_vv.glsl", "sh_lightGeneral.vsh", ""),
	("LightingGeneral_p.glsl", "sh_lightGeneral.fsh", ""),
];

#=========================================================#
# Options
#=========================================================#

g_xshaderDirectory = "../Kiwilooper/shaders_source/";
g_gmsShaderDirectory = "../Kiwilooper/shaders/";
g_xpandaParams = "";
g_xpanda = "./XPanda/XPanda.exe"

#=========================================================#
# Misc
#=========================================================#

#colors ripped from blender
class bcolors:
	HEADER = '\033[95m'
	OKBLUE = '\033[94m'
	OKGREEN = '\033[92m'
	WARNING = '\033[93m'
	FAIL = '\033[91m'
	ENDC = '\033[0m'
	BOLD = '\033[1m'
	UNDERLINE = '\033[4m'

def enableConsoleColors():
	import ctypes
	# Pulling from kernel32 to enable VT100 processing in the console we're working in.
	l_kernel32 = ctypes.WinDLL('kernel32')
	l_hStdOut = l_kernel32.GetStdHandle(-11)
	
	mode = ctypes.c_ulong()
	l_kernel32.GetConsoleMode(l_hStdOut, ctypes.byref(mode))
	mode.value |= 0x004 # ENABLE_VIRTUAL_TERMINAL_PROCESSING 0x004
	l_kernel32.SetConsoleMode(l_hStdOut, mode)
enableConsoleColors()

#=========================================================#
# Runner
#=========================================================#

import os, subprocess, types, sys

def main():

	m_buildSucceeded = 0
	m_buildFailed = 0
	m_buildUpToDate = 0
	
	for source_filename, target_filename, extra_params in g_shaders:
		
		# Get the name without suffix
		l_targetNaked = os.path.splitext(target_filename)[0]
		
		l_sourcePath = g_xshaderDirectory + source_filename;
		l_outputPath = g_gmsShaderDirectory + l_targetNaked + "/" + target_filename;
		
		print(l_sourcePath + " >> " + l_outputPath);
		
		l_status = XPandShader(l_sourcePath, l_outputPath, extra_params, []);
		
		if (l_status == 0):
			m_buildSucceeded += 1
		else:
			m_buildFailed += 1
	
	print((bcolors.WARNING if m_buildFailed > 0 else bcolors.OKGREEN)
		  + "Shader Build: {:d} succeeded, {:d} failed, {:d} up-to-date."
		  .format(m_buildSucceeded, m_buildFailed, m_buildUpToDate)
		  + bcolors.ENDC)
	return (0 if m_buildSucceeded else 1) # Done.

#=========================================================#
# XPanda Runner
#=========================================================#

def XPandShader(shaderFilePath, outputFilePath, extraParams, macros):

	##command = ' '.join([g_xpanda,
	##			  shaderFilePath,
	##			  "--x " + g_xshaderDirectory,
	##			  "--o \"" + outputFilePath + "\"",
	##			  extraParams,
	##			  *[macro.name + "=" + macro.value for macro in macros]
	##			  ])
	##print(command)

	# Start up the reparser
	stream = subprocess.Popen(
		' '.join([g_xpanda,
				  shaderFilePath,
				  "--x " + g_xshaderDirectory,
				  "--o \"" + outputFilePath + "\"",
				  extraParams,
				  *[macro.name + "=" + macro.value for macro in macros]
				  ]),
		stdout=subprocess.PIPE)
	# Grab the output and return code
	output_bytestream = stream.communicate()
	code = stream.returncode
	
	# If there was an error on the parse...
	if True:
		# Parse the stdout bytestream
		if (output_bytestream[0] != None):
			output_string = output_bytestream[0].decode("utf-8")
			
			if ("ERROR:" in output_string):
				output_string = bcolors.FAIL + output_string + bcolors.ENDC
				code = 1 # Mark failed
				print(output_string)
			

	return code
	

#=========================================================#
# Run program
#=========================================================#

main()