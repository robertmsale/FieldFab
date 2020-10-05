//
//  ARContentView.swift
//  FieldFab
//
//  Created by Robert Sale on 9/27/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import ARKit
import UIKit

class ARData: ObservableObject {
    @Published var ductPos: SCNVector3 = SCNVector3(0.0, 0.0, 0.0)
    @Published var ductRotation = SCNVector3(0, 0, 0)
    @Published var resetAR: Bool = false
}

enum ARRotationMode {
    case x, y, z
}
enum ARMoveMode {
    case xz, y
}

struct ARContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var arData = ARData()
    @State var textHelperShown = false
    @State var rotationMode: ARRotationMode = .x
    @State var rotateActive: Bool = false
    @State var previousAngle: Angle = Angle(degrees: 0)
    @State var moveMode: ARMoveMode = .xz
    
    enum FindAngleRecurse {
        case below, above, none
    }
    
    func findNearestAngle(_ a: Float) -> Float {
        switch Math.radToDeg(rads: a) {
            case let x where x >= -382.5 && x < -337.5: return Math.degToRad(degrees: 0)
            case let x where x >= -337.5 && x < -292.5: return Math.degToRad(degrees: 45)
            case let x where x >= -292.5 && x < -247.5: return Math.degToRad(degrees: 90)
            case let x where x >= -247.5 && x < -202.5: return Math.degToRad(degrees: 135)
            case let x where x >= -202.5 && x < -157.5: return Math.degToRad(degrees: 180)
            case let x where x >= -157.5 && x < -112.5: return Math.degToRad(degrees: 225)
            case let x where x >= -112.5 && x < -67.5: return Math.degToRad(degrees: 270)
            case let x where x >= -67.5 && x < -22.5: return Math.degToRad(degrees: 315)
            case let x where x >= -22.5 && x < 22.5: return Math.degToRad(degrees: 0)
            case let x where x >= 22.5 && x < 67.5: return Math.degToRad(degrees: 45)
            case let x where x >= 67.5 && x < 112.5: return Math.degToRad(degrees: 90)
            case let x where x >= 112.5 && x < 157.5: return Math.degToRad(degrees: 135)
            case let x where x >= 157.5 && x < 202.5: return Math.degToRad(degrees: 180)
            case let x where x >= 202.5 && x < 247.5: return Math.degToRad(degrees: 225)
            case let x where x >= 247.5 && x < 292.5: return Math.degToRad(degrees: 270)
            case let x where x >= 292.5 && x < 337.5: return Math.degToRad(degrees: 315)
            case let x where x >= 337.5 && x < 382.5: return Math.degToRad(degrees: 0)
            default: return 0
        }
    }
    
    var body: some View {
        GeometryReader {g in
            ZStack {
                ARViewContainer(ductPosition: $arData.ductPos, ductRotation: $arData.ductRotation, rotationMode: rotationMode, textHelperShown: textHelperShown, reset: $arData.resetAR)
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: g.size.width, height: g.size.height)
                    .zIndex(-1)
                VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                    .frame(width: g.size.width, height: 32, alignment: .center)
                    .edgesIgnoringSafeArea(.top)
                    .position(x: g.size.width / 2, y: 0)
//                PlaneAdjustmentView(xz: $arData.xz)
//                    .frame(width: 100, height: 100)
//                    .position(x: 80, y: g.size.height - 60)
//                PlaneAdjustmentView(xz: $arData.y, axis: .y)
//                    .frame(width: 100, height: 100)
//                    .position(x: g.size.width - 80, y: g.size.height - 60)
                Button(action: { self.textHelperShown.toggle() }, label: {
                    Text(textHelperShown ? "Hide\nHelpers" : "Show\nHelpers")
                        .multilineTextAlignment(.center)
                        .padding()
                })
                .background(VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light)))
                .cornerRadius(15)
                .position(CGPoint(x: 62, y: g.size.height - 48))
                .zIndex(3)
                VStack {
                    Text("Rotation Mode")
                    ButtonGroup<ARRotationMode>(data: [.x, .y, .z], dataTitles: ["X", "Y", "Z"], wrappedValue: $rotationMode)
                }
                .frame(width: 120, height: 80)
                .zIndex(4)
                .position(x: g.size.width - 80, y: g.size.height - 60)
                VStack {
                    Text("Move Mode")
                    ButtonGroup<ARMoveMode>(data: [.xz, .y], dataTitles: ["XZ", "Y"], wrappedValue: $moveMode)
                }
                .frame(width: 120, height: 80)
                .zIndex(5)
                .position(x: g.size.width - 80, y: g.size.height - 200)
                
                ResetViewButton()
                    .frame(width: 60, height: 60)
                    .position(x: g.size.width / 2, y: g.size.height - 40)
                    .onTapGesture(count: 1, perform: {
                        self.arData.resetAR = true
                        self.arData.ductPos = SCNVector3(0, 0, 0)
                        self.arData.ductRotation = SCNVector3(0, 0, 0)
                    })
                    
            }
            .gesture(DragGesture().onChanged({ v in
                switch moveMode {
                    case .xz:
                        arData.ductPos = arData.ductPos.translate(x: v.translation.width * 0.0005 * 0.0254).translate(z: v.translation.height * 0.0005 * 0.0254)
                    case .y:
                        arData.ductPos = arData.ductPos.translate(y: -v.translation.height * 0.0005 * 0.0254)
                }
            }))
            .gesture(RotationGesture().onChanged({ a in
                if !rotateActive {
                    previousAngle = a
                    rotateActive = true
                }
                switch rotationMode {
                    case .x:
                        arData.ductRotation = arData.ductRotation.translate(x: a > previousAngle ? 0.0002 : -0.0002)
                    case .y:
                        arData.ductRotation = arData.ductRotation.translate(y: a > previousAngle ? -0.0002 : 0.0002)
                    case .z:
                        arData.ductRotation = arData.ductRotation.translate(z: a > previousAngle ? -0.0002 : 0.0002)
                }
                previousAngle = a
            }).onEnded({ _ in
                rotateActive = false
                switch rotationMode {
                    case .x: arData.ductRotation = arData.ductRotation.set(x: findNearestAngle(arData.ductRotation.x))
                    case .y: arData.ductRotation = arData.ductRotation.set(y: findNearestAngle(arData.ductRotation.y))
                    case .z: arData.ductRotation = arData.ductRotation.set(z: findNearestAngle(arData.ductRotation.z))
                }
            }))
        }
    }
}

struct ARContentView_Previews: PreviewProvider {
    static var previews: some View {
        ARContentView().environmentObject(AppLogic())
    }
}
