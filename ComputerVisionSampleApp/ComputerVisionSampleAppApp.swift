//
//  ComputerVisionSampleAppApp.swift
//  ComputerVisionSampleApp
//
//  Created by Alex Shepard on 8/8/23.
//

import SwiftUI

@main
struct ComputerVisionSampleAppApp: App {
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
