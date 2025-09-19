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
    @State private var headAnchor = AnchorEntity(.head)
    @State private var immersiveRoot: Entity?
    @State private var ball: TennisBallEntity?

    var body: some View {
        RealityView { content in
            // 앵커 추가
            content.add(worldAnchor)
            content.add(headAnchor)

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
            print("isPresent: \(previous) -> \(present)")
            if present {
                // 헤드 기준 로컬 좌표로 60cm 앞, 1m 높이에 스폰
                let spawnLocal = SIMD3<Float>(0, 1.0, -0.6)
                Task {
                    await spawnBall(headLocal: spawnLocal)
                }
            } else {
                removeBallIfNeeded()
            }
        }
        // ImmersiveView가 나중에 열릴 때도 반영
        .task {
            if appModel.ballPresent, ball == nil {
                let spawnLocal = SIMD3<Float>(0, 1.0, -0.6)
                await spawnBall(headLocal: spawnLocal)
            }
        }
    }

    private func parentForContent() -> Entity {
        immersiveRoot ?? worldAnchor
    }

    @MainActor
    private func spawnBall(headLocal: SIMD3<Float>) async {
        do {
            let newBall = try await TennisBallEntity.loadAsync()
            newBall.name = "TennisBall"

            let parent = parentForContent()
            let worldPos = headAnchor.convert(position: headLocal, to: parent)
            parent.addChild(newBall)
            newBall.position = worldPos

            // 기본 충돌 필터 명시 (의도치 않은 필터 문제 예방)
            if var collision = newBall.components[CollisionComponent.self] {
                collision.filter = CollisionFilter(group: .default, mask: .all)
                newBall.components[CollisionComponent.self] = collision
            }

            ball = newBall
            print("Ball spawned at \(worldPos) parent=\(parent.name)")
        } catch {
            print("spawn error: \(error)")
        }
    }

    @MainActor
    private func removeBallIfNeeded() {
        if let existing = ball {
            existing.removeFromParent()
            ball = nil
            print("Ball removed")
            return
        }
        if let byName = parentForContent().findEntity(named: "TennisBall")
            ?? worldAnchor.findEntity(named: "TennisBall")
            ?? headAnchor.findEntity(named: "TennisBall") {
            byName.removeFromParent()
            print("Ball removed (found by name)")
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveVRView()
        .environment(AppModel())
}