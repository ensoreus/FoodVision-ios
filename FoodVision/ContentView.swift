//
//  ContentView.swift
//  FoodVision
//
//  Created by Philipp Maluta on 21.10.2022.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {

    @ObservedObject var viewModel = ClassifyViewModel()

    func makeUIView(context: Context) -> ARView {
        viewModel.arView = ARView(frame: .zero)
        
        // Load the "Box" scene from the "Experience" Reality File
        let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        viewModel.arView.scene.anchors.append(boxAnchor)
        return viewModel.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}

    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {

        let labelNode = SKLabelNode(text: self.viewModel.classification)
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        return labelNode;

    }

    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewModel.touchBegan()
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
