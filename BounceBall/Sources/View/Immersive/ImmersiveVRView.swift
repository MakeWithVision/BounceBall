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
    @State private var ball: TennisBallEntity?

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
                    await respawnBall(parent: parent)
                    print("isPresent: \(previous) -> \(present)")
                }
            }
        }
    }

    @MainActor
    private func respawnBall(parent: Entity) async {
        let fallback = appModel.windowPosition!
        if appModel.ballPresent {
            ball?.removeFromParent()
            ball = nil
            await spawnBall(parent: parent, worldPosition: fallback)
        }
        else {
            await spawnBall(parent: parent, worldPosition: fallback)
        }
    }

    @MainActor
    private func spawnBall(parent: Entity, worldPosition: SIMD3<Float>) async {
        do {
            let newBall = try await TennisBallEntity.loadAsync()
            newBall.name = "TennisBall"

            parent.addChild(newBall)
            newBall.position = worldPosition

            ball = newBall
            print("Ball spawned at \(worldPosition)")
        } catch {
            print("spawn error: \(error)")
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveVRView()
        .environment(AppModel())
}
