import RealityKit
import simd

@MainActor
final class BallManager {
    private(set) var ball: TennisBallEntity?

    func respawnBall(parent: Entity, worldPosition: SIMD3<Float>) async {
        ball?.removeFromParent()
        ball = nil
        await spawnBall(parent: parent, worldPosition: worldPosition)
    }

    func spawnBall(parent: Entity, worldPosition: SIMD3<Float>) async {
        do {
            let newBall = try await TennisBallEntity.loadAsync()
            newBall.name = "TennisBall"
            parent.addChild(newBall)
            newBall.position = worldPosition
            ball = newBall
        } catch {
            print("spawn error: \(error)")
        }
    }
}