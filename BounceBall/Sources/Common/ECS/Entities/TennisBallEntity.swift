import RealityKit
import RealityKitContent
import simd

final class TennisBallEntity: Entity {
    static func loadAsync() async throws -> TennisBallEntity {
        let loaded = try await Entity(named: "TennisBall", in: realityKitContentBundle)
        
        let ball = TennisBallEntity()
        ball.addChild(loaded)

        ball.generateCollisionShapes(recursive: true)

        ball.components.set(
            PhysicsBodyComponent(
                massProperties: .init(mass: 0.057),
                material: .default,
                mode: .dynamic
            )
        )

        ball.components.set(PhysicsMotionComponent())

        return ball
    }

    var position: SIMD3<Float> {
        get { transform.translation }
        set { transform.translation = newValue }
    }
}