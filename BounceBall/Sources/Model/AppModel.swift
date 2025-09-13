//
//  AppModel.swift
//  BounceBall
//
//  Created by apple on 9/12/25.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
  // 공간 관리
    let immersiveSpaceARID = "ImmersiveSpaceAR"
    let immersiveSpaceVRID = "ImmersiveSpaceVR"

    enum ImmersiveSpaceState {
        case ar
        case inTransition
        case vr
    }
    var immersiveSpaceState = ImmersiveSpaceState.ar
  
  private(set) var isFirstLaunch: Bool = true
  
  func makrFirstLaunchFalse() {
    isFirstLaunch = false
  }
}
