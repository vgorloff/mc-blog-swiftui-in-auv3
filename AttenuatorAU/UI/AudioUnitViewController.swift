//
//  AudioUnitViewController.swift
//  AttenuatorAU
//
//  Created by Vlad Gorlov on 04.04.20.
//  Copyright © 2020 Vlad Gorlov. All rights reserved.
//

import CoreAudioKit

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
   
   private lazy var auView = MainView()
   var audioUnit: AttenuatorAudioUnit?
   private var parameterObserverToken: AUParameterObserverToken?
   private var isConfigured = false
   
   public override func loadView() {
      view = auView
      preferredContentSize = NSSize(width: 200, height: 150)
   }
   
   public override var preferredMaximumSize: NSSize {
      return NSSize(width: 800, height: 600)
   }
   
   public override var preferredMinimumSize: NSSize {
      return NSSize(width: 200, height: 150)
   }
   
   public override func viewDidLoad() {
      super.viewDidLoad()
      setupViewIfNeeded()
   }
   
   public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
      let au = try AttenuatorAudioUnit(componentDescription: componentDescription, options: [])
      audioUnit = au
      DispatchQueue.main.async {
         self.setupViewIfNeeded()
      }
      return au
   }
   
   private func setupViewIfNeeded() {
      if !isConfigured, let au = audioUnit {
         isConfigured = true
         setupUI(au: au)
      }
   }
   
   private func setupUI(au: AttenuatorAudioUnit) {
      auView.setGain(au.parameterGain.value)
      parameterObserverToken = au.parameterTree?.token(byAddingParameterObserver: { address, value in
         DispatchQueue.main.async { [weak self] in
            let paramType = AttenuatorParameter.fromRawValue(address)
            switch paramType {
            case .gain:
               self?.auView.setGain(value)
            }
         }
      })
      auView.onDidChange = { [weak self] value in
         if let token = self?.parameterObserverToken {
            self?.audioUnit?.parameterGain?.setValue(value, originator: token)
         }
      }
   }
}
