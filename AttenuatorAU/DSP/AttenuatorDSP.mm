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
   
   for (int channel = 0; channel < _numberOfChannels; ++channel) {
      if (_isBypassed) {
         if (inBufferListPtr->mBuffers[channel].mData == outBufferListPtr->mBuffers[channel].mData) {
            continue;
         }
      }
      
      // Get pointer to immutable input buffer and mutable output buffer
      const float* inPtr = (float*)inBufferListPtr->mBuffers[channel].mData;
      float* outPtr = (float*)outBufferListPtr->mBuffers[channel].mData;
      
      // Perform per sample dsp on the incoming float `inPtr` before asigning it to `outPtr`
      for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
         if (_isBypassed) {
            outPtr[frameIndex] = inPtr[frameIndex];
         } else {
            outPtr[frameIndex] = _paramGain * inPtr[frameIndex];
         }
      }
   }
}

@end
