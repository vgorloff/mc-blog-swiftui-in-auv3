//
//  AttenuatorParameter.swift
//  AttenuatorAU
//
//  Created by Vlad Gorlov on 05.04.20.
//  Copyright © 2020 Vlad Gorlov. All rights reserved.
//

import Foundation
import AudioUnit

enum AttenuatorParameter: UInt64 {

   case gain = 1000
   
   static func fromRawValue(_ rawValue: UInt64) -> AttenuatorParameter {
      if let value = AttenuatorParameter(rawValue: rawValue) {
         return value
      }
      fatalError()
   }

   var parameterID: String {
      let prefix = "paramID:"
      switch self {
      case .gain: return prefix + "Gain"
      }
   }

   var name: String {
      switch self {
      case .gain: return "Gain"
      }
   }

   var min: AUValue {
      switch self {
      case .gain: return 0
      }
   }

   var max: AUValue {
      switch self {
      case .gain: return 1
      }
   }

   var defaultValue: AUValue {
      switch self {
      case .gain: return 1
      }
   }

   func stringFromValue(value: AUValue) -> String {
      switch self {
      case .gain: return "\(value)"
      }
   }
}
