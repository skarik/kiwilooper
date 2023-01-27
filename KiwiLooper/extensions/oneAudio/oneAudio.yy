{
  "resourceType": "GMExtension",
  "resourceVersion": "1.2",
  "name": "oneAudio",
  "optionsFile": "options.json",
  "options": [],
  "exportToGame": true,
  "supportedTargets": -1,
  "extensionVersion": "0.0.1",
  "packageId": "",
  "productId": "",
  "author": "",
  "date": "2020-09-14T12:41:30.972518-07:00",
  "license": "",
  "description": "",
  "helpfile": "",
  "iosProps": false,
  "tvosProps": false,
  "androidProps": false,
  "installdir": "",
  "files": [
    {"resourceType":"GMExtensionFile","resourceVersion":"1.0","name":"","filename":"oneAudio.dll","origname":"","init":"","final":"","kind":1,"uncompress":false,"functions":[
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioInitialize","externalName":"AudioInitialize","kind":1,"help":"zero","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioFree","externalName":"AudioFree","kind":1,"help":"","hidden":false,"returnType":2,"argCount":0,"args":[],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioBufferLoad","externalName":"AudioBufferLoad","kind":1,"help":"filename","hidden":false,"returnType":2,"argCount":0,"args":[
            1,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioBufferFree","externalName":"AudioBufferFree","kind":1,"help":"buffer","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceCreate","externalName":"AudioSourceCreate","kind":1,"help":"buffer","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceDestroy","externalName":"AudioSourceDestroy","kind":1,"help":"source","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourcePlay","externalName":"AudioSourcePlay","kind":1,"help":"source, reset","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioUpdate","externalName":"AudioUpdate","kind":1,"help":"deltatime_in_sec","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSetChannelGain","externalName":"AudioSetChannelGain","kind":1,"help":"channel - kFAMixChannel, gain","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSetSoundSpeed","externalName":"AudioSetSoundSpeed","kind":1,"help":"speed_of_sound","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioListenerCreate","externalName":"AudioListenerCreate","kind":1,"help":"","hidden":false,"returnType":2,"argCount":0,"args":[],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioListenerDestroy","externalName":"AudioListenerDestroy","kind":1,"help":"listener","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioListenerSetPosition","externalName":"AudioListenerSetPosition","kind":1,"help":"listener, x, y, z","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioListenerSetVelocity","externalName":"AudioListenerSetVelocity","kind":1,"help":"listener, x, y, z","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioListenerSetOrientation","externalName":"AudioListenerSetOrientation","kind":1,"help":"listener, x_forward, y_forward, z_forward, x_up, y_up, z_up","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
            2,
            2,
            2,
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourcePause","externalName":"AudioSourcePause","kind":1,"help":"source","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceStop","externalName":"AudioSourceStop","kind":1,"help":"source","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceIsPlaying","externalName":"AudioSourceIsPlaying","kind":1,"help":"source","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourcePlayed","externalName":"AudioSourcePlayed","kind":1,"help":"source","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceSetPlaybackTime","externalName":"AudioSourceSetPlaybackTime","kind":1,"help":"source, time","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceGetPlaybackTime","externalName":"AudioSourceGetPlaybackTime","kind":1,"help":"source","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceGetSoundLength","externalName":"AudioSourceGetSoundLength","kind":1,"help":"source","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceGetCurrentMagnitude","externalName":"AudioSourceGetCurrentMagnitude","kind":1,"help":"source","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceSetPosition","externalName":"AudioSourceSetPosition","kind":1,"help":"source, x, y, z","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceSetVelocity","externalName":"AudioSourceSetVelocity","kind":1,"help":"source, x, y, z","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceSetLooped","externalName":"AudioSourceSetLooped","kind":1,"help":"source, looped","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceSetPitch","externalName":"AudioSourceSetPitch","kind":1,"help":"source, pitch","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceSetGain","externalName":"AudioSourceSetGain","kind":1,"help":"source, gain","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceSetSpatial","externalName":"AudioSourceSetSpatial","kind":1,"help":"source, spatial - 0 for 2d - 1 for 3d","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceSetChannel","externalName":"AudioSourceSetChannel","kind":1,"help":"source, channel - kFAMixChannel","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceSetFalloff","externalName":"AudioSourceSetFalloff","kind":1,"help":"source, min_dist, max_dist","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioSourceSetFalloffModel","externalName":"AudioSourceSetFalloffModel","kind":1,"help":"source, model - kFAFalloff, falloff","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioBufferGetLength","externalName":"AudioBufferGetLength","kind":1,"help":"buffer","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioEffectDestroy","externalName":"AudioEffectDestroy","kind":1,"help":"effect","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioEffectCreateLowPass1","externalName":"AudioEffectCreateLowPass1","kind":1,"help":"channel - kFAMixChannel","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioEffectLowPass1SetParams","externalName":"AudioEffectLowPass1SetParams","kind":1,"help":"effect, cutoffPitch, cutoffFade, strength","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
            2,
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioEffectLowPass1GetCutoffPitch","externalName":"AudioEffectLowPass1GetCutoffPitch","kind":1,"help":"effect","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioEffectLowPass1GetCutoffFade","externalName":"faudioEffectLowPass1GetCutoffFade","kind":1,"help":"effect","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioEffectLowPass1GetCutoffStrength","externalName":"AudioEffectLowPass1GetCutoffStrength","kind":1,"help":"effect","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioUtilGetCurrentTime","externalName":"UtilGetCurrentTime","kind":1,"help":"","hidden":false,"returnType":2,"argCount":0,"args":[],"documentation":"",},
        {"resourceType":"GMExtensionFunction","resourceVersion":"1.0","name":"faudioUtilGetFileLastEditTime","externalName":"UtilGetFileLastEditTime","kind":1,"help":"","hidden":false,"returnType":2,"argCount":0,"args":[
            1,
          ],"documentation":"",},
      ],"constants":[
        {"resourceType":"GMExtensionConstant","resourceVersion":"1.0","name":"kFAMixChannelDefault","value":"0","hidden":false,},
        {"resourceType":"GMExtensionConstant","resourceVersion":"1.0","name":"kFAMixChannelPhysics","value":"1","hidden":false,},
        {"resourceType":"GMExtensionConstant","resourceVersion":"1.0","name":"kFAMixChannelHeavy","value":"2","hidden":false,},
        {"resourceType":"GMExtensionConstant","resourceVersion":"1.0","name":"kFAMixChannelSpeech","value":"3","hidden":false,},
        {"resourceType":"GMExtensionConstant","resourceVersion":"1.0","name":"kFAMixChannelBackground","value":"4","hidden":false,},
        {"resourceType":"GMExtensionConstant","resourceVersion":"1.0","name":"kFAMixChannelMusic","value":"5","hidden":false,},
        {"resourceType":"GMExtensionConstant","resourceVersion":"1.0","name":"kFAFalloffLinear","value":"0","hidden":false,},
        {"resourceType":"GMExtensionConstant","resourceVersion":"1.0","name":"kFAFalloffPower","value":"1","hidden":false,},
        {"resourceType":"GMExtensionConstant","resourceVersion":"1.0","name":"kFAFalloffInverse","value":"2","hidden":false,},
        {"resourceType":"GMExtensionConstant","resourceVersion":"1.0","name":"kFAFalloffExponential","value":"3","hidden":false,},
      ],"ProxyFiles":[],"copyToTargets":35218731827264,"usesRunnerInterface":false,"order":[
        {"name":"faudioInitialize","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioFree","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioUpdate","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSetChannelGain","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSetSoundSpeed","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioListenerCreate","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioListenerDestroy","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioListenerSetPosition","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioListenerSetVelocity","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioListenerSetOrientation","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioBufferLoad","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioBufferFree","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioBufferGetLength","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceCreate","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceDestroy","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourcePlay","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourcePause","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceStop","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceIsPlaying","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourcePlayed","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceSetPlaybackTime","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceGetPlaybackTime","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceGetSoundLength","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceGetCurrentMagnitude","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceSetPosition","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceSetVelocity","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceSetLooped","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceSetPitch","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceSetGain","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceSetSpatial","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceSetChannel","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceSetFalloff","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioSourceSetFalloffModel","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioEffectDestroy","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioEffectCreateLowPass1","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioEffectLowPass1SetParams","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioEffectLowPass1GetCutoffPitch","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioEffectLowPass1GetCutoffFade","path":"extensions/oneAudio/oneAudio.yy",},
        {"name":"faudioEffectLowPass1GetCutoffStrength","path":"extensions/oneAudio/oneAudio.yy",},
      ],},
    {"resourceType":"GMExtensionFile","resourceVersion":"1.0","name":"","filename":"oneCoreExt.dll","origname":"","init":"","final":"","kind":1,"uncompress":false,"functions":[],"constants":[],"ProxyFiles":[],"copyToTargets":-1,"usesRunnerInterface":false,"order":[],},
  ],
  "classname": "",
  "tvosclassname": null,
  "tvosdelegatename": null,
  "iosdelegatename": "",
  "androidclassname": "",
  "sourcedir": "",
  "androidsourcedir": "",
  "macsourcedir": "",
  "maccompilerflags": "",
  "tvosmaccompilerflags": "",
  "maclinkerflags": "",
  "tvosmaclinkerflags": "",
  "iosplistinject": "",
  "tvosplistinject": "",
  "androidinject": "",
  "androidmanifestinject": "",
  "androidactivityinject": "",
  "gradleinject": "",
  "androidcodeinjection": "",
  "hasConvertedCodeInjection": true,
  "ioscodeinjection": "",
  "tvoscodeinjection": "",
  "iosSystemFrameworkEntries": [],
  "tvosSystemFrameworkEntries": [],
  "iosThirdPartyFrameworkEntries": [],
  "tvosThirdPartyFrameworkEntries": [],
  "IncludedResources": [],
  "androidPermissions": [],
  "copyToTargets": 35218731827264,
  "iosCocoaPods": "",
  "tvosCocoaPods": "",
  "iosCocoaPodDependencies": "",
  "tvosCocoaPodDependencies": "",
  "parent": {
    "name": "Extensions",
    "path": "folders/Extensions.yy",
  },
}