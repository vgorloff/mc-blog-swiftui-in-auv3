//
//  AttenuatorAudioUnit.swift
//  AttenuatorAU
//
//  Created by Vlad Gorlov on 05.04.20.
//  Copyright © 2020 Vlad Gorlov. All rights reserved.
//

import Foundation
import AudioUnit
import AVFoundation

class AttenuatorAudioUnit: AUAudioUnit {
   
   public enum Error: Swift.Error {
      case statusError(OSStatus)
      case unableToInitialize(String)
   }
   
   private let maxNumberOfChannels: UInt32 = 8
   private let maxFramesToRender: UInt32 = 512
   
   private var _parameterTree: AUParameterTree!
   private(set) var parameterGain: AUParameter!
   
   private let dsp = AttenuatorDSP()
   
   private var inputBus: AUAudioUnitBus
   private var outputBus: AUAudioUnitBus
   private var outPCMBuffer: AVAudioPCMBuffer
   
   private var _inputBusses: AUAudioUnitBusArray!
   private var _outputBusses: AUAudioUnitBusArray!
   
   override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions) throws {
      
      guard let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2) else {
         throw Error.unableToInitialize(String(describing: AVAudioFormat.self))
      }
      inputBus = try AUAudioUnitBus(format: format)
      inputBus.maximumChannelCount = maxNumberOfChannels
      outputBus = try AUAudioUnitBus(format: format)
      outputBus.maximumChannelCount = maxNumberOfChannels
      
      guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: maxFramesToRender) else {
         throw Error.unableToInitialize(String(describing: AVAudioPCMBuffer.self))
      }
      pcmBuffer.frameLength = maxFramesToRender
      outPCMBuffer = pcmBuffer
      
      dsp.numberOfChannels = format.channelCount
      dsp.paramGain = AttenuatorParameter.gain.defaultValue
      
      try super.init(componentDescription: componentDescription, options: options)
      self.maximumFramesToRender = maxFramesToRender
      
      _parameterTree = setUpParametersTree()
      _inputBusses = AUAudioUnitBusArray(audioUnit: self, busType: AUAudioUnitBusType.input, busses: [inputBus])
      _outputBusses = AUAudioUnitBusArray(audioUnit: self, busType: AUAudioUnitBusType.output, busses: [outputBus])
   }
   
   override var parameterTree: AUParameterTree? {
      get {
         return _parameterTree
      } set {
         fatalError()
      }
   }
   
   override var shouldBypassEffect: Bool {
      get {
         return dsp.isBypassed
      } set {
         dsp.isBypassed = newValue
      }
   }
   
   public override var inputBusses: AUAudioUnitBusArray {
      return _inputBusses
   }
   
   public override var outputBusses: AUAudioUnitBusArray {
      return _outputBusses
   }
   
   override func allocateRenderResources() throws {
      // Should be equal as we created it with the same format.
      if outputBus.format.channelCount != inputBus.format.channelCount {
         setRenderResourcesAllocated(false)
         throw Error.statusError(kAudioUnitErr_FailedInitialization)
      }
      try super.allocateRenderResources()
      guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: inputBus.format, frameCapacity: maximumFramesToRender) else {
         throw Error.unableToInitialize(String(describing: AVAudioPCMBuffer.self))
      }
      pcmBuffer.frameLength = maxFramesToRender
      outPCMBuffer = pcmBuffer
      dsp.numberOfChannels = outputBus.format.channelCount
   }
   
   override var internalRenderBlock: AUInternalRenderBlock {
      return { [weak self] _, timestamp, frameCount, outputBusNumber, outputData, _, pullInputBlock in
         
         guard let this = self else {
            return kAudioUnitErr_NoConnection
         }
         if frameCount > this.maximumFramesToRender {
            return kAudioUnitErr_TooManyFramesToProcess;
         }
         
         guard let pullInputBlock = pullInputBlock else {
            return kAudioUnitErr_NoConnection
         }
         
         var pullFlags: AudioUnitRenderActionFlags = []
         
         let inputData = this.outPCMBuffer.mutableAudioBufferList
         // Instead of `inputBusNumber` we can also pass `0`
         let status = pullInputBlock(&pullFlags, timestamp, frameCount, outputBusNumber, inputData)
         
         if status != noErr {
            return status
         }
         
         /*
          Important:
          If the caller passed non-null output pointers (outputData->mBuffers[x].mData), use those.
          
          If the caller passed null output buffer pointers, process in memory owned by the Audio Unit
          and modify the (outputData->mBuffers[x].mData) pointers to point to this owned memory.
          The Audio Unit is responsible for preserving the validity of this memory until the next call to render,
          or deallocateRenderResources is called.
          
          If your algorithm cannot process in-place, you will need to preallocate an output buffer
          and use it here.
          
          See the description of the canProcessInPlace property.
          */
         let inListPointer = UnsafeMutableAudioBufferListPointer(inputData)
         let outListPointer = UnsafeMutableAudioBufferListPointer(outputData)
         for indexOfBuffer in 0 ..< outListPointer.count {
            // Shpuld be equal by default.
            outListPointer[indexOfBuffer].mNumberChannels = inListPointer[indexOfBuffer].mNumberChannels
            outListPointer[indexOfBuffer].mDataByteSize = inListPointer[indexOfBuffer].mDataByteSize
            if outListPointer[indexOfBuffer].mData == nil {
               outListPointer[indexOfBuffer].mData = inListPointer[indexOfBuffer].mData
            }
         }
         
         this.dsp.process(frameCount, inBufferListPtr: inputData, outBufferListPtr: outputData)
         
         return status
      }
   }
   
   // MARK: -
   
   var maximumMagnitude: Float {
      return dsp.maximumMagnitude
   }
   
   // MARK: - Private
   
   private func setUpParametersTree() -> AUParameterTree {
      let pGain = AttenuatorParameter.gain
      parameterGain = AUParameterTree.createParameter(withIdentifier: pGain.parameterID,
                                                      name: pGain.name, address: pGain.rawValue, min: pGain.min, max: pGain.max,
                                                      unit: AudioUnitParameterUnit.linearGain, unitName: nil, flags: [],
                                                      valueStrings: nil, dependentParameters: nil)
      parameterGain.value = pGain.defaultValue
      let tree = AUParameterTree.createTree(withChildren: [parameterGain])
      tree.implementorStringFromValueCallback = { param, value in
         guard let paramValue = value?.pointee else {
            return "-"
         }
         let param = AttenuatorParameter.fromRawValue(param.address)
         return param.stringFromValue(value: paramValue)
      }
      tree.implementorValueObserver = { [weak self] param, value in
         let param = AttenuatorParameter.fromRawValue(param.address)
         switch param {
         case .gain:
            self?.dsp.paramGain = value
         }
      }
      tree.implementorValueProvider = { [weak self] param in guard let s = self else { return AUValue() }
         let param = AttenuatorParameter.fromRawValue(param.address)
         switch param {
         case .gain:
            return s.dsp.paramGain;
         }
      }
      return tree
   }
}
