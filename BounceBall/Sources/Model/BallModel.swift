import SwiftUI
import simd

@MainActor
@Observable
class BallModel {
    var isPressent: Bool = false
    var position: SIMD3<Float> = [0, 0, 0]

    func reset(){
        position = .init(0, 0, 1)
        isPressent = false
    }
}