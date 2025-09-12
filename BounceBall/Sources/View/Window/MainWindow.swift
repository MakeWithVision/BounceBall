import SwiftUI

struct MainWindow: View {
    @Environment(BallModel.self) private var ballModel

    var body: some View {
        Text("주변 벽에 공을 던져 마음껏 가지고 놀아보세요")
        .padding()
        HStack {
            ToggleImmersiveSpaceButton()
            Button(ballModel.isPressent ? "공 초기화" : "공 생성하기") {
                if ballModel.isPressent {
                    ballModel.reset()
                } else {
                    ballModel.isPressent = true
                }
            }
        }
    }
}

#Preview {
    MainWindow()
        .environment(BallModel())
}