import SwiftUI
import simd

struct MainWindow: View {
    @Environment(BallModel.self) private var ballModel

    var body: some View {
        GeometryReader3D { proxy in
            VStack {
                Text("주변 벽에 공을 던져 마음껏 가지고 놀아보세요")
                .padding()
                HStack {
                    ToggleImmersiveSpaceButton()
                    Button(ballModel.isPresent ? "공 초기화" : "공 생성하기") {
                        let windowCenter = proxy.frame(in: . immersiveSpace).center
                        let pos = SIMD3<Float>(
                            Float(windowCenter.x),
                            Float(windowCenter.y),
                            Float(windowCenter.z) - 0.3
                        )

                        if ballModel.isPresent {
                            ballModel.isPresent = false
                        } else {
                            // ballModel.position = pos
                            ballModel.isPresent = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MainWindow()
        .environment(AppModel())
        .environment(BallModel())
}