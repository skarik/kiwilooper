#macro kAudioFalloffModelExponential 0
#macro kAudioFalloffModelLinear 1

#macro kAudioSpatial2D 0.0
#macro kAudioSpatial3D 1.0

z = 0;

loop = false;
priority = 5;

falloff_start = 100;
falloff_end = 1000;
falloff_factor = 1.0;
falloff_model = kAudioFalloffModelExponential;

gain = 1.0;
pitch = 1.0;
channel = kFAMixChannelDefault;
spatial = kAudioSpatial3D;

parent = null;

// System:
m_sound = "";
m_buffer = nullptr;
//m_streamed = false;
//m_emitter = audio_emitter_create();
//m_instance = null;
m_source = nullptr;


alarm[0] = 1;  // Alarm to play sound
//alarm[1] = 20; // Alarm to check for destruction

m_despawnTimerEnabled = false;
m_despawnTimer = 0.0;
m_despawnTimerCounter = 0.0;