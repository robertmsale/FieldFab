//
//  ARMenuSheet.swift
//  FieldFab
//
//  Created by Robert Sale on 10/7/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit

enum FlowDirection: UInt64, CaseIterable, Identifiable {
    case up = 0
    case down = 1
    case left = 2
    case right = 3

    var id: UInt64 { self.rawValue }

    func getVector() -> SCNVector3 {
        switch self {
        case .up: return SCNVector3(x: 0, y: 0, z: 0)
        case .left: return SCNVector3(x: 0, y: 0, z: Math.degToRad(degrees: -90))
        case .right: return SCNVector3(x: 0, y: 0, z: Math.degToRad(degrees: 90))
        case .down: return SCNVector3(x: 0, y: 0, z: Math.degToRad(degrees: 180))
        }
    }
}

struct ARMenuSheet: View {
    @EnvironmentObject var al: AppLogic

    var body: some View {
        ScrollView {
            VStack {
                Text("Flow Direction")
                Picker("Flow Direction", selection: $al.arViewFlowDirection) {
                    Text("Up").tag(FlowDirection.up)
                    Text("Down").tag(FlowDirection.down)
                    Text("Left").tag(FlowDirection.left)
                    Text("Right").tag(FlowDirection.right)
                }.pickerStyle(SegmentedPickerStyle())
                Divider()
                HStack {
                    Text("Helpers shown")
                    Spacer()
                    Toggle("", isOn: $al.arViewHelpersShown)
                }
            }
            .padding()
        }
    }
}

struct ARMenuSheet_Previews: PreviewProvider {
    static var previews: some View {
        ARMenuSheet().environmentObject(AppLogic())
    }
}
