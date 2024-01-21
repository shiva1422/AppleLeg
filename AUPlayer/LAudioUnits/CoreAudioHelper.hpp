//
//  CoreAudioHelper.hpp
//  CoreAudio
//
//  Created by shivaaz on 4/9/23.
//

#ifndef CoreAudioHelper_hpp
#define CoreAudioHelper_hpp

#include <stdio.h>
#include "CoreAudioHelper.hpp"
#include <AudioToolbox/AudioToolbox.h>


class CoreAudioHelper{
    
public:
    static bool isFatalError(OSStatus error,const char* operation);
    static OSStatus getDefaultInputDeviceSampleRate(float &sampleRate);
    static int getRecordBufferSize(const AudioStreamBasicDescription *format,AudioQueueRef queue,float seconds);
    static void copyEncoderCookieToFile(AudioQueueRef queue,AudioFileID theFile) ;
};

#endif /* CoreAudioHelper_hpp */
