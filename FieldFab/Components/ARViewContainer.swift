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
    @EnvironmentObject var al: AppLogic
    @State var oldRotation: SCNVector3 = SCNVector3()
    @State var rotating = false
    //    var rotationMode: ARRotationMode
    //    var textHelperShown: Bool
    typealias V3 = SCNVector3

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        guard let scene = SCNScene(named: "ductwork.scn", inDirectory: "main.scnassets")
        else { fatalError("Derp") }
        arView.session = ARSession()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        let geometryNode = al.duct.getQuadGeometry(
            al.offsetX.original,
            al.offsetY.original,
            options: al.arViewHelpersShown ? [.isAR, .sideTextShown] : [.isAR],
            tabs: TabsData())
        for v in geometryNode {
            v.position = al.arDuctPosition
            scene.rootNode.addChildNode(v)
            v.eulerAngles = al.arViewFlowDirection.getVector()
        }

        arView.scene = scene

        return arView

    }

    func applyTransforms(_ nodes: [SCNNode]) {
        for n in nodes {
            n.position = al.arDuctPosition
            n.eulerAngles = al.arViewFlowDirection.getVector()
            n.simdRotate(
                by: simd_quatf(
                    angle: al.arDuctRotation,
                    axis: simd_normalize(SIMD3(0, 1, 0))),
                aroundTarget: SIMD3(al.arDuctPosition))
        }
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if al.arViewReset {
            uiView.session = ARSession()
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = []
            uiView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            al.arViewReset = false
        }
        let duct = uiView.scene.rootNode.childNode(withName: "duct", recursively: false)
        let hfront = uiView.scene.rootNode.childNode(withName: "h-front", recursively: false)
        let hback = uiView.scene.rootNode.childNode(withName: "h-back", recursively: false)
        let hleft = uiView.scene.rootNode.childNode(withName: "h-left", recursively: false)
        let hright = uiView.scene.rootNode.childNode(withName: "h-right", recursively: false)
        if al.arMeasurementsDidChange {
            duct?.removeFromParentNode()
            hfront?.removeFromParentNode()
            hback?.removeFromParentNode()
            hleft?.removeFromParentNode()
            hright?.removeFromParentNode()

            let geometryNode = al.duct.getQuadGeometry(
                al.offsetX.original,
                al.offsetY.original,
                options: al.arViewHelpersShown ? [.isAR, .sideTextShown] : [.isAR],
                tabs: TabsData())

            for v in geometryNode {
                v.position = al.arDuctPosition
                v.eulerAngles = al.arViewFlowDirection.getVector()
                v.simdRotate(
                    by: simd_quatf(
                        angle: al.arDuctRotation,
                        axis: simd_normalize(SIMD3(0, 1, 0))),
                    aroundTarget: SIMD3(geometryNode[0].position)
                )
            }
            for v in geometryNode { uiView.scene.rootNode.addChildNode(v) }
            al.arMeasurementsDidChange = false
        } else {
            applyTransforms([duct!, hfront!, hback!, hleft!, hright!])
            hfront?.geometry?.firstMaterial?.transparent.contents = al.arViewHelpersShown ? UIImage(named: "F") : UIColor.white
            hback?.geometry?.firstMaterial?.transparent.contents = al.arViewHelpersShown ? UIImage(named: "B") : UIColor.white
            hleft?.geometry?.firstMaterial?.transparent.contents = al.arViewHelpersShown ? UIImage(named: "L") : UIColor.white
            hright?.geometry?.firstMaterial?.transparent.contents = al.arViewHelpersShown ? UIImage(named: "R") : UIColor.white
        }
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
