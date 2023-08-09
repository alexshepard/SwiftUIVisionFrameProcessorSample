//
//  CameraDataModel.swift
//  ComputerVisionSampleApp
//
//  Created by Alex Shepard on 8/8/23.
//

import AVFoundation
import SwiftUI
import Vision
import CoreML
import os.log
import Accelerate

final class CameraDataModel: ObservableObject {
    public let camera = Camera()

    var countedFrames = 0
    var fpsCounterStartTime: Date?

    @Published var predictionTime: String?
    @Published var prediction: String?
    @Published var predictedScore: String?
    @Published var fps: String?

    var isPhotosLoaded = false

    var visionModel: VNCoreMLModel?
    let taxonomy = TTaxonomy()

    init() {
        let configuration = MLModelConfiguration()
        do {
            self.visionModel = try VNCoreMLModel(for: INatVision_2_4_fact256_8bit(configuration: configuration).model)
        } catch let error {
            print("got an error loading the model \(error.localizedDescription)")
        }

        if let taxUrl = Bundle.main.url(forResource: "taxonomy", withExtension: "json") {
            do {
                try self.taxonomy.loadTaxonomy(taxUrl: taxUrl)
            } catch {
                print("Couldn't load taxonomy")
            }
        } else {
            print("Couldn't find taxonomy")
        }

        Task {
            await handleCameraCV()
        }
    }

    func handleCameraCV() async {
        for await f in camera.frameStream {
            Task {
                if fpsCounterStartTime == nil {
                    fpsCounterStartTime = .now
                }

                if let model = visionModel {
                    let request = VNCoreMLRequest(model: model) { fin, err in
                        let frameProcessStart = Date()

                        guard let results = fin.results as? [VNCoreMLFeatureValueObservation] else { return }
                        guard let fv = results.first?.featureValue else { return }
                        guard let preds = fv.multiArrayValue else { return }

                        assert(preds.dataType == .float32)

                        let ptr = UnsafeMutablePointer<Float32>(OpaquePointer(preds.dataPointer))
                        let count = preds.count
                        var score: Float = 0
                        var yhat: vDSP_Length = 0
                        vDSP_maxvi(ptr, vDSP_Stride(1), &score, &yhat, vDSP_Length(count))

                        let doubleScore = Double(score) * 100
                        guard let taxon = self.taxonomy.leafClassIdToTax[Int(yhat)] else { return }

                        let frameProcessElapsed = Date().timeIntervalSince(frameProcessStart)

                        self.countedFrames += 1
                        let fpsCounterElapsedTime = Date().timeIntervalSince(self.fpsCounterStartTime!)
                        let fps = Double(self.countedFrames) / fpsCounterElapsedTime

                        Task { @MainActor in
                            self.prediction = taxon.name
                            self.predictionTime = "\(frameProcessElapsed.formatted(.number.precision(.fractionLength(8))))s"
                            self.predictedScore = "\(doubleScore.formatted(.number.precision(.fractionLength(2))))%"
                            self.fps = "\(fps.formatted(.number.precision(.fractionLength(2))))"
                        }

                        // every 100 frames start counting from scratch
                        if (self.countedFrames > 100) {
                            self.countedFrames = 0
                            self.fpsCounterStartTime = .now
                        }
                    }

                    do {
                        try VNImageRequestHandler(cvPixelBuffer: f, options: [:]).perform([request])
                    } catch {
                        print("error in vision request \(error.localizedDescription)")
                    }

                }
            }
        }
    }
}

fileprivate extension Image.Orientation {
    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "DataModel")


