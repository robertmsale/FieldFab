//
//  DuctSCN.swift
//  FieldFab
//
//  Created by Robert Sale on 12/25/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit
import ARKit
import VectorExtensions
import VectorProtocol

struct DuctSCN: UIViewRepresentable {
    typealias UIViewType = SCNView
    @EnvironmentObject var state: AppState
    @State var cameraRollTime: Date = Date()
    let q = DispatchQueue.global(qos: .userInteractive)
    let s = DispatchSemaphore(value: 1)
    
    func ductNode(_ scene: SCNScene?) -> SCNNode {
        return scene?.rootNode.childNode(withName: "Duct Node", recursively: false) ?? SCNNode()
    }
    func allDuctNodes(_ scene: SCNScene?) -> [SCNNode] {
        let nameSet = Set(Duct.allNodeNames)
        return ductNode(scene).childNodes(passingTest: {(n, _) in nameSet.contains(n.name ?? "Fail Miserably")})
    }
    func allTabNodes(_ scene: SCNScene?) -> [SCNNode] {
        let nameSet = Set(Duct.tabNodeNames)
        return ductNode(scene).childNodes(passingTest: {(n, _) in nameSet.contains(n.name ?? "Fail Miserably")})
    }
    func allFaceNodes(_ scene: SCNScene?) -> [SCNNode] {
        let nameSet = Set(Duct.ductNodeNames)
        return ductNode(scene).childNodes(passingTest: {(n, _) in nameSet.contains(n.name ?? "Fail Miserably")})
    }

