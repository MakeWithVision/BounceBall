//
//  BounceBallApp.swift
//  BounceBall
//
//  Created by apple on 9/12/25.
//

import SwiftUI

@main
struct BounceBallApp: App {

<<<<<<< HEAD:BounceBall/App/BounceBallApp.swift
  @State private var appModel = AppModel()
  @Environment(\.openWindow) private var openWindow
  @Environment(\.dismissWindow) private var dismissWindow

  var body: some Scene {
    WindowGroup(id: "MainWindow") {
      ContentView()
        .environment(appModel)
=======
    @State private var appModel = AppModel()
    @State private var ballModel = BallModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .environment(ballModel)
        }
        .defaultSize(width: 384, height: 260)
        .windowResizability(.contentSize)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .environment(ballModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
>>>>>>> feat/#2:BounceBall/App/BounceBallApp2 copy.swift
    }

    ImmersiveSpace(id: appModel.immersiveSpaceID) {
      ImmersiveView()
        .environment(appModel)
        .onAppear {
          appModel.immersiveSpaceState = .open
          
          if appModel.isFirstLaunch {
            openWindow(id: "MainWindow")
          }
          
        }
        .onDisappear {
          appModel.immersiveSpaceState = .closed
          
          if appModel.isFirstLaunch {
            appModel.makrFirstLaunchFalse()
          }
          dismissWindow(id: "MainWindow")
        }
    }
    .immersionStyle(selection: .constant(.mixed), in: .mixed)
  }
}
