//
//  ARController.swift
//  Matching App
//
//  Created by Ajanth Kumarakuruparan on 2023/07/03.
//

import Foundation
import ARKit
import os


class ARController: NSObject, ObservableObject {
    
    @Published var sceneView:ARSCNView
    private let metalDevice:MTLDevice?
    //The CoreML model we use for emotion classification.
    //private let model:VNCoreMLModel
    //The scene node containing the emotion text.
    private var textNode: SCNNode?
    private let faceLogger:Logger
    var blendShapes: [ARFaceAnchor.BlendShapeLocation : NSNumber]?
    
    override init(){
        self.sceneView = ARSCNView(frame: UIScreen.main.bounds)
        self.metalDevice = MTLCreateSystemDefaultDevice()!
        self.faceLogger = Logger()
        //self.model = try! VNCoreMLModel(for: CNNEmotions().model)
        super.init()
        sceneView.showsStatistics = true
        sceneView.delegate = self
        let config = ARFaceTrackingConfiguration()
        config.isLightEstimationEnabled = true
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    /// - Parameter faceGeometry: the geometry the node is using.
    private func addTextNode(faceGeometry: ARSCNFaceGeometry) {
        let text = SCNText(string: "", extrusionDepth: 1)
        text.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemYellow
        text.materials = [material]

        let textNode = SCNNode(geometry: faceGeometry)
        textNode.position = SCNVector3(-0.1, 0.3, -0.5)
        textNode.scale = SCNVector3(0.003, 0.003, 0.003)
        textNode.geometry = text
        self.textNode = textNode
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
}

extension ARController: ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = self.metalDevice else { return nil }
        let node = SCNNode(geometry: ARSCNFaceGeometry(device: device))
        //Projects the white lines on the face.
        node.geometry?.firstMaterial?.fillMode = .lines
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let faceGeometry = node.geometry as? ARSCNFaceGeometry, textNode == nil else { return }
        addTextNode(faceGeometry: faceGeometry)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry,
              let pixelBuffer = self.sceneView.session.currentFrame?.capturedImage
        else {
            return
        }
        
        
        //Updates the face geometry.
        faceGeometry.update(from: faceAnchor.geometry)
        
        self.blendShapes = faceAnchor.blendShapes
        
        
        //Printing blend shape values
        /*
        let eyeBlinkLeft = faceAnchor.blendShapes[.eyeBlinkLeft]
        let eyeBlinkRight = faceAnchor.blendShapes[.eyeBlinkRight]
        let eyeLookUpLeft = faceAnchor.blendShapes[.eyeLookUpLeft]
        let eyeLookUpRight = faceAnchor.blendShapes[.eyeLookUpRight]
        let eyeLookDownLeft = faceAnchor.blendShapes[.eyeLookDownLeft]
        let eyeLookDownRight = faceAnchor.blendShapes[.eyeLookDownRight]
        let eyeLookInLeft = faceAnchor.blendShapes[.eyeLookInLeft]
        let eyeLookInright = faceAnchor.blendShapes[.eyeLookInRight]
        let eyeLookOutLeft = faceAnchor.blendShapes[.eyeLookOutLeft]
        let eyeLookOutRight = faceAnchor.blendShapes[.eyeLookOutRight]
        let eyeSquintLeft = faceAnchor.blendShapes[.eyeSquintLeft]
        let eyeSquintRight = faceAnchor.blendShapes[.eyeSquintRight]
        let eyeWideLeft = faceAnchor.blendShapes[.eyeWideLeft]
        */
        
        //self.faceLogger.debug("Eye Blink left : \(eyeBlinkLeft)")
        
        
        /*
        //Creates Vision Image Request Handler using the current frame and performs an MLRequest.
         try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .left, options: [:]).perform([VNCoreMLRequest(model: model) { [weak self] request, error in
         //Here we get the first result of the Classification Observation result.
         guard let firstResult = (request.results as? [VNClassificationObservation])?.first else { return }
         DispatchQueue.main.async {
         //                print("identifier: \(topResult.identifier), confidence: \(topResult.confidence)")
         //Check if the confidence is high enough - used an arbitrary value here - and update the text to display the resulted emotion.
         
         if firstResult.confidence > 0.90 {
         (self?.textNode?.geometry as? SCNText)?.string = firstResult.identifier
         
         }
         }
         }])
         */
    }
}
