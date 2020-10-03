/// @description Keep-alive audio

faudioSetChannelGain(kFAMixChannelDefault,		Settings.audio_sfx_volume * Settings.audio_total_volume);
faudioSetChannelGain(kFAMixChannelBackground,	Settings.audio_sfx_volume * Settings.audio_total_volume);
faudioSetChannelGain(kFAMixChannelHeavy,		Settings.audio_sfx_volume * Settings.audio_total_volume);
faudioSetChannelGain(kFAMixChannelPhysics,		Settings.audio_sfx_volume * Settings.audio_total_volume);
faudioSetChannelGain(kFAMixChannelSpeech,		Settings.audio_speech_volume * Settings.audio_total_volume);
faudioSetChannelGain(kFAMixChannelMusic,		Settings.audio_music_volume * Settings.audio_total_volume);

faudioUpdate(Time.deltaTime);