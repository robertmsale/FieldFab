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
    @Published var ductRotation: SCNVector3 = SCNVector3(0, 0, 0)
    @Published var xz: CGPoint = CGPoint(x: 0.0, y: 0.0) {
        didSet {
            self.ductPos = SCNVector3(self.xz.x.f, self.ductPos.y, -self.xz.y.f)
        }
    }
    @Published var y: CGPoint = CGPoint(x: 0.0, y: 0.0) {
        didSet {
            self.ductPos = SCNVector3(self.ductPos.x, self.y.y.f, self.ductPos.z)
        }
    }
    @Published var resetAR: Bool = false
}

struct ARContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var arData = ARData()
    
    var body: some View {
        GeometryReader {g in
            ZStack {
                ARViewContainer(ductPosition: $arData.ductPos, ductRotation: $arData.ductRotation, reset: $arData.resetAR)
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: g.size.width, height: g.size.height)
                    .zIndex(-1)
                VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                    .frame(width: g.size.width, height: 32, alignment: .center)
                    .edgesIgnoringSafeArea(.top)
                    .position(x: g.size.width / 2, y: 0)
                PlaneAdjustmentView(xz: $arData.xz)
                    .frame(width: 100, height: 100)
                    .position(x: 80, y: g.size.height - 60)
                PlaneAdjustmentView(xz: $arData.y, axis: .y)
                    .frame(width: 100, height: 100)
                    .position(x: g.size.width - 80, y: g.size.height - 60)
                ResetViewButton()
                    .frame(width: 60, height: 60)
                    .position(x: g.size.width / 2, y: g.size.height - 40)
                    .onTapGesture(count: 1, perform: {
                        self.arData.resetAR = true
                    })
                RotateButtonView(side: .top)
                    .frame(width: 70, height: 70, alignment: .center)
                    .position(x: g.size.width / 2, y: 70)
                    .edgesIgnoringSafeArea(.top)
                    .onTapGesture(count: 1, perform: {
                        if self.arData.ductRotation.z == 0 {
                            self.arData.ductRotation = self.arData.ductRotation.translate(z: Math.degToRad(degrees: 270))
                        } else {
                            self.arData.ductRotation = self.arData.ductRotation.translate(z: Math.degToRad(degrees: -90))
                        }
                    })
                RotateButtonView(side: .bottom)
                    .frame(width: 70, height: 70, alignment: .center)
                    .position(x: g.size.width / 2, y: g.size.height - 130)
                    .onTapGesture(count: 1, perform: {
                        if self.arData.ductRotation.z == Math.degToRad(degrees: 270).f {
                            self.arData.ductRotation = self.arData.ductRotation.translate(z: Math.degToRad(degrees: -270))
                        } else {
                            self.arData.ductRotation = self.arData.ductRotation.translate(z: Math.degToRad(degrees: 90))
                        }
                    })
                RotateButtonView(side: .left)
                    .frame(width: 70, height: 70, alignment: .center)
                    .position(x: 40, y: g.size.height / 2)
                    .onTapGesture(count: 1, perform: {
                        if self.arData.ductRotation.x == 0 {
                            self.arData.ductRotation = self.arData.ductRotation.translate(x: Math.degToRad(degrees: 270))
                        } else {
                            self.arData.ductRotation = self.arData.ductRotation.translate(x: Math.degToRad(degrees: -90))
                        }
                    })
                RotateButtonView(side: .right)
                    .frame(width: 70, height: 70, alignment: .center)
                    .position(x: g.size.width - 40, y: g.size.height / 2)
                    .onTapGesture(count: 1, perform: {
                        if self.arData.ductRotation.x == Math.degToRad(degrees: 270).f {
                            self.arData.ductRotation = self.arData.ductRotation.translate(x: Math.degToRad(degrees: -270))
                        } else {
                            self.arData.ductRotation = self.arData.ductRotation.translate(x: Math.degToRad(degrees: 90))
                        }
                    })
                    
            }
        }
    }
}

struct ARContentView_Previews: PreviewProvider {
    static var previews: some View {
        ARContentView().environmentObject(AppLogic())
    }
}
