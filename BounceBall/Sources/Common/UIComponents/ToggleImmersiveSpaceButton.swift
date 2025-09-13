//
//  ToggleImmersiveSpaceButton.swift
//  BounceBall
//
//  Created by apple on 9/12/25.
//

import SwiftUI

struct ToggleImmersiveSpaceButton: View {

    @Environment(AppModel.self) private var appModel

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        Button {
            Task { @MainActor in
                switch appModel.immersiveSpaceState {
                    case .vr:
                        appModel.immersiveSpaceState = .inTransition
                        await dismissImmersiveSpace()
                        await openImmersiveSpace(id: appModel.immersiveSpaceARID)
                        // Don't set immersiveSpaceState to .closed because there
                        // are multiple paths to ImmersiveView.onDisappear().
                        // Only set .closed in ImmersiveView.onDisappear().

                    case .ar:
                        appModel.immersiveSpaceState = .inTransition
                        await dismissImmersiveSpace()
                        await openImmersiveSpace(id: appModel.immersiveSpaceVRID)

                    case .inTransition:
                        // This case should not ever happen because button is disabled for this case.
                        break
                }
            }
        } label: {
            Text(appModel.immersiveSpaceState == .vr ? "현실 공간" : "가상 공간")
        }
        .disabled(appModel.immersiveSpaceState == .inTransition)
        .animation(.none, value: 0)
        .fontWeight(.semibold)
    }
}
