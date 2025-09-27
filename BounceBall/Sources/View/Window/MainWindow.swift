import SwiftUI
import simd

struct MainWindow: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        GeometryReader3D { proxy in
            VStack {
                Text("주변 벽에 공을 던져 마음껏 가지고 놀아보세요")
                .padding()
                HStack {
                    ToggleImmersiveSpaceButton()
                    Button(appModel.ballPresent ? "공 초기화" : "공 생성하기") {
                        let windowCenter = proxy.frame(in: .immersiveSpace).center
                        appModel.windowPosition = SIMD3<Float>(
                            Float(windowCenter.x / 1000),
                            -Float(windowCenter.y / 1000),
                            Float(windowCenter.z / 1000) + 0.3
                        )

                        if appModel.ballPresent {
                            appModel.ballPosition = appModel.windowPosition
                            print("windowPosition: \(appModel.windowPosition)")
                        } else {
                            appModel.ballPresent = true
                            appModel.ballPosition = appModel.windowPosition
                            print("windowPosition: \(appModel.windowPosition)")
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
}
