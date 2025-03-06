//
//  DuctTransition3DView.swift
//  FieldFab
//
//  Created by Robert Sale on 1/1/23.
//  Copyright © 2023 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit
import UIKit
import ARKit
import SIMDExtensions

extension DuctTransition {
    class DuctSCNView: SCNView {
        var currentDuctwork: DuctTransition.DuctData? = nil
        var crossbrake: Bool = false
        var particlePhysicsEnabled: Bool = false
    }
    
    class DuctARSCNView: ARSCNView {
        var currentDuctwork: DuctTransition.DuctData? = nil
        var crossbrake: Bool = false
    }
    
    struct Duct3DView: View {
        var body: some View {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .enableInjection()
        }

        #if DEBUG
        @ObserveInjection var forceRedraw
        #endif
    }

    struct SceneView: UIViewRepresentable {
        typealias AppKey = DuctTransition.AppStorageKeys
        typealias V2 = SIMD2<Double>
        typealias V3 = SIMD3<Float>
        typealias UIViewType = DuctTransition.DuctSCNView
        var geo: GeometryProxy
        var textShown: Bool
        @EnvironmentObject var state: DuctTransition.ModuleState
        @AppStorage(AppKey.showDebugInfo) var showDebugInfo = false
        @AppStorage(AppKey.energySaver) var energySaver = false
        @AppStorage(AppKey.crossBrake) var crossBrake = true
        @AppStorage(AppKey.lighting) var lighting: LightingMethod = .physicallyBased
        @AppStorage(AppKey.texture) var texture: String = "galvanized"
        @AppStorage(AppKey.bgType) var bgType: BackgroundType = .image
        @AppStorage(AppKey.showHelpers) var showHelpers: Bool = false
        @AppStorage(AppKey.bgR) var bgR: Double = 0.0
        @AppStorage(AppKey.bgG) var bgG: Double = 0.0
        @AppStorage(AppKey.bgB) var bgB: Double = 1.0
        @AppStorage(AppKey.bgImage) var bgImage: BackgroundImage = .shop
        @AppStorage(AppKey.particlePhysicsEnabled) var particlePhysicsEnabled: Bool = true
        var ductwork: DuctTransition.DuctData
        var ductSceneHitTest: (String) -> Void
        @Binding var selectorShown: Bool
        @State var cameraRollTime: Date = Date()
        
        func ductNode(_ scene: SCNScene?) -> SCNNode {
            return scene?.rootNode.childNode(withName: "duct", recursively: false) ?? SCNNode()
        }
        func energyUpdate(_ view: UIViewType) {
            if !energySaver {
                view.antialiasingMode = .multisampling2X
            } else {
                view.antialiasingMode = .none
            }
            view.rendersContinuously = !energySaver
        }
        func bgTextureUpdate(_ view: UIViewType, _ scene: SCNScene?) {
            if bgType == .image {
                let img = UIImage(named: bgImage.rawValue)
                scene?.background.contents = img
                scene?.lightingEnvironment.contents = img
            } else {
                let color = UIColor(red: bgR, green: bgG, blue: bgB, alpha: 1.0)
                scene?.background.contents = color
                scene?.lightingEnvironment.contents = color
            }
        }
        func materialUpdate(_ scene: SCNScene?) {
            for node in ductNode(scene).childNodes {
                if node.name == "tnode" { continue }
                node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "\(texture)-diffuse")
                node.geometry?.firstMaterial?.metalness.contents = UIImage(named: "\(texture)-metallic")
                node.geometry?.firstMaterial?.normal.contents = UIImage(named: "\(texture)-normal")
                node.geometry?.firstMaterial?.roughness.contents = UIImage(named: "\(texture)-roughness")
                node.geometry?.firstMaterial?.lightingModel = lighting.scn
            }
        }
        
