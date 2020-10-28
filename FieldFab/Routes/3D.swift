//
//  3D.swift
//  FieldFab
//
//  Created by Robert Sale on 9/11/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit
import UIKit

class ThreeDData: ObservableObject {
    @Published var objectHit = SceneObject.front
    @Published var showPopup = false
    @Published var tapRecognized = false
    
}
enum SceneObject {
    case front, back, left, right
}

struct ThreeD: View {
    @State var helpVisible = false
    @State var cameraMode = true
    @State var selectorShown = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var al: AppLogic
    @GestureState var lol = false
    @ObservedObject var data = ThreeDData()
    
    func getPopupPosition(_ g: GeometryProxy) -> CGPoint {
        if data.showPopup { return CGPoint(x: g.size.width / 2, y: g.size.height / 2) }
        else { return CGPoint(x: g.size.width / 2, y: 2000)}
    }

    var body: some View {
        GeometryReader {g in
            ZStack {
                SceneView(
                    geo: g,
                    textShown: al.threeDViewHelpersShown,
                    tapHandler: { name in
                        switch name {
                            case "front", "h-front":
                                print("Hit front")
                                print(al.threeDObjectHitPopupShown)
                                al.threeDObjectHitPopupShown = true
                                al.threeDObjectHit = .front
                            case "back", "h-back":
                                al.threeDObjectHitPopupShown = true
                                al.threeDObjectHit = .back
                            case "left", "h-left":
                                al.threeDObjectHitPopupShown = true
                                al.threeDObjectHit = .left
                            case "right", "h-right":
                                al.threeDObjectHitPopupShown = true
                                al.threeDObjectHit = .right
                            case let tab where tab[0...2] == "tab":
                                switch tab[4...5] {
                                    case "ft": print("Hit front top tab")
                                    default: break
                                }
                            default: break
                        }
                    },
                    selectorShown: $selectorShown
                )
                        .edgesIgnoringSafeArea(.all)
//                if /*!cameraMode*/ false {
//                    Rectangle()
//                        .opacity(0)
//                        .onTapWithLocation({v in
//                            data.hitTestLocation = v
//                            data.tapRecognized = true
//                        })
//                }
//                HStack(spacing: 0) {
//                    Button(action: {cameraMode = true}, label: {
//                        Image(systemName: "camera.rotate").font(.title)
//                            .frame(width: 60, height: 40)
//                    })
//                    .disabled(cameraMode)
//                    Divider()
//                    Button(action: {cameraMode = false}, label: {
//                        Image(systemName: "wand.and.rays").font(.title)
//                            .frame(width: 60, height: 40)
//                    })
//                    .disabled(!cameraMode)
//                }
//                .background(BlurEffectView())
//                .cornerRadius(15)
//                .frame(width: 120, height: 40)
//                .position(x: g.size.width / 2, y: 90.0)
                Button(action: { self.helpVisible = true }, label: {
                    Image(systemName: "questionmark")
                        .font(.title)
                        .frame(width: 25, height: 25)
                        .padding()
                        .background(VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light)))
                        .cornerRadius(90)
                })
                .position(CGPoint(x: 40, y: g.size.height - 40))
                .zIndex(2.0)
                Button(action: {
                    al.threeDMenuShown = true
                }, label: {
                    Image(systemName: "pencil")
                        .font(.title)
                        .frame(width: 25, height: 25)
                        .padding()
                        .background(VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light)))
                        .cornerRadius(90)
                })
                .position(CGPoint(x: g.size.width - 40, y: g.size.height - 40))
                .zIndex(3)
                if al.experimentalFeaturesEnabled.contains(.newLayout) {
                    SelectorWheel(shown: $selectorShown)
                        .zIndex(4)
                        .clipShape(Rectangle())
                        .edgesIgnoringSafeArea(.horizontal)
                }
                if helpVisible {
                    CameraHelpView(g: g, visible: $helpVisible)
                        .background(
                            VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                        )
                        .zIndex(4.0)
                }
            }
        }
    }
}

struct _D_Previews: PreviewProvider {
    static var previews: some View {
        let aL = AppLogic()
        aL.isTransition = true
        aL.width = Fraction(16)
        aL.depth = Fraction(20)
        aL.length = Fraction(5)
        aL.offsetX = Fraction(1)
        aL.offsetY = Fraction(1)
        aL.tWidth = Fraction(20)
        aL.tDepth = Fraction(16)
        return GeometryReader { _ in
            ThreeD().environmentObject(aL)
        }
    }
}

struct SceneView: UIViewRepresentable {
    var geo: GeometryProxy
    var textShown: Bool
    @EnvironmentObject var aL: AppLogic
    var tapHandler: (String) -> Void
    @Binding var selectorShown: Bool
    typealias V3 = SCNVector3
    
    class Coordinator: NSObject {
        var tapHandler: (String) -> Void
        
        init(handler: @escaping (String) -> Void) {
            self.tapHandler = handler
        }
        
