//
//  CoreAudioHelper.cpp
//  CoreAudio
//
//  Created by shivaaz on 4/9/23.
//

#include "CoreAudioHelper.hpp"
#include <AudioToolbox/AudioToolbox.h>
#include <CoreAudio/CoreAudioTypes.h>
#include "AVFoundation/AVFoundation.h"

bool CoreAudioHelper::isFatalError(OSStatus error, const char *operation)
{
    if (error == noErr) return false;
        char errorString[20];
        // See if it appears to be a 4-char-code
        *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
        if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4]))
        {
            errorString[0] = errorString[5] = '\'';
            errorString[6] = '\0';
        }
    else
                    // No, format it as an integer
        sprintf(errorString, "%d", (int)error);
        fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    return true;
}

void CoreAudioHelper::copyEncoderCookieToFile(AudioQueueRef queue, AudioFileID theFile)
{
    
    OSStatus error = noErr;
    UInt32 propSize;
    error = AudioQueueGetPropertySize(queue,kAudioConverterCompressionMagicCookie, &propSize);
    if(error == noErr && propSize >0)
    {
        
        
         Byte *magicCookie = (Byte *)malloc(propSize);
        
        error = AudioQueueGetProperty(queue, kAudioQueueProperty_MagicCookie, magicCookie, &propSize);
        if(isFatalError(error, "copyEncoderCookieToFileFailed"))
        {
            assert(false);
            free(magicCookie);
            return;
        }
        
        //care full about flags _MagicCookie its different for queue and file.
        error = AudioFileSetProperty(theFile, kAudioFilePropertyMagicCookieData, propSize, magicCookie);
        if(isFatalError(error, "copyEncoderCookieToFileFailed"))
        {
            assert(false);
            free(magicCookie);
            return;
        }
        
        free(magicCookie);
       
    }
}
OSStatus CoreAudioHelper::getDefaultInputDeviceSampleRate(float &sampleRate)
{
    
   //TODO mac and ios different and AudioSession and other are deprecated use AVAudioSession
    OSStatus error = noErr;
    
    //TODO IOS
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    sampleRate = [[AVAudioSession sharedInstance] sampleRate];
#endif
    
    return error;
    //below is mac or deprecated 
    /*
      OSStatus error;
         AudioDeviceID deviceID = 0;

         AudioObjectPropertyAddress propertyAddress;
         UInt32 propertySize;
         propertyAddress.mSelector = kAudioHardwarePropertyDefaultInputDevice;
         propertyAddress.mScope = kAudioObjectPropertyScopeGlobal;
         propertyAddress.mElement = 0;
         propertySize = sizeof(AudioDeviceID);
         error = AudioHardwareServiceGetPropertyData(kAudioObjectSystemObject,
                                        &propertyAddress,
                                        0,
                                        NULL,
                                        &propertySize,
                                        &deviceID);
         if (error) return error;”
     
     “ propertyAddress.mSelector = kAudioDevicePropertyNominalSampleRate;
         propertyAddress.mScope = kAudioObjectPropertyScopeGlobal;
         propertyAddress.mElement = 0;
         propertySize = sizeof(Float64);
         error = AudioHardwareServiceGetPropertyData(deviceID,
                                                     &propertyAddress,
                                                     0,
                                                     NULL,
                                                     &propertySize,
                                                     outSampleRate);

         return error;
     

   
     */
}


int CoreAudioHelper::getRecordBufferSize(const AudioStreamBasicDescription *format, AudioQueueRef queue, float seconds)
{
    
    int packets,frames,bytes;
    frames = seconds * format->mSampleRate;
    if(format->mBytesPerFrame > 0)
    {
        bytes = frames * format->mBytesPerFrame;
    }
    else
    {
        UInt32 maxPacketSize;
        if(format->mBytesPerPacket > 0)
        {
            maxPacketSize = format->mBytesPerPacket;
        }
        else
        {
            // Get the largest single packet size possible
            OSStatus err = noErr;
            UInt32 propSize = sizeof(maxPacketSize);
            AudioQueueGetProperty(queue, kAudioConverterPropertyMaximumOutputPacketSize, &maxPacketSize, &propSize);
            if(isFatalError(err, "error get property maxPacketSize"))
            {
                NSLog(@"error get max packet size error");
            }
        }
        
        if(format->mFramesPerPacket > 0)
        {
            packets = frames/format->mFramesPerPacket;
            
        }
        else
        {
            NSLog(@"Warn worst case : 1 frame per packet");
            packets = frames;
        }
        
        if(packets == 0)packets =1;
        bytes = packets * maxPacketSize;
        
    }
    return bytes;
}