        func geometryUpdateAll(_ scene: SCNScene?) {
            ductNode(scene).removeFromParentNode()
            let dNode = SCNNode()
            dNode.name = "duct"
            let vdata = ductwork.vertexData
            for face in DuctTransition.Face.allCases {
                let faceNode = DuctTransition.FaceGeometry.generate(data: vdata, face: face, crossBrake: crossBrake)
                    .toNode(name: face.localizedString)
                dNode.addChildNode(faceNode)
                for edge in DuctTransition.TabEdge.allCases {
                    if let tab = ductwork.tabs[face, edge] {
                        let tabNode = DuctTransition.TabGeometry.generate(tab, face: face, edge: edge, verts: vdata.getTabPoints(face, edge))
                        dNode.addChildNode(tabNode)
                    }
                }
            }
            
            scene?.rootNode.childNode(withName: "air", recursively: false)?.removeFromParentNode()
            if particlePhysicsEnabled {
                let airParticles = SCNParticleSystem()
                let plane = SCNBox(width: vdata[.fbr].x.cg, height: 0.00000001, length: vdata[.fbr].z.cg, chamferRadius: 0.0000001)
                
                airParticles.emitterShape = plane
                
                airParticles.birthRate = 2000
                airParticles.birthRateVariation = 50
                airParticles.particleLifeSpan = 2.0
                
                airParticles.particleSize = 0.00002
                airParticles.particleSizeVariation = 0.01
                airParticles.particleColor = UIColor.white.withAlphaComponent(0.3)
                airParticles.particleColorVariation = SCNVector4(x: 0.1, y: 0.1, z: 0.1, w: 0.2)
                
                airParticles.speedFactor = 1.0
                airParticles.particleVelocity = 2.0
                airParticles.particleVelocityVariation = 0.5
                airParticles.spreadingAngle = calculateSpreadAngle(plane1: [vdata[.fbl], vdata[.fbr], vdata[.bbr], vdata[.bbl]].map {$0.asSCNV3}, plane2: [vdata[.ftl], vdata[.ftr], vdata[.btr], vdata[.btl]].map { $0.asSCNV3 }).cg.deg / 2
                airParticles.acceleration = SCNVector3(x: 0, y: 0.2, z: 0)
                
                airParticles.isAffectedByGravity = false
                airParticles.isAffectedByPhysicsFields = true
                airParticles.colliderNodes = dNode.childNodes
                airParticles.dampingFactor = 0.1
                airParticles.blendMode = .alpha
                
                let emitterNode = SCNNode()
                emitterNode.addParticleSystem(airParticles)
                emitterNode.name = "air"
                
                let avgBottom = [vdata[.fbl], vdata[.fbr], vdata[.bbl], vdata[.bbr]].reduce(simd_float3.zero) { (result, point) in
                    result + point
                } / 4.0
                
                emitterNode.position = (avgBottom * 1.1).asSCNV3
                
                let avgTop = [vdata[.ftl], vdata[.ftr], vdata[.btl], vdata[.btr]].reduce(simd_float3.zero) { (result, point) in
                    result + point
                } / 4.0
                
                let direction = avgTop - avgBottom
                
                airParticles.emittingDirection = direction.normalized.asSCNV3
                
                scene?.rootNode.addChildNode(emitterNode)
            }
            
            scene?.rootNode.addChildNode(dNode)
        }
        func helpersUpdate(_ scene: SCNScene?) {
            let i = CGFloat(0.25)
            let f = UIColor(red: 0, green: i, blue: 0, alpha: i)
            let b = UIColor(red: i, green: 0, blue: 0, alpha: i)
            let l = UIColor(red: i, green: i, blue: 0, alpha: i)
            let r = UIColor(red: 0, green: 0, blue: i, alpha: i)
            let c = showHelpers
            let faceNames = Set(DuctTransition.Face.allCases.map { $0.localizedString })
            for x in ductNode(scene).childNodes(passingTest: { node, _ in faceNames.contains(node.name ?? "") }) {
                switch x.name {
                case "Front": x.geometry?.firstMaterial?.emission.contents = c ? f : NSNumber(value: 0)
                case "Back":  x.geometry?.firstMaterial?.emission.contents = c ? b : NSNumber(value: 0)
                case "Left":  x.geometry?.firstMaterial?.emission.contents = c ? l : NSNumber(value: 0)
                case "Right": x.geometry?.firstMaterial?.emission.contents = c ? r : NSNumber(value: 0)
                    default: break
                }
            }
        }
        func moveCamera(_ view: UIViewType) {
            if let cam = view.scene?.rootNode.childNode(withName: "Camera", recursively: false) {
                let r = CGFloat(ductNode(view.scene!).boundingSphere.radius)
                guard let camera = cam.camera else { return }
                let fov = camera.fieldOfView
                let aspect = view.frame.width / view.frame.height
                let minAspect = min(CGFloat(1.0), aspect)
                let d: CGFloat = r / (CGFloat(0.8) * tan(fov / CGFloat(2.0) * CGFloat.pi / CGFloat(180)) * minAspect)
                
                cam.position = .init(0, 0, d)
                cam.look(at: SCNVector3(0, 0, 0))
                view.pointOfView = cam
            }
        }
        