    func energyUpdate(_ view: UIViewType) {
        if !state.energySaver {
            view.antialiasingMode = .multisampling2X
        }
        view.rendersContinuously = !state.energySaver
//        state.events.scene.energySaverChanged = false
    }
    func bgTextureUpdate(_ view: UIViewType, _ scene: SCNScene?) {
        if let t = state.sceneBGTexture {
            let img = UIImage(named: t)
            scene?.background.contents = img
            scene?.lightingEnvironment.contents = img
        } else {
            scene?.background.contents = state.sceneBGColor
            scene?.lightingEnvironment.contents = state.sceneBGColor
        }
//        state.events.scene.bgChanged = false
    }
    func materialUpdate(_ scene: SCNScene?) {
        for node in allDuctNodes(scene) {
            node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "\(state.material)-diffuse")
            node.geometry?.firstMaterial?.metalness.contents = UIImage(named: "\(state.material)-metallic")
            node.geometry?.firstMaterial?.normal.contents = UIImage(named: "\(state.material)-normal")
            node.geometry?.firstMaterial?.roughness.contents = UIImage(named: "\(state.material)-roughness")
            node.geometry?.firstMaterial?.lightingModel = state.lightingModel.scn
        }
//        state.events.scene.textureChanged = false
    }
    func geometryUpdateAll(_ scene: SCNScene?) {
        ductNode(scene).removeFromParentNode()
        let dNode = SCNNode()
        dNode.name = "Duct Node"
        dNode.addChildNode(state.currentWork?.geometry.front.toNode(name: "Front") ?? SCNNode())
        dNode.addChildNode(state.currentWork?.geometry.back.toNode(name: "Back") ?? SCNNode())
        dNode.addChildNode(state.currentWork?.geometry.left.toNode(name: "Left") ?? SCNNode())
        dNode.addChildNode(state.currentWork?.geometry.right.toNode(name: "Right") ?? SCNNode())
        for tab in DuctTab.FaceTab.allCases {
            if let node = state.currentWork?.geometry.tabs[tab]?.toNode(name: tab.tabNodeName) {
                dNode.addChildNode(node)
            }
        }
        scene?.rootNode.addChildNode(dNode)
//        state.events.scene.measurementsChanged = false
    }
    func tabsUpdate(_ scene: SCNScene?) {
        for i in allTabNodes(scene) { i.removeFromParentNode() }
        let dNode = ductNode(scene)
        for tab in DuctTab.FaceTab.allCases {
            if let node = state.currentWork?.geometry.tabs[tab]?.toNode(name: tab.tabNodeName) {
                dNode.addChildNode(node)
            }
        }
//        state.events.scene.tabsChanged = false
    }
    func helpersUpdate(_ scene: SCNScene?) {
        let i = CGFloat(0.25)
        let f = UIColor(red: 0, green: i, blue: 0, alpha: i)
        let b = UIColor(red: i, green: 0, blue: 0, alpha: i)
        let l = UIColor(red: i, green: i, blue: 0, alpha: i)
        let r = UIColor(red: 0, green: 0, blue: i, alpha: i)
        let c = state.showHelpers
        for x in allFaceNodes(scene) {
            switch x.name {
                case "Front": x.geometry?.firstMaterial?.emission.contents = c ? f : NSNumber(0)
                case "Back":  x.geometry?.firstMaterial?.emission.contents = c ? b : NSNumber(0)
                case "Left":  x.geometry?.firstMaterial?.emission.contents = c ? l : NSNumber(0)
                case "Right": x.geometry?.firstMaterial?.emission.contents = c ? r : NSNumber(0)
                default: break
            }
        }
//        state.events.scene.helpersChanged = false
    }
    func moveCamera(_ view: UIViewType) {
        if let cam = view.scene?.rootNode.childNode(withName: "Camera", recursively: false) {
            let maxXZ: Float = max(
                max(state.currentWork?.data.width.rendered3D ?? 0, state.currentWork?.data.twidth.rendered3D ?? 0),
                max(state.currentWork?.data.depth.rendered3D ?? 0, state.currentWork?.data.tdepth.rendered3D ?? 0)
            )
            switch state.work3DMeasurementSelected {
                case .width, .twidth, .length, .offsetx: cam.worldPosition = SCNVector3(0, 0, maxXZ * 4)
                default: cam.worldPosition = SCNVector3(maxXZ * 4, 0, 0)
            }
            cam.look(at: SCNVector3(0, 0, 0))
            view.pointOfView = cam
        }
//        state.events.scene.drawerChanged = false
    }
    
    func makeUIView(context: Context) -> SCNView {
        let scene = SCNScene()
        let view = SCNView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        view.autoenablesDefaultLighting = true
        view.allowsCameraControl = true
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true
//        SCNCameraController()
//        camera.wantsHDR = true
        let camNode = SCNNode()
        camNode.name = "Camera"
        camNode.camera = camera
//        let maxXZ = max(state.currentWork?.data.width.rendered3D ?? 0, state.currentWork?.data.depth.rendered3D ?? 0)
        view.pointOfView = camNode
        energyUpdate(view)
        bgTextureUpdate(view, scene)
        geometryUpdateAll(scene)
        materialUpdate(scene)
        helpersUpdate(scene)
//        let panG = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.panCam(g:)))
//        let zoomG = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.zoomCam(g:)))
        let pressG = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.hit(g:)))
        
