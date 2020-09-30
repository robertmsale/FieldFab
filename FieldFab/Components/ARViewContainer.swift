//
//  ARViewContainer.swift
//  FieldFab
//
//  Created by Robert Sale on 9/27/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import UIKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var aL: AppLogic
    @Binding var ductPosition: SCNVector3
    @Binding var ductRotation: SCNVector3
    @Binding var reset: Bool
    typealias V3 = SCNVector3
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        let scene = SCNScene()
        arView.session = ARSession()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        let geometry = self.aL.duct.getQuadGeometry(self.aL.offsetX.original, self.aL.offsetY.original, true)
        geometry.firstMaterial?.diffuse.contents = UIImage(named: "sheetmetal")
        geometry.firstMaterial?.normal.contents = UIImage(named: "sheetmetal-normal")
        geometry.firstMaterial?.lightingModel = .physicallyBased
        geometry.firstMaterial?.roughness.contents = 1.0
        
        let node = SCNNode(geometry: geometry)
        node.name = "duct"
        node.position = self.ductPosition
        node.eulerAngles = self.ductRotation
        
        scene.rootNode.addChildNode(node)
        
        arView.scene = scene
        
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        uiView.scene.rootNode.childNode(withName: "duct", recursively: false)?.removeFromParentNode()
        if self.reset {
            uiView.session = ARSession()
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            uiView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            self.reset = false
        }
        
        let geometry = self.aL.duct.getQuadGeometry(self.aL.offsetX.original, self.aL.offsetY.original, true)
        geometry.firstMaterial?.diffuse.contents = UIImage(named: "sheetmetal")
        geometry.firstMaterial?.normal.contents = UIImage(named: "sheetmetal-normal")
        geometry.firstMaterial?.lightingModel = .physicallyBased
        geometry.firstMaterial?.roughness.contents = 1.0

        let node = SCNNode(geometry: geometry)
        node.name = "duct"
        node.position = self.ductPosition
//        node.localRotate(by: SCNQuaternion(0, 0, 1, MathUtils.degToRad(degrees: 90)))
        node.eulerAngles = self.ductRotation

        uiView.scene.rootNode.addChildNode(node)
    }
    
}

struct ARViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        ARViewContainer(
            ductPosition: Binding.constant(SCNVector3(x: 0.0, y: 0.0, z: 0.0)),
            ductRotation: Binding.constant(SCNVector3(0, 0, 0)),
            reset: Binding.constant(false)
        ).environmentObject(AppLogic())
    }
}
