#  <#Title#>


https://github.com/phracker/MacOSX-SDKs/blob/master/MacOSX10.8.sdk/System/Library/Frameworks/AVFoundation.framework/Versions/A/Headers/AVPlayerItemOutput.h
setting up custom video output to player:

1.after creating AVPlayerItem and player and observing the status is ready to play go to next.
2.create AVPlayerItemVideoOutput with initWithPixelBufferAttributes  
3.AVPlayerItem.add(AVPlayerItemVideoOutput).

Drawing:
4.Better use CADisplayLink callback.(although not in macos  ).in the DisplayLink callback check AVPlayerItermVideoOutput has new pixel buffer using hasNewPixelBufferForItemTime:CMTime(pts)
5.if there is a buffer , copy the buffer ,use it and release ;
        **CVPixelBuffer ref    pixBuff = [[self AVPlayerItemVideooutput] copyPixelBufferForItemTime:pts itemTimeForDisplay:&presentationItemTime];
        ** CVBufferRelease( pixBuff );


