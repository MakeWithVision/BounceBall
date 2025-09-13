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
    .defaultSize(width: 384, height: 260)
    .windowResizability(.contentSize)

    ImmersiveSpace(id: appModel.immersiveSpaceARID) {
      ImmersiveARView()
        .environment(appModel)
        .onAppear {
          appModel.immersiveSpaceState = .ar
          
          if appModel.isFirstLaunch {
            openWindow(id: "MainWindow")
          }
          
        }
        .onDisappear {
          appModel.immersiveSpaceState = .vr
          
          if appModel.isFirstLaunch {
            appModel.makrFirstLaunchFalse()
          }
          dismissWindow(id: "MainWindow")
        }
    }
    .immersionStyle(selection: .constant(.mixed), in: .mixed)


    ImmersiveSpace(id: appModel.immersiveSpaceVRID) {
            ImmersiveVRView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .vr
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .ar
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
  }
}
