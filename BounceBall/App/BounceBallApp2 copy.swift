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
    }
}
