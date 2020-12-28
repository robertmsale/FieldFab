//
//  DuctSceneProtocol.swift
//  FieldFab
//
//  Created by Robert Sale on 12/25/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import Foundation
import SceneKit
import VectorExtensions
import ARKit
import SwiftUI

protocol DuctSceneProtocol: UIViewRepresentable {
    var duct: Duct { get set }
    var maxXZ: Float? { get }
}

extension DuctSceneProtocol {
    var tabNodeNames: [String] {
        ["tab-front-left", "tab-front-right", "tab-front-top", "tab-front-bottom", "tab-left-left", "tab-left-right", "tab-left-top", "tab-left-bottom", "tab-right-left", "tab-right-right", "tab-right-top", "tab-right-bottom", "tab-back-left", "tab-back-right", "tab-back-top", "tab-back-bottom"]
    }
    var ductNodeNames: [String] {
        ["Front", "Back", "Left", "Right"]
    }
    func setMaterial(_ view: SCNView, to: String, nodes: [String] = [], lightingModel: LightingModel = .physicallyBased, progress: inout Double) {
        let pDelta = 0.01
        var nodeNames = Set<String>(nodes)
        if nodes.count == 0 {
            for i in DuctData.Face.allCases.map({$0.rawValue}) { nodeNames.insert(i) }
            for i in DuctTab.FaceTab.allCases.map({$0.tabNodeName}) { nodeNames.insert(i) }
        }
        progress += pDelta
        let nodes = view.scene?.rootNode.childNodes(passingTest: { (n, _) in nodeNames.contains(n.name ?? "Fail Purposefully") }) ?? []
        for i in nodes {
            progress += pDelta
            i.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "\(to)-diffuse")
            i.geometry?.firstMaterial?.metalness.contents = UIImage(named: "\(to)-metallic")
            i.geometry?.firstMaterial?.normal.contents = UIImage(named: "\(to)-normal")
            i.geometry?.firstMaterial?.roughness.contents = UIImage(named: "\(to)-roughness")
            i.geometry?.firstMaterial?.lightingModel = lightingModel.scn
        }
    }
    func setHelpers(_ view: SCNView, _ on: Bool, progress: inout Double) {
        progress += 0.01
        if on {
            view.scene?.rootNode.childNode(withName: "Front", recursively: true)?.geometry?.firstMaterial?.emission.contents = UIColor(red: 0, green: 0.25, blue: 0, alpha: 0.2)
            view.scene?.rootNode.childNode(withName: "Back", recursively: true)?.geometry?.firstMaterial?.emission.contents =  UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.2)
            view.scene?.rootNode.childNode(withName: "Left", recursively: true)?.geometry?.firstMaterial?.emission.contents =  UIColor(red: 0.25, green: 0.25, blue: 0, alpha: 0.2)
            view.scene?.rootNode.childNode(withName: "Right", recursively: true)?.geometry?.firstMaterial?.emission.contents = UIColor(red: 0, green: 0, blue: 0.25, alpha: 0.2)
        } else {
            view.scene?.rootNode.childNode(withName: "Front", recursively: true)?.geometry?.firstMaterial?.emission.contents = nil
            view.scene?.rootNode.childNode(withName: "Back", recursively: true)?.geometry?.firstMaterial?.emission.contents =  nil
            view.scene?.rootNode.childNode(withName: "Left", recursively: true)?.geometry?.firstMaterial?.emission.contents =  nil
            view.scene?.rootNode.childNode(withName: "Right", recursively: true)?.geometry?.firstMaterial?.emission.contents = nil
        }
    }
    func generate3DScene(bgColor: CGColor, bgImage: String? = nil, progress: inout Double) -> SCNScene {
        let scene = SCNScene(named: "ductwork.scn", inDirectory: "main.scnassets") ?? SCNScene()
        let pDelta = 0.01
        progress += pDelta
        let ductNode = SCNNode()
        progress += pDelta
        ductNode.name = "Duct Node"
        for (_, v) in duct.getNodes() {
            ductNode.addChildNode(v)
            progress += pDelta
        }
        progress += pDelta
        let camera = SCNCamera()
        camera.fieldOfView = 90
        camera.zFar = 100
        camera.zNear = 0.0001
        progress += pDelta
        let camNode = SCNNode()
        camNode.worldPosition = SCNVector3(0, 0, (maxXZ ?? 1) * 2)
        camNode.camera = camera
        progress += pDelta
        scene.rootNode.addChildNode(ductNode)
        progress += pDelta
        scene.rootNode.addChildNode(camNode)
        func setBG(_ v: Any?) { scene.background.contents = v; scene.lightingEnvironment.contents = v }
        if let img = bgImage { setBG(UIImage(named: img)) }
        else { setBG(bgColor) }
        progress += pDelta
        return scene
    }
    func setScene(view: SCNView, scene: SCNScene? = nil, debugInfo: Bool = false, progress: inout Double) {
        let pDelta = 0.01
        view.rendersContinuously = false
        progress += pDelta
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        progress += pDelta
        view.showsStatistics = debugInfo
        view.scene = scene ?? generate3DScene(bgColor: CGColor(red: 0, green: 0, blue: 1, alpha: 1), bgImage: nil, progress: &progress)
        progress += pDelta
    }
    func setARScene(view: ARSCNView, progress: inout Double) {
        let pDelta = 0.01
        let scene = SCNScene()
        view.session = ARSession()
        progress += pDelta
        view.automaticallyUpdatesLighting = true
        view.session.configuration?.isLightEstimationEnabled = true
        progress += pDelta
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        configuration.environmentTexturing = .automatic
        progress += pDelta
        view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        progress += pDelta
        let ductNode = SCNNode()
        ductNode.name = "Duct Node"
        for (_, v) in duct.getNodes() {
            ductNode.addChildNode(v)
            progress += pDelta
        }
        progress += pDelta
        scene.rootNode.addChildNode(ductNode)
        view.scene = scene
        progress += pDelta
    }
}