//        view.addGestureRecognizer(panG)
//        view.addGestureRecognizer(zoomG)
        view.addGestureRecognizer(pressG)
        scene.rootNode.addChildNode(camNode)
        view.scene = scene
        moveCamera(view)
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if state.sceneEvents.bgChanged { bgTextureUpdate(uiView, uiView.scene) }
        if state.sceneEvents.energySaverChanged { energyUpdate(uiView) }
        if state.sceneEvents.measurementsChanged {
            geometryUpdateAll(uiView.scene)
            materialUpdate(uiView.scene)
            moveCamera(uiView)
            helpersUpdate(uiView.scene)
        }
        else if state.sceneEvents.tabsChanged {
            tabsUpdate(uiView.scene)
            materialUpdate(uiView.scene)
        }
        if state.sceneEvents.textureChanged { materialUpdate(uiView.scene) }
        if state.sceneEvents.helpersChanged { helpersUpdate(uiView.scene) }
        if state.sceneEvents.drawerChanged { moveCamera(uiView) }
        if state.workViewTab == 1 {
            materialUpdate(uiView.scene)
        }
        if state.sceneEvents.needsReset {
            Task {
                state.sceneEvents = EventState.Scene()
            }
        }
        if state.currentWorkTab == 1 && !uiView.isPlaying { uiView.play(nil) }
        if state.currentWorkTab != 1 && uiView.isPlaying { uiView.pause(nil) }
        uiView.showsStatistics = state.showDebugInfo
    }
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator({
            state.ductSceneHitTest = $0
        })
    }
    
    class Coordinator {
//        let changePosition: (CGPoint) -> Void
        var initialPan: CGPoint = CGPoint()
        var scale: CGFloat = 1.0
        var hitTest: (String?) -> Void
        
        init(_ hitTest: @escaping (String?) -> Void) {
            self.hitTest = hitTest
        }
        
        @objc func hit(g: UILongPressGestureRecognizer) {
            guard let v = (g.view as? SCNView) else { return }
            let res = v.hitTest(g.location(in: v))
            if res.count > 0 {
                hitTest(res[0].node.name)
            }
        }
        
        @objc func zoomCam(g: UIPinchGestureRecognizer) {
            guard g.view != nil else {return}
            let v = (g.view! as! SCNView)
            
            if g.state == .began {
                g.scale = self.scale
            }
            if g.state == .changed {
                let camNode = v.scene?.rootNode.childNode(withName: "Camera", recursively: false) ?? SCNNode()
                camNode.position.multiplyScalar(g.scale < self.scale ? 0.95 : 1.05)
            }
        }
        
        @objc func panCam(g: UIPanGestureRecognizer) {
            guard g.view != nil else {return}
            let v = (g.view! as! SCNView)
            
            let translation = g.translation(in: v)
            if g.state == .began {
                self.initialPan = translation
            }
            if g.state != .cancelled {
                let rotSpeed: Float = 0.001
                let dx = (self.initialPan.y - translation.y).f * rotSpeed
                let dy = (self.initialPan.x - translation.x).f * rotSpeed
                let camNode = v.scene?.rootNode.childNode(withName: "Camera", recursively: false)
                let camPos = camNode?.worldPosition ?? SCNVector3()
                let camPosSph = Spherical(from: camPos)
                var camPosSphEnd = camPosSph
                camPosSphEnd.phi += dx
                camPosSphEnd.theta += dy
                var posEnd = SCNVector3()
                posEnd.set(spherical: camPosSphEnd)
                camNode?.worldPosition = posEnd
                camNode?.worldOrientation = v.scene!.rootNode.worldOrientation
                camNode?.look(at: SCNVector3(0,0,0))
//                print(camNode?.worldUp)
            }
        }
    }
}

struct DuctAR: UIViewRepresentable {
    typealias UIViewType = ARSCNView
    @EnvironmentObject var state: AppState
    
    func ductNode(_ scene: SCNScene?) -> SCNNode {
        return scene?.rootNode.childNode(withName: "Duct Node", recursively: false) ?? SCNNode()
    }
    func allDuctNodes(_ scene: SCNScene?) -> [SCNNode] {
        let nameSet = Set(Duct.allNodeNames)
        return ductNode(scene).childNodes(passingTest: {(n, _) in nameSet.contains(n.name ?? "Fail Miserably")})
    }
    func allTabNodes(_ scene: SCNScene?) -> [SCNNode] {
        let nameSet = Set(Duct.tabNodeNames)
        return ductNode(scene).childNodes(passingTest: {(n, _) in nameSet.contains(n.name ?? "Fail Miserably")})
    }
    func allFaceNodes(_ scene: SCNScene?) -> [SCNNode] {
        let nameSet = Set(Duct.ductNodeNames)
        return ductNode(scene).childNodes(passingTest: {(n, _) in nameSet.contains(n.name ?? "Fail Miserably")})
    }
    
