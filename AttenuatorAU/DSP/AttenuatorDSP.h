//
//  AttenuatorDSP.h
//  AttenuatorAU
//
//  Created by Vlad Gorlov on 05.04.20.
//  Copyright © 2020 Vlad Gorlov. All rights reserved.
//

#ifndef AttenuatorDSP_h
#define AttenuatorDSP_h

#import <AudioToolbox/AudioToolbox.h>

@interface AttenuatorDSP: NSObject

@property (nonatomic) float paramGain;
@property (nonatomic) bool isBypassed;
@property (nonatomic) uint numberOfChannels;

// Used by VU meter on UI side.
@property (nonatomic) float maximumMagnitude;

-(void)process:(AUAudioFrameCount)frameCount inBufferListPtr:(AudioBufferList*)inBufferListPtr outBufferListPtr:(AudioBufferList*)outBufferListPtr;

@end

#endif /* AttenuatorDSP_h */
