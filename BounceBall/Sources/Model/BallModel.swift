import SwiftUI
import simd

@MainActor
@Observable
class BallModel {
    var isPresent: Bool = false
    var position: SIMD3<Float>?
}