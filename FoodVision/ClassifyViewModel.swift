//
//  ClassifyViewModel.swift
//  FoodVision
//
//  Created by Philipp Maluta on 20.01.2023.
//

import SwiftUI
import ARKit
import RealityKit

class ClassifyViewModel: ObservableObject {
    @Published var classification: String = ""
    @Published var currentFrame: ARFrame!
    var arView: ARView!

    lazy var classificationRequest: VNCoreMLRequest = {

        do {
            let configuration = MLModelConfiguration()
            let model = try VNCoreMLModel(for: FoodVisionBig(configuration: configuration).model)
            let request = VNCoreMLRequest(model: model) { request, error in

                // process classifications
                guard let classifications = request.results as? [VNClassificationObservation], error == nil else {
                    return
                }
                self.processClassifications(classifications)
            }

            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            print(error.localizedDescription)
            fatalError("Unable to initialize request for Machine Learning Model")
        }
    }()
    
    func processClassifications(_ classifications: [VNClassificationObservation]) {

        if let observation = classifications.first {

            self.classification = observation.identifier

            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.2
            let transform = simd_mul(self.currentFrame.camera.transform, translation)

            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            arView.session.add(anchor: anchor)
        }
    }

    func classifyImage() {

        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(UIDevice.current.orientation.rawValue)) else {
            return
        }
        let handler = VNImageRequestHandler(cvPixelBuffer: self.currentFrame.capturedImage, orientation: orientation, options: [:])

        DispatchQueue.global().async {
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func touchBegan() {
        currentFrame = arView.session.currentFrame
        classifyImage()
    }
}