    func energyUpdate(_ view: ARSCNView) {
        if !state.energySaver {
            view.antialiasingMode = .multisampling2X
        }
        view.rendersContinuously = !state.energySaver
//        state.events.ar.energySaverChanged = false
    }
    func materialUpdate(_ scene: SCNScene?) {
        for node in allDuctNodes(scene) {
            node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "\(state.material)-diffuse")
            node.geometry?.firstMaterial?.metalness.contents = UIImage(named: "\(state.material)-metallic")
            node.geometry?.firstMaterial?.normal.contents = UIImage(named: "\(state.material)-normal")
            node.geometry?.firstMaterial?.roughness.contents = UIImage(named: "\(state.material)-roughness")
            node.geometry?.firstMaterial?.lightingModel = state.lightingModel.scn
        }
//        state.events.ar.textureChanged = false
    }
    func geometryUpdateAll(_ scene: SCNScene?) {
        ductNode(scene).removeFromParentNode()
        let dNode = SCNNode()
        dNode.name = "Duct Node"
        dNode.addChildNode(state.currentWork?.geometry.front.toNode(name: "Front") ?? SCNNode())
        dNode.addChildNode(state.currentWork?.geometry.back.toNode(name: "Back") ?? SCNNode())
        dNode.addChildNode(state.currentWork?.geometry.left.toNode(name: "Left") ?? SCNNode())
        dNode.addChildNode(state.currentWork?.geometry.right.toNode(name: "Right") ?? SCNNode())
        for tab in DuctTab.FaceTab.allCases {
            if let node = state.currentWork?.geometry.tabs[tab]?.toNode(name: tab.tabNodeName) {
                dNode.addChildNode(node)
            }
        }
        scene?.rootNode.addChildNode(dNode)
//        state.events.ar.measurementsChanged = false
    }
    func tabsUpdate(_ scene: SCNScene?) {
        for i in allTabNodes(scene) { i.removeFromParentNode() }
        let dNode = ductNode(scene)
        for tab in DuctTab.FaceTab.allCases {
            if let node = state.currentWork?.geometry.tabs[tab]?.toNode(name: tab.tabNodeName) {
                dNode.addChildNode(node)
            }
        }
//        state.events.ar.tabsChanged = false
    }
    func helpersUpdate(_ scene: SCNScene?) {
        let i = CGFloat(0.25)
        let f = UIColor(red: 0, green: i, blue: 0, alpha: i)
        let b = UIColor(red: i, green: 0, blue: 0, alpha: i)
        let l = UIColor(red: i, green: i, blue: 0, alpha: i)
        let r = UIColor(red: 0, green: 0, blue: i, alpha: i)
        
        let c = state.showHelpers
        for x in allFaceNodes(scene) {
            switch x.name {
                case "Front": x.geometry?.firstMaterial?.emission.contents = c ? f : NSNumber(0)
                case "Back":  x.geometry?.firstMaterial?.emission.contents = c ? b : NSNumber(0)
                case "Left":  x.geometry?.firstMaterial?.emission.contents = c ? l : NSNumber(0)
                case "Right": x.geometry?.firstMaterial?.emission.contents = c ? r : NSNumber(0)
                default: break
            }
        }
//        state.events.ar.helpersChanged = false
    }
    
    func changeFlow(_ scene: SCNScene?, context: Context) {
        if state.flowDirection != context.coordinator.currentFlow {
            for n in allDuctNodes(scene) {
                switch state.flowDirection {
                    case .up: n.eulerAngles = SCNVector3(0, 0, 0)
                    case .down: n.eulerAngles = SCNVector3(0, 0,   180.0.rad)
                    case .left: n.eulerAngles = SCNVector3(0, 0,    90.0.rad)
                    case .right: n.eulerAngles = SCNVector3(0, 0,  -90.0.rad)
                }
            }
            context.coordinator.currentFlow = state.flowDirection
        }
    }
    
    func makeUIView(context: Context) -> ARSCNView {
        let view = ARSCNView(frame: CGRect.zero)
        let scene = SCNScene()
        view.session = ARSession()
        view.automaticallyUpdatesLighting = true
        view.session.configuration?.isLightEstimationEnabled = true
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        configuration.environmentTexturing = .automatic
        view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        let hitG = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.hit(g:)))
        let rotG = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.rotate(g:)))
        let panG = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.panCam(g:)))
        view.addGestureRecognizer(hitG)
        view.addGestureRecognizer(panG)
        view.addGestureRecognizer(rotG)
        energyUpdate(view)
        geometryUpdateAll(scene)
        materialUpdate(scene)
        helpersUpdate(scene)
        changeFlow(scene, context: context)
        view.scene = scene
        return view
    }
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        configuration.environmentTexturing = .automatic
        if state.arEvents.energySaverChanged {
            energyUpdate(uiView)
        }
        if state.arEvents.measurementsChanged {
            geometryUpdateAll(uiView.scene)
            materialUpdate(uiView.scene)
            helpersUpdate(uiView.scene)
            let node = ductNode(uiView.scene)
            node.worldPosition = context.coordinator.ductPosition
            node.eulerAngles = context.coordinator.ductEuler
        }
        if state.arEvents.textureChanged {
            materialUpdate(uiView.scene)
        }
        if state.arEvents.tabsChanged {
            tabsUpdate(uiView.scene)
            materialUpdate(uiView.scene)
        }
        if state.arEvents.helpersChanged {
            helpersUpdate(uiView.scene)
        }
        if state.arEvents.arViewReset {
            uiView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors, .resetSceneReconstruction])
            context.coordinator.ductPosition = SCNVector3(0,0,0)
            context.coordinator.ductEuler = SCNVector3(0, 0, 0)
            let node = ductNode(uiView.scene)
            node.worldPosition = SCNVector3(0,0,0)
            node.eulerAngles = SCNVector3(0,0,0)
            materialUpdate(uiView.scene)
            helpersUpdate(uiView.scene)
            state.arEvents.arViewReset = false
        }
        changeFlow(uiView.scene, context: context)
        if state.currentWorkTab == 2 && !uiView.isPlaying {
            uiView.play(nil)
            uiView.session.run(configuration, options: [])
        }
        if state.currentWorkTab != 2 && uiView.isPlaying {
            uiView.pause(nil)
            uiView.session.pause()
        }
        if state.arEvents.needsReset {
            state.arEvents = EventState.ARScene()
        }
        uiView.showsStatistics = state.showDebugInfo
        context.coordinator.translationMode = state.translationMode
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator({
            state.ductSceneHitTest = $0
        }, state.translationMode, currentFlow: state.flowDirection)
    }
    
    class Coordinator {
        var ductPosition = SCNVector3(0, 0, 0)
        var ductRotation = CGFloat(0)
        var ductEuler = SCNVector3(0, 0, 0)
        var initialRotation = CGFloat(0)
        var initialPan = CGPoint.zero
        var translationMode: AppState.TranslationMode
        var hitTest: (String?) -> Void
        var currentFlow: AppState.FlowDirection
        
        init(_ hitTest: @escaping (String?) -> Void, _ translationM: AppState.TranslationMode, currentFlow: AppState.FlowDirection) {
            self.hitTest = hitTest
            self.translationMode = translationM
            self.currentFlow = currentFlow
        }
        
        @objc func hit(g: UILongPressGestureRecognizer) {
            guard let v = (g.view as? ARSCNView) else { return }
            let res = v.hitTest(g.location(in: v))
            if res.count > 0 {
                hitTest(res[0].node.name)
            }
        }
        
        @objc func rotate(g: UIRotationGestureRecognizer) {
            guard let v = (g.view as? ARSCNView) else {return}
            if g.state == .began {
                initialRotation = g.rotation
                
            }
            if g.state != .cancelled {
                let ductNode = v.scene.rootNode.childNode(withName: "Duct Node", recursively: false) ?? SCNNode()
                ductNode.eulerAngles.translate([.y: -(g.rotation - initialRotation).f * 0.01])
                ductEuler = ductNode.eulerAngles
            }
        }
        
        @objc func panCam(g: UIPanGestureRecognizer) {
            guard g.view != nil else {return}
            let v = (g.view! as! SCNView)
            
            let translation = g.translation(in: v)
            if g.state == .began {
                self.initialPan = translation
            }
            if g.state != .cancelled {
                let rotSpeed: Float = 0.0001
                let dy = -(self.initialPan.y - translation.y).f * rotSpeed
                let dx = -(self.initialPan.x - translation.x).f * rotSpeed
                switch translationMode {
                    case .xz: ductPosition.x += dx; ductPosition.z += dy
                    case .y: ductPosition.y -= dy
                }
                v.scene?.rootNode.childNode(withName: "Duct Node", recursively: false)?.worldPosition = self.ductPosition
            }
            
        }
    }
}
