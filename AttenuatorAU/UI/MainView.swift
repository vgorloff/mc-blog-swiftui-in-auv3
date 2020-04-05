//
//  MainView.swift
//  AttenuatorAU
//
//  Created by Vlad Gorlov on 05.04.20.
//  Copyright © 2020 Vlad Gorlov. All rights reserved.
//

import Foundation
import SwiftUI

final class SliderData: ObservableObject {
   
   @Published var gain: Float = 100
}

class MainView: NSView {
   
   private let sliderData = SliderData()
   private var vuView: VUView?
   private let stackView = NSStackView()
   
   var onDidChange: ((Float) -> Void)?
   var onRender: (() -> Float)?
   
   override init(frame frameRect: NSRect) {
      super.init(frame: frameRect)
      wantsLayer = true
      layer?.backgroundColor = NSColor.lightGray.cgColor
      
      do {
         let vuView = try VUView()
         stackView.addArrangedSubview(vuView)
         vuView.onRender = { [weak self] in
            return self?.onRender?() ?? 0
         }
         vuView.heightAnchor.constraint(equalToConstant: 30).isActive = true
         self.vuView = vuView
      } catch {
         assertionFailure()
         print(String(describing: error))
      }
      
      let view = NSHostingView(rootView: MainUI { [weak self] in
         let value = $0 / 100
         print("MainView> Value to Host: \(value)")
         self?.onDidChange?(value)
      }.environmentObject(sliderData))
      stackView.addArrangedSubview(view)
      view.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
      
      stackView.orientation = .vertical
      stackView.translatesAutoresizingMaskIntoConstraints = false
      addSubview(stackView)
      
      leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
      trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
      topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
      bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
      
      widthAnchor.constraint(greaterThanOrEqualToConstant: 260).isActive = true
   }
   
   required dynamic init?(coder aDecoder: NSCoder) {
      fatalError()
   }
   
   func setGain(_ value: Float) {
      print("MainView> Value from Host: \(value)")
      sliderData.gain = 100 * value
   }
}