        @objc func tapped(g: UILongPressGestureRecognizer) -> Void {
            let res = (g.view as! SceneView.UIViewType).hitTest(g.location(in: g.view))
            if res.count > 0 {
                self.tapHandler(res[0].node.name ?? "")
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(handler: self.tapHandler)
    }

    func makeUIView(context: Context) -> SCNView {
        let bounding = min(self.geo.size.width, self.geo.size.height)
        let sceneView = SCNView(frame: CGRect(x: 0.0, y: 0.0, width: bounding, height: bounding))

        sceneView.rendersContinuously = true
        sceneView.showsStatistics = aL.experimentalFeaturesEnabled.contains(.showDebugInfo)
        guard let scene = SCNScene(named: "ductwork.scn", inDirectory: "main.scnassets")
        else { fatalError("Derp") }
        scene.rootNode.childNode(withName: "plane", recursively: false)?.geometry?.firstMaterial?.fillMode = .lines

        let camera = SCNCamera()
        camera.fieldOfView = 90
        camera.zFar = 1000
        let camNode = SCNNode()
        var maxXZ: Float = 0.0
        for (_, v) in self.aL.duct.v3D {
            maxXZ = maxXZ < max(v.x, v.z) ? max(v.x, v.z) : maxXZ
        }
        camNode.worldPosition = SCNVector3(0.0, 0.0, maxXZ * 4)
        camNode.name = "camera"
        camNode.camera = camera
        sceneView.allowsCameraControl = true

        let geometryNode = self.aL.duct.getQuadGeometry(
            self.aL.offsetX.original,
            self.aL.offsetY.original,
            options: textShown ? [.sideTextShown] : [],
            tabs: aL.tabs)
        for v in geometryNode {
            scene.rootNode.addChildNode(v)
        }
        
        let gesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped))
        gesture.minimumPressDuration = 0.5

        scene.rootNode.addChildNode(camNode)

        sceneView.scene = scene
        sceneView.addGestureRecognizer(gesture)
        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.showsStatistics = aL.experimentalFeaturesEnabled.contains(.showDebugInfo)
        var maxXZ: Float = 0.0
        for (_, v) in self.aL.duct.v3D {
            maxXZ = maxXZ < max(v.x, v.z) ? max(v.x, v.z) : maxXZ
        }
        if aL.threeDMeasurementsDidChange {
            uiView.scene?.rootNode.childNode(withName: "duct", recursively: false)?.removeFromParentNode()
            uiView.scene?.rootNode.childNode(withName: "camera", recursively: false)?.removeFromParentNode()
            uiView.scene?.rootNode.childNode(withName: "h-front", recursively: false)?.removeFromParentNode()
            uiView.scene?.rootNode.childNode(withName: "h-back", recursively: false)?.removeFromParentNode()
            uiView.scene?.rootNode.childNode(withName: "h-left", recursively: false)?.removeFromParentNode()
            uiView.scene?.rootNode.childNode(withName: "h-right", recursively: false)?.removeFromParentNode()
            var nodeNames = ["duct", "camera", "h-front", "h-back", "h-left"]
            nodeNames.append(contentsOf: ["h-right", "front", "back", "left", "right"])
            for i in nodeNames {
                uiView.scene?.rootNode.childNode(withName: i, recursively: false)?.removeFromParentNode()
            }
            var tabnames = ["ft", "fb", "fl", "fr", "bt", "bb", "bl"]
            tabnames.append(contentsOf: ["br", "lt", "lb", "ll", "lr", "rt", "rb", "rl", "rr"])
            for i in tabnames {
                uiView.scene?.rootNode.childNode(withName: "tab-\(i)", recursively: false)?.removeFromParentNode()
            }

            let camera = SCNCamera()
            camera.fieldOfView = 90
            let camNode = SCNNode()
            camNode.worldPosition = SCNVector3(0.0, 0.0, maxXZ * 4)
            camNode.name = "camera"
            camNode.camera = camera

            let geometryNode = self.aL.duct.getQuadGeometry(
                self.aL.offsetX.original,
                self.aL.offsetY.original,
                options: textShown ? [.sideTextShown] : [],
                tabs: aL.tabs)

            for v in geometryNode {
                uiView.scene?.rootNode.addChildNode(v)
            }

            uiView.scene?.rootNode.addChildNode(camNode)
            aL.threeDMeasurementsDidChange = false
        } else {
//            if tapRecognized {
//                let res = uiView.hitTest(hitTestLocation)
//                if res.count > 0 {
//
//                }
//                tapRecognized = false
//            }
            uiView.scene?.rootNode.childNode(withName: "h-front", recursively: false)?.geometry?.firstMaterial?.transparent.contents = aL.threeDViewHelpersShown ? UIImage(named: "F") : UIColor.white
            uiView.scene?.rootNode.childNode(withName: "h-back", recursively: false)?.geometry?.firstMaterial?.transparent.contents = aL.threeDViewHelpersShown ? UIImage(named: "B") : UIColor.white
            uiView.scene?.rootNode.childNode(withName: "h-left", recursively: false)?.geometry?.firstMaterial?.transparent.contents = aL.threeDViewHelpersShown ? UIImage(named: "L") : UIColor.white
            uiView.scene?.rootNode.childNode(withName: "h-right", recursively: false)?.geometry?.firstMaterial?.transparent.contents = aL.threeDViewHelpersShown ? UIImage(named: "R") : UIColor.white
        }
        
        if selectorShown {
            let cam = uiView.scene?.rootNode.childNode(withName: "camera", recursively: false)
            switch aL.selectorWheelSelection {
                case .width, .tWidth, .offsetX:
                    cam?.position = SCNVector3(0, 0, maxXZ * 4)
                case .depth, .tDepth, .offsetY:
                    cam?.position = SCNVector3(maxXZ * 4, 0, 0)
                default:
                    cam?.position = SCNVector3(0, 0, maxXZ * 4)
            }
            cam?.look(at: SCNVector3(0, 0, 0))
            uiView.pointOfView = cam
        }
    }
}
