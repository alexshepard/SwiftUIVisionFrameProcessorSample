//
//  CameraView.swift
//  ComputerVisionSampleApp
//
//  Created by Alex Shepard on 8/8/23.
//
/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct CameraView: View {
    @StateObject private var model = CameraDataModel()

    var body: some View {
        NavigationView {
            ZStack {
                CameraPreview(session: model.camera.captureSession)

                VStack {
                    Spacer()
                    Text(model.prediction ?? "No prediction")

                    HStack(alignment: .bottom) {
                        Text("Score: \(model.predictedScore ?? "Dunno")")
                        Spacer()
                        Text("FPS: \(model.fps ?? "Dunno")")
                        Spacer()
                        Text("TTP: \(model.predictionTime ?? "Dunno")")
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .task {
                await model.camera.start()
            }
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .statusBar(hidden: true)
        }
    }
}
