//
//  AttenuatorDSP.mm
//  AttenuatorAU
//
//  Created by Vlad Gorlov on 05.04.20.
//  Copyright © 2020 Vlad Gorlov. All rights reserved.
//

#include "AttenuatorDSP.h"

@implementation AttenuatorDSP

- (instancetype)init {
   self = [super init];
   if (self) {
      self.paramGain = 1;
   }
   return self;
}

- (void)process:(AUAudioFrameCount)frameCount inBufferListPtr:(AudioBufferList*)inBufferListPtr outBufferListPtr:(AudioBufferList*)outBufferListPtr {
   
   _maximumMagnitude = 0;
   for (int channel = 0; channel < _numberOfChannels; ++channel) {
      // Get pointer to immutable input buffer and mutable output buffer
      const float* inPtr = (float*)inBufferListPtr->mBuffers[channel].mData;
      float* outPtr = (float*)outBufferListPtr->mBuffers[channel].mData;
      
      // Perform per sample dsp on the incoming float `inPtr` before asigning it to `outPtr`
      for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
         float value = inPtr[frameIndex];
         if (!_isBypassed) {
            value *= _paramGain;
         }
         outPtr[frameIndex] = value;
         _maximumMagnitude = fmax(_maximumMagnitude, value);
      }
   }
}

@end
