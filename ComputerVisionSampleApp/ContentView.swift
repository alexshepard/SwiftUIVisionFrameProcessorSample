//
//  ContentView.swift
//  ComputerVisionSampleApp
//
//  Created by Alex Shepard on 8/8/23.
//

import SwiftUI

struct ContentView: View {
    @State private var isPresentingFrameProcessor = false

    var body: some View {
        VStack {
            Button {
                isPresentingFrameProcessor.toggle()
            } label: {
                Image(systemName: "camera")
                    .imageScale(.large)
            }
        }
        .sheet(isPresented: $isPresentingFrameProcessor) {
            NavigationView {
                CameraView()
                    .toolbar {
                        Button("Done") {
                            isPresentingFrameProcessor.toggle()
                        }
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
