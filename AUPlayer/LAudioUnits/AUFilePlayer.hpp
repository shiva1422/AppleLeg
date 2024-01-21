//
//  AudioGraph.h
//  AUPlayer
//
//  Created by shivaaz on 4/26/23.
//

#ifndef AudioGraph_h
#define AudioGraph_h

#include <AudioToolbox/AudioToolbox.h>


//This is no better than NSSound,AVAudioPlayer,AudioQueue,but win is in the next.
class AudioGraphPlayer{
    
public:
    
    AudioGraphPlayer(const char *filePath);
    
    AudioGraphPlayer(){};
    
    bool initWithFile(const char* path);

    int play();
    
    int release();
    
    double getDuration(){return audioDuration;}
    
    
private:
    
    bool createAUGraph();
    bool prepareFileAU();
    
    
private:
    
    AudioStreamBasicDescription audioFormat;
    AudioFileID file;
    AUGraph graph;
    
    /*“The fileAU is of type AudioUnit, which is typedef’ed as a ComponentInstance on Mac OS X 10.5 (and, therefore, is compatible with the legacy Component Manager APIs) and as an AudioComponentInstance on version 10.6 and up and on iOS. As long as your code uses the AudioUnit type, the distinction is largely irrelevant and your source will compile for the various SDKs.*/
    AudioUnit fileAU;
    Float64 audioDuration;
    
    
    
    
};

//wrapper for objective c++.
typedef struct AudioGraphPlayerWrap{
    
    AudioGraphPlayer *audioGraphPlayer;
    
    AudioGraphPlayerWrap(const char* filePath)
    {
        audioGraphPlayer = new AudioGraphPlayer(filePath);
    }
    
    int play(){return audioGraphPlayer->play();}
    
}AudioGraphPlayerWrap;

#endif /* AudioGraph_h */
