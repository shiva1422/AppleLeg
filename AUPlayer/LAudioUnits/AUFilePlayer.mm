//
//  AudioGraph.m
//  AUPlayer
//
//  Created by shivaaz on 4/26/23.
//

#import <Foundation/Foundation.h>
#include "AUFilePlayer.hpp"
#include "CoreAudioHelper.hpp"
#include "KSLog.h"

//TODO cpp is ok no mm req.

AudioGraphPlayer::AudioGraphPlayer(const char *filePath){
    
    initWithFile(filePath);
}

bool AudioGraphPlayer::initWithFile(const char *filePath)
{
    
    OSStatus ret = noErr;
    
    //OpenAudioFile //AudioFileServices
    CFStringRef cfFile = CFStringCreateWithCString(NULL, filePath,kCFStringEncodingUTF8);
    CFURLRef fileURL = CFURLCreateWithString(NULL, cfFile,NULL );
    
    ret = AudioFileOpenURL(fileURL, kAudioFileReadPermission, 0, &file);
    
    CFRelease(cfFile);
    CFRelease(fileURL);
    
    assert(!CoreAudioHelper::isFatalError(ret,"AudioFileOpenFailed"));
    
    //Get Input Format
    UInt32 propSize = sizeof(audioFormat);
    ret = AudioFileGetProperty(file, kAudioFilePropertyDataFormat, &propSize, &audioFormat);
    assert(!CoreAudioHelper::isFatalError(ret,"AudioFileGetPropertyFialed"));
    
    assert(createAUGraph());
    assert(prepareFileAU());

    KSLogI("AudioGraphPlayer inited");
    return true;
}

bool AudioGraphPlayer::createAUGraph()
{
    //steps 1-7 follow in order.
    //1.create AUGraph
  
    OSStatus ret = NewAUGraph(&graph);
    assert(!CoreAudioHelper::isFatalError(ret, "create AUGraph failed"));
    
    /*187
     “the component type and subtype for an audio unit are constants defined in the AUComponent.h header file and described in the Audio Unit Component Services documentation. Combining those with a constant to indicate Apple as the manufacturer, you can create a component that matches the default output audio unit”

     */
    
    
    /*2.create nodes*/
    
    //create Default Output Graph Node
    // Generate description that matches output device (speakers)”
    AudioComponentDescription cd = {0};
    cd.componentType = kAudioUnitType_Output;
    cd.componentSubType = kAudioUnitSubType_DefaultOutput;
    cd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    //Add node with above description to the graph
    AUNode outputNode;
    ret = AUGraphAddNode(graph, &cd, &outputNode);
    
    assert(!CoreAudioHelper::isFatalError(ret, "add default aunode to graph failed"));
    
    //create Generator node AU type(audio file player)
    
    AudioComponentDescription filePlayerCD = {0};
    filePlayerCD.componentType = kAudioUnitType_Generator;
    filePlayerCD.componentSubType = kAudioUnitSubType_AudioFilePlayer;
    filePlayerCD.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    //Add above node to the graph
    AUNode filePlayNode;
    ret = AUGraphAddNode(graph, &filePlayerCD, &filePlayNode);
    assert(!CoreAudioHelper::isFatalError(ret, "add filePlayNode Failed"));
    
    //3.openGraph

    //Open the graph : opens all contained audio units but resources are not allocated Yet.
    ret = AUGraphOpen(graph);
    assert(!CoreAudioHelper::isFatalError(ret, "Graph Open Failed"));
    
    //not properties can be get and set from audio units and create connecection between nodes but can't  alloc //resources Yet.
    
    //need to configure file player unit later and tell in which file and how much to play so should get pointer to it now.
    
    //4.Optional: Get audio units from nodes if you need to access any of the units directly.

    // Get the reference to the AudioUnit object for the
    // file player graph node
    
    ret = AUGraphNodeInfo(graph, filePlayNode, NULL, &fileAU);
    assert(!CoreAudioHelper::isFatalError(ret, "get file play unit failed"));
    

    //5.Connect nodes

    //connect filePlayerNode to OutputNode.
    ret = AUGraphConnectNodeInput(graph,filePlayNode, 0, outputNode, 0);//0 is port/bus/element number
    assert(!CoreAudioHelper::isFatalError(ret, "connect fileplay Node to OutputNode failed"));
    
    //6.Initialize the AUGraph.

    //initialize the graph this causes resources to be allocated
    ret = AUGraphInitialize(graph);
    assert(!CoreAudioHelper::isFatalError(ret, "initialize AUGraph failed"));
    /*
     “Unlike AUGraphOpen(), the above initialize step is potentially expensive because it allows units to allocate needed resources such as RAM or file handles. When a graph is initialized, it is potentially ready to be started. In this case, though, you have to do a little more work to set up the file player unit.”
     */
    
    
    //need play unit to do some preparation for playing specified fileID

    
    //7.Start the AUGraph.when needed
    
    return true;
    
}

