//
//  ImmersiveView.swift
//  BounceBall
//
//  Created by apple on 9/12/25.
//

import SwiftUI
import RealityKit
import RealityKitContent
import simd

struct ImmersiveVRView: View {
    @Environment(AppModel.self) private var appModel
    @State private var worldAnchor = AnchorEntity(world: .zero)
    @State private var immersiveRoot: Entity?
    @State private var ballManager = BallManager()

    var body: some View {
        RealityView { content in
            // 앵커 추가
            content.add(worldAnchor)

            // 초기 RealityKit 컨텐츠 추가 (Immersive 루트)
            if let immersive = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                immersiveRoot = immersive
                content.add(immersive)
            }
        }
        .onAppear {
            print("ImmersiveView appeared")
        }
        .onChange(of: appModel.ballPresent) { previous, present in
            if present {
                Task { @MainActor in
                    let parent = immersiveRoot!
                    let fallback = appModel.windowPosition!
                    await ballManager.respawnBall(parent: parent, worldPosition: fallback)
                }
            }
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveVRView()
        .environment(AppModel())
}
