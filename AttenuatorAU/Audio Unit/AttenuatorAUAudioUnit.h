//
//  AttenuatorAUAudioUnit.h
//  AttenuatorAU
//
//  Created by Vlad Gorlov on 04.04.20.
//  Copyright © 2020 Vlad Gorlov. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "AttenuatorAUDSPKernelAdapter.h"

// Define parameter addresses.
extern const AudioUnitParameterID myParam1;

@interface AttenuatorAUAudioUnit : AUAudioUnit

@property (nonatomic, readonly) AttenuatorAUDSPKernelAdapter *kernelAdapter;
- (void)setupAudioBuses;
- (void)setupParameterTree;
- (void)setupParameterCallbacks;
@end