bool AudioGraphPlayer::prepareFileAU()
{
    //“Provide a list of AudioFileIDs to play by setting the unit’s kAudioUnitProperty_ScheduledFileIDs //property.i.e tell file player unit to load the file we want.
   
    OSStatus ret = AudioUnitSetProperty(fileAU, kAudioUnitProperty_ScheduledFileIDs, kAudioUnitScope_Global, 0, &file, sizeof(file));
    assert(!CoreAudioHelper::isFatalError(ret, "set File propert failed"));
    
    
    //“ Define a region to play with the kAudioUnitProperty_ScheduledFileRegion property.”
    
    UInt64 nPackets;
    UInt32 propSize = sizeof(nPackets);
    ret = AudioFileGetProperty(file,kAudioFilePropertyAudioDataPacketCount,&propSize,&nPackets);
    assert(!CoreAudioHelper::isFatalError(ret, "get audio file packet count failed"));
    
    //Tell the filePlayer AU to play entire file
    
    ScheduledAudioFileRegion playRange;
    memset (&playRange.mTimeStamp, 0, sizeof(playRange.mTimeStamp));
    playRange.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    playRange.mTimeStamp.mSampleTime = 0;
    playRange.mCompletionProc = NULL;
    playRange.mCompletionProcUserData = NULL;
    playRange.mAudioFile = file;
    playRange.mLoopCount = 10;
    playRange.mStartFrame = 0;
    playRange.mFramesToPlay = nPackets * audioFormat.mFramesPerPacket;
    
    
    ret = AudioUnitSetProperty(fileAU,kAudioUnitProperty_ScheduledFileRegion,kAudioUnitScope_Global,0,&playRange,sizeof(playRange));
    
    assert(!CoreAudioHelper::isFatalError(ret, "filePlay unit set play range failed"));
    
    
    
    //“Provide a start time with the kAudioUnitProperty_ScheduleStartTimeStamp property.”
    
    // Tell the file player AU when to start playing (-1 sample time
    // means next render cycle)
    AudioTimeStamp startTime;
    memset (&startTime, 0, sizeof(startTime));
    startTime.mFlags = kAudioTimeStampSampleTimeValid;
    startTime.mSampleTime = -1;
    ret=AudioUnitSetProperty(fileAU,kAudioUnitProperty_ScheduleStartTimeStamp,kAudioUnitScope_Global,0,&startTime,sizeof(startTime));
    assert(!CoreAudioHelper::isFatalError(ret, "kAudioUnitProperty_ScheduleStartTimeS"));

    //Compute duration for convenience
    audioDuration = (nPackets * audioFormat.mFramesPerPacket) /audioFormat.mSampleRate;

    return true;
}

int AudioGraphPlayer::play()
{
    OSStatus ret = AUGraphStart(graph);
    assert(!CoreAudioHelper::isFatalError(ret, "AudioGraphStartFail"));
    return 0;
}


int AudioGraphPlayer::release()
{
    AUGraphStop(graph);
    AUGraphUninitialize(graph);
    AUGraphClose(graph);
    AudioFileClose(file);
    return 0;
}
