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
    @State var oldRotation: SCNVector3 = SCNVector3()
    @State var rotating = false
    var rotationMode: ARRotationMode
    var textHelperShown: Bool
    @Binding var reset: Bool
    typealias V3 = SCNVector3
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        guard let scene = SCNScene(named: "ductwork.scn", inDirectory: "main.scnassets")
        else { fatalError("Derp") }
        arView.session = ARSession()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        let geometryNode = self.aL.duct.getQuadGeometry(
            self.aL.offsetX.original,
            self.aL.offsetY.original,
            options: textHelperShown ? [.isAR, .sideTextShown] : [.isAR],
            tabs: Tabs())
        geometryNode.name = "duct"
        geometryNode.position = ductPosition
        
        let rotCylX = SCNCylinder(radius: 0.0254 / 32, height: 10)
        rotCylX.radialSegmentCount = 3
        rotCylX.firstMaterial?.fillMode = .lines
        rotCylX.firstMaterial?.diffuse.contents = UIColor.red
        let rotCylY = SCNCylinder(radius: 0.0254 / 32, height: 10)
        rotCylY.radialSegmentCount = 3
        rotCylY.firstMaterial?.fillMode = .lines
        rotCylY.firstMaterial?.diffuse.contents = UIColor.red
        let rotCylZ = SCNCylinder(radius: 0.0254 / 32, height: 10)
        rotCylZ.radialSegmentCount = 3
        rotCylZ.firstMaterial?.fillMode = .lines
        rotCylZ.firstMaterial?.diffuse.contents = UIColor.red
        
        switch rotationMode {
            case .x: rotCylX.firstMaterial?.diffuse.contents = UIColor.green
            case .y: rotCylY.firstMaterial?.diffuse.contents = UIColor.green
            case .z: rotCylZ.firstMaterial?.diffuse.contents = UIColor.green
        }
        
        let rotCylXNode = SCNNode(geometry: rotCylX)
        let rotCylYNode = SCNNode(geometry: rotCylY)
        let rotCylZNode = SCNNode(geometry: rotCylZ)
        
        rotCylXNode.eulerAngles = V3(x: 0, y: 0, z: Math.degToRad(degrees: 90))
        rotCylZNode.eulerAngles = V3(x: Math.degToRad(degrees: 90), y: 0, z: 0)
        rotCylXNode.name = "rotcylx"
        rotCylYNode.name = "rotcyly"
        rotCylZNode.name = "rotcylz"
        
        scene.rootNode.addChildNode(rotCylXNode)
        scene.rootNode.addChildNode(rotCylYNode)
        scene.rootNode.addChildNode(rotCylZNode)
        scene.rootNode.addChildNode(geometryNode)
        
        arView.scene = scene
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        let oldDuct = uiView.scene.rootNode.childNode(withName: "duct", recursively: false)!
        oldDuct.removeFromParentNode()
        uiView.scene.rootNode.childNode(withName: "rotcylx", recursively: false)?.removeFromParentNode()
        uiView.scene.rootNode.childNode(withName: "rotcyly", recursively: false)?.removeFromParentNode()
        uiView.scene.rootNode.childNode(withName: "rotcylz", recursively: false)?.removeFromParentNode()
        if self.reset {
            uiView.session = ARSession()
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = []
            uiView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
        
        let rotCylX = SCNCylinder(radius: 0.0254 / 32, height: 10)
        rotCylX.radialSegmentCount = 3
        rotCylX.firstMaterial?.fillMode = .lines
        rotCylX.firstMaterial?.diffuse.contents = UIColor.red
        let rotCylY = SCNCylinder(radius: 0.0254 / 32, height: 10)
        rotCylY.radialSegmentCount = 3
        rotCylY.firstMaterial?.fillMode = .lines
        rotCylY.firstMaterial?.diffuse.contents = UIColor.red
        let rotCylZ = SCNCylinder(radius: 0.0254 / 32, height: 10)
        rotCylZ.radialSegmentCount = 3
        rotCylZ.firstMaterial?.fillMode = .lines
        rotCylZ.firstMaterial?.diffuse.contents = UIColor.red
        
        switch rotationMode {
            case .x: rotCylX.firstMaterial?.diffuse.contents = UIColor.green
            case .y: rotCylY.firstMaterial?.diffuse.contents = UIColor.green
            case .z: rotCylZ.firstMaterial?.diffuse.contents = UIColor.green
        }
        
        let rotCylXNode = SCNNode(geometry: rotCylX)
        let rotCylYNode = SCNNode(geometry: rotCylY)
        let rotCylZNode = SCNNode(geometry: rotCylZ)
        
        
        rotCylXNode.position = ductPosition
        rotCylYNode.position = ductPosition
        rotCylZNode.position = ductPosition
        
        let geometryNode = self.aL.duct.getQuadGeometry(
            self.aL.offsetX.original,
            self.aL.offsetY.original,
            options: textHelperShown ? [.isAR, .sideTextShown] : [.isAR],
            tabs: Tabs())
        geometryNode.name = "duct"
        geometryNode.position = self.ductPosition
        if !reset {
            geometryNode.simdOrientation = oldDuct.simdOrientation
        } else {
            reset = false
        }
        
        switch rotationMode {
            case .x: geometryNode.simdRotate(by: simd_quatf(angle: ductRotation.x, axis: simd_normalize(SIMD3(geometryNode.worldRight))), aroundTarget: simd_float3(ductPosition))
            case .y: geometryNode.simdRotate(by: simd_quatf(angle: ductRotation.y, axis: simd_normalize(SIMD3(geometryNode.worldUp))), aroundTarget: simd_float3(ductPosition))
            case .z: geometryNode.simdRotate(by: simd_quatf(angle: ductRotation.z, axis: simd_normalize(SIMD3(geometryNode.worldFront))), aroundTarget: simd_float3(ductPosition))
        }
        print(geometryNode.worldUp)
        rotCylXNode.eulerAngles = V3(x: 0, y: 0, z: Math.degToRad(degrees: 90))
        rotCylZNode.eulerAngles = V3(x: Math.degToRad(degrees: 90), y: 0, z: 0)
        rotCylYNode.eulerAngles = V3(x: 0, y: 0, z: 0)
        rotCylXNode.simdRotate(by: geometryNode.simdOrientation, aroundTarget: simd_float3(ductPosition))
        rotCylYNode.simdRotate(by: geometryNode.simdOrientation, aroundTarget: simd_float3(ductPosition))
        rotCylZNode.simdRotate(by: geometryNode.simdOrientation, aroundTarget: simd_float3(ductPosition))
        rotCylXNode.name = "rotcylx"
        rotCylYNode.name = "rotcyly"
        rotCylZNode.name = "rotcylz"

        uiView.scene.rootNode.addChildNode(rotCylXNode)
        uiView.scene.rootNode.addChildNode(rotCylZNode)
        uiView.scene.rootNode.addChildNode(rotCylYNode)
        uiView.scene.rootNode.addChildNode(geometryNode)
    }
    
}

//struct ARViewContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        ARViewContainer(
//            ductPosition: Binding.constant(SCNVector3(x: 0.0, y: 0.0, z: 0.0)),
//            ductRotation: Binding.constant(SCNVector3(0, 0, 0)),
//            rotationMode: .x,
//            textHelperShown: true,
//            reset: Binding.constant(false)
//        ).environmentObject(AppLogic())
//    }
//}
