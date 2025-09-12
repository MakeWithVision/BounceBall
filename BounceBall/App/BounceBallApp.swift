//
//  BounceBallApp.swift
//  BounceBall
//
//  Created by apple on 9/12/25.
//

import SwiftUI

@main
struct BounceBallApp: App {

  @State private var appModel = AppModel()
  @Environment(\.openWindow) private var openWindow
  @Environment(\.dismissWindow) private var dismissWindow

  var body: some Scene {
    WindowGroup(id: "MainWindow") {
      ContentView()
        .environment(appModel)
    }

    ImmersiveSpace(id: appModel.immersiveSpaceID) {
      ImmersiveView()
        .environment(appModel)
        .onAppear {
          appModel.immersiveSpaceState = .open
          openWindow(id: "MainWindow")
        }
        .onDisappear {
          appModel.immersiveSpaceState = .closed
          dismissWindow(id: "MainWindow")
        }
    }
    .immersionStyle(selection: .constant(.mixed), in: .mixed)
  }
}