        func makeUIView(context: Context) -> UIViewType {
            let scene = SCNScene()
            let view = UIViewType(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            view.autoenablesDefaultLighting = true
            view.allowsCameraControl = true
            let camera = SCNCamera()
            camera.automaticallyAdjustsZRange = true
            camera.wantsHDR = true
            let camNode = SCNNode()
            camNode.name = "Camera"
            camNode.camera = camera
            scene.rootNode.addChildNode(camNode)
            view.pointOfView = camNode
            energyUpdate(view)
            bgTextureUpdate(view, scene)
            geometryUpdateAll(scene)
            materialUpdate(scene)
            helpersUpdate(scene)
            view.crossbrake = crossBrake
            let pressG = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.hit(g:)))
            
            view.addGestureRecognizer(pressG)
            view.scene = scene
            moveCamera(view)
            view.currentDuctwork = ductwork
            #if DEBUG
            view.debugOptions = [SCNDebugOptions(rawValue: 2048)]
            #endif
            return view
        }
        
        func updateUIView(_ uiView: UIViewType, context: Context) {
            bgTextureUpdate(uiView, uiView.scene)
            energyUpdate(uiView)
            if ductwork != uiView.currentDuctwork || crossBrake != uiView.crossbrake || particlePhysicsEnabled != uiView.particlePhysicsEnabled {
                geometryUpdateAll(uiView.scene)
                if ductwork != uiView.currentDuctwork {moveCamera(uiView)}
                uiView.currentDuctwork = ductwork
                uiView.crossbrake = crossBrake
                uiView.particlePhysicsEnabled = particlePhysicsEnabled
            }
            materialUpdate(uiView.scene)
            helpersUpdate(uiView.scene)
            uiView.showsStatistics = showDebugInfo
        }
        
        
        func makeCoordinator() -> Coordinator {
            return Coordinator({
                ductSceneHitTest($0)
            })
        }
        
        class Coordinator {
            var initialPan: V2 = V2()
            var scale: Double = 1.0
            var hitTest: (String) -> Void
            
            init(_ hitTest: @escaping (String) -> Void) {
                self.hitTest = hitTest
            }
            static let faceNames = Set(["Front", "Back", "Left", "Right"])
            @objc func hit(g: UILongPressGestureRecognizer) {
                guard let v = (g.view as? SCNView) else { return }
                let res = v.hitTest(g.location(in: v))
                for r in res {
                    if( Coordinator.faceNames.contains(r.node.name ?? "") ) {
                        hitTest(r.node.name!)
                        break
                    }
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
                    camNode.position = (camNode.position.simd * (g.scale < self.scale ? 0.95 : 1.05)).asSCNV3
                }
            }
            
            @objc func panCam(g: UIPanGestureRecognizer) {
                guard g.view != nil else {return}
                let v = (g.view! as! SCNView)
                let t = g.translation(in: v)
                let translation = V2(t.x, t.y)
                if g.state == .began {
                    self.initialPan = translation
                }
                if g.state != .cancelled {
                    let rotSpeed: Double = 0.001
                    let d = initialPan - translation * V2(repeating: rotSpeed)
                    let camNode = v.scene?.rootNode.childNode(withName: "Camera", recursively: false)
                    let camPos = camNode?.worldPosition ?? SCNVector3()
                    let camPosSph = SIMDExtensions.Spherical<Float>(cartesian: camPos.asSIMDF)
                    var camPosSphEnd = camPosSph
                    camPosSphEnd.simd += V3(0, Float(d.y), Float(d.x))
                    let posEnd = camPosSph.asCartesian
                    camNode?.worldPosition = posEnd.asSCNV3
                    camNode?.worldOrientation = v.scene!.rootNode.worldOrientation
                    camNode?.look(at: SCNVector3(0,0,0))
                }
            }
        }
        @ObserveInjection var redraw
    }
    
    struct DuctAR: UIViewRepresentable {
        typealias UIViewType = DuctARSCNView
        typealias AppKey = DuctTransition.AppStorageKeys
        typealias V2 = SIMD2<Double>
        typealias V3 = SIMD3<Float>
        var geo: GeometryProxy
        var textShown: Bool
        @EnvironmentObject var state: DuctTransition.ModuleState
        @AppStorage(AppKey.showDebugInfo) var showDebugInfo = false
        @AppStorage(AppKey.energySaver) var energySaver = false
        @AppStorage(AppKey.crossBrake) var crossBrake = true
        @AppStorage(AppKey.lighting) var lighting: LightingMethod = .physicallyBased
        @AppStorage(AppKey.texture) var texture: String = "galvanized"
        @AppStorage(AppKey.bgType) var bgType: BackgroundType = .image
        @AppStorage(AppKey.showHelpers) var showHelpers: Bool = false
        @AppStorage(AppKey.bgR) var bgR: Double = 0.0
        @AppStorage(AppKey.bgG) var bgG: Double = 0.0
        @AppStorage(AppKey.bgB) var bgB: Double = 1.0
        @AppStorage(AppKey.bgImage) var bgImage: BackgroundImage = .shop
        var ductwork: DuctTransition.DuctData
        var ductSceneHitTest: (String) -> Void
        @Binding var resetARSession: Bool
        @Binding var selectorShown: Bool
        @State var cameraRollTime: Date = Date()
        let q = DispatchQueue.global(qos: .userInteractive)
        let s = DispatchSemaphore(value: 1)
        
        
        
        let view = UIViewType(frame: CGRect.zero)
        func dnode(_ scene: SCNScene?) -> SCNNode {
            return flownode(scene).childNode(withName: "duct", recursively: false) ?? SCNNode()
        }
        func flownode(_ scene: SCNScene?) -> SCNNode {
            return scene?.rootNode.childNode(withName: "flow", recursively: false) ?? SCNNode()
        }
        
        func energyUpdate(_ view: UIViewType) {
            if !energySaver {
                view.antialiasingMode = .multisampling2X
            }
            view.rendersContinuously = !energySaver
        }
        func materialUpdate(_ scene: SCNScene?) {
            for node in dnode(scene).childNodes {
                node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "\(texture)-diffuse")
                node.geometry?.firstMaterial?.metalness.contents = UIImage(named: "\(texture)-metallic")
                node.geometry?.firstMaterial?.normal.contents = UIImage(named: "\(texture)-normal")
                node.geometry?.firstMaterial?.roughness.contents = UIImage(named: "\(texture)-roughness")
                node.geometry?.firstMaterial?.lightingModel = lighting.scn
            }
        }
        func geometryUpdateAll(_ scene: SCNScene?, context: Context) {
            let ndnode = SCNNode()
            let nflownode = SCNNode()
            ndnode.eulerAngles = dnode(scene).eulerAngles
            nflownode.worldPosition = flownode(scene).worldPosition
            nflownode.eulerAngles = flownode(scene).eulerAngles
            dnode(scene).childNodes.forEach({ $0.removeFromParentNode()})
            dnode(scene).removeFromParentNode()
            flownode(scene).removeFromParentNode()
            for face in DuctTransition.Face.allCases {
                let faceNode = DuctTransition.FaceGeometry.generate(data: ductwork.vertexData, face: face, crossBrake: crossBrake)
                    .toNode(name: face.localizedString)
                ndnode.addChildNode(faceNode)
                for edge in DuctTransition.TabEdge.allCases {
                    if let tab = ductwork.tabs[face, edge] {
                        let tabNode = DuctTransition.TabGeometry.generate(tab, face: face, edge: edge, verts: ductwork.vertexData.getTabPoints(face, edge))
                        ndnode.addChildNode(tabNode)
                    }
                }
            }
            ndnode.name = "duct"
            nflownode.name = "flow"
            nflownode.addChildNode(ndnode)
            scene?.rootNode.addChildNode(nflownode)
        }
        func helpersUpdate(_ scene: SCNScene?) {
            let i = CGFloat(0.25)
            let f = UIColor(red: 0, green: i, blue: 0, alpha: i)
            let b = UIColor(red: i, green: 0, blue: 0, alpha: i)
            let l = UIColor(red: i, green: i, blue: 0, alpha: i)
            let r = UIColor(red: 0, green: 0, blue: i, alpha: i)
            let c = showHelpers
            let faceNames = Set(DuctTransition.Face.allCases.map { $0.localizedString })
            for x in dnode(scene).childNodes(passingTest: { node, _ in faceNames.contains(node.name ?? "") }) {
                switch x.name {
                case "Front": x.geometry?.firstMaterial?.emission.contents = c ? f : NSNumber(value: 0)
                case "Back":  x.geometry?.firstMaterial?.emission.contents = c ? b : NSNumber(value: 0)
                case "Left":  x.geometry?.firstMaterial?.emission.contents = c ? l : NSNumber(value: 0)
                case "Right": x.geometry?.firstMaterial?.emission.contents = c ? r : NSNumber(value: 0)
                default: break
                }
            }
        }
        
        func changeFlow(_ scene: SCNScene?) {
            let ang90: Float = 1.5708
            switch state.flowDirection {
            case .up: dnode(scene).eulerAngles = SCNVector3(0, 0, 0)
            case .down: dnode(scene).eulerAngles = SCNVector3(0, 0, ang90 * 2)
            case .right: dnode(scene).eulerAngles = SCNVector3(0, 0, ang90 * 3)
            case .left: dnode(scene).eulerAngles = SCNVector3(0, 0, ang90)
            }
        }
        
        func makeUIView(context: Context) -> UIViewType {
            view.session = ARSession()
            view.automaticallyUpdatesLighting = true
            view.session.configuration?.isLightEstimationEnabled = true
            let scene = SCNScene()
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = []
            configuration.environmentTexturing = .automatic
            configuration.isLightEstimationEnabled = true
            view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            let hitG = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.hit(g:)))
            let rotG = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.rotate(g:)))
            let panG = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.panCam(g:)))
            view.addGestureRecognizer(hitG)
            view.addGestureRecognizer(panG)
            view.addGestureRecognizer(rotG)
            energyUpdate(view)
            let ndnode = SCNNode()
            let nflownode = SCNNode()
            ndnode.name = "duct"
            nflownode.name = "flow"
            nflownode.addChildNode(ndnode)
            scene.rootNode.addChildNode(nflownode)
            geometryUpdateAll(scene, context: context)
            materialUpdate(scene)
            helpersUpdate(scene)
            changeFlow(scene)
            view.scene = scene
            view.currentDuctwork = ductwork
            view.crossbrake = crossBrake
            return view
        }
        func resetAR(_ view: UIViewType) {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = []
            configuration.environmentTexturing = .automatic
            configuration.isLightEstimationEnabled = true
            flownode(view.scene).worldPosition = .init()
            flownode(view.scene).eulerAngles = .init()
            view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            Task {
                resetARSession = false
            }
        }
        func updateUIView(_ uiView: UIViewType, context: Context) {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = []
            configuration.environmentTexturing = .automatic
            if resetARSession {
                resetAR(uiView)
            }
            if uiView.currentDuctwork != ductwork || crossBrake != uiView.crossbrake {
                geometryUpdateAll(uiView.scene, context: context)
                uiView.currentDuctwork = ductwork
                uiView.crossbrake = crossBrake
            }
            materialUpdate(uiView.scene)
            helpersUpdate(uiView.scene)
            context.coordinator.translationMode = state.translationMode
            changeFlow(uiView.scene)
            uiView.showsStatistics = showDebugInfo
            context.coordinator.translationMode = state.translationMode
        }
        
        static func dismantleUIView(_ uiView: DuctTransition.DuctARSCNView, coordinator: Coordinator) {
            uiView.session.pause()
        }
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(
                { s in
                    ductSceneHitTest(s)
                },
                state.translationMode,
                currentFlow: state.flowDirection
            )
        }
        
        class Coordinator {
            var ductPosition = SCNVector3(0, 0, 0)
            var ductRotation = CGFloat(0)
            var ductEuler = SCNVector3(0, 0, 0)
            var initialRotation = CGFloat(0)
            var initialPan = CGPoint.zero
            var translationMode: DuctTransition.ModuleState.TranslationMode
            var hitTest: (String) -> Void
            var currentFlow: DuctTransition.ModuleState.FlowDirection
            
            
            func dnode(_ scene: SCNScene?) -> SCNNode {
                flownode(scene).childNode(withName: "duct", recursively: false) ?? SCNNode()
            }
            func flownode(_ scene: SCNScene?) -> SCNNode {
                scene?.rootNode.childNode(withName: "flow", recursively: false) ?? SCNNode()
            }
            
            init(_ hitTest: @escaping (String) -> Void, _ translationM: DuctTransition.ModuleState.TranslationMode, currentFlow: DuctTransition.ModuleState.FlowDirection) {
                self.hitTest = hitTest
                self.translationMode = translationM
                self.currentFlow = currentFlow
            }
            
            @objc func hit(g: UILongPressGestureRecognizer) {
                guard let v = (g.view as? SCNView) else { return }
                let res = v.hitTest(g.location(in: v))
                for r in res {
                    if( DuctTransition.SceneView.Coordinator.faceNames.contains(r.node.name ?? "") ) {
                        hitTest(r.node.name!)
                        break
                    }
                }
            }
            
            @objc func rotate(g: UIRotationGestureRecognizer) {
                if g.state == .began {
                    initialRotation = g.rotation
                    
                }
                if g.state != .cancelled {
                    
                    flownode((g.view as? UIViewType)?.scene).eulerAngles.simd += SIMD3<Float>(0.0, -(g.rotation - initialRotation).f * 0.01, 0.0)
                    ductEuler = flownode((g.view as? UIViewType)?.scene).eulerAngles
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
                    case .xz: flownode((g.view as? UIViewType)?.scene).worldPosition.x += dx; flownode((g.view as? UIViewType)?.scene).worldPosition.z += dy
                    case .y: flownode((g.view as? UIViewType)?.scene).worldPosition.y -= dy
                    }
                }
                
            }
        }
        @ObserveInjection var redraw
    }
}
