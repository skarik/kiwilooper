if (singleton_this()) exit; // Make this object a singleton

persistent = true;

// Set defaults:
bloodDisabled = false;
settingsControlDefaults();

// Load settings
settingsLoad();

// Push it to the file
settingsSave();