//
//  MainUI.swift
//  AttenuatorVST2UI
//
//  Created by Vlad Gorlov on 30.03.20.
//  Copyright © 2020 Vlad Gorlov. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

struct MainUI: View {
   
   @EnvironmentObject var sliderData: SliderData
   @State var gain: Float = 100
   
   private var onChanged: (Float) -> Void
   
   init(onChanged: @escaping (Float) -> Void) {
      self.onChanged = onChanged
   }
   
   var body: some View {
      VStack {
         Slider(value: Binding<Float>(get: { self.gain }, set: {
            self.gain = $0
            self.onChanged($0)
         }), in: 0...100, step: 2)
         Text("Gain: \(Int(gain))")
      }.onReceive(sliderData.$gain, perform: { self.gain = $0 })
   }
}
