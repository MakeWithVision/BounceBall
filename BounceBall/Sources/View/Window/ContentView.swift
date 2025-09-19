//
//  ContentView.swift
//  BounceBall
//
//  Created by apple on 9/12/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    var body: some View {
        VStack {
            MainWindow()
        }
        .padding()
        .frame(width: 384, height: 260)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
