//
//  2D.swift
//  FieldFab
//
//  Created by Robert Sale on 9/6/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SpriteKit

struct TwoD: View {
    @EnvironmentObject var aL: AppLogic
    let sides = ["Left", "Front", "Right", "Back"]
    @State var sidesIndex = 1
    
    func getQuadFace() -> QuadFace {
        let quad = Quad.genQuadFromDimensions(
            length: self.aL.length.original,
            width: self.aL.width.original,
            depth: self.aL.depth.original,
            offsetX: self.aL.offsetX.original,
            offsetY: self.aL.offsetY.original,
            tWidth: self.aL.tWidth.original,
            tDepth: self.aL.tDepth.original)
        switch self.sides[self.sidesIndex] {
        case "Left":
            return QuadFace(
                bl: quad.back.bl,
                br: quad.front.bl,
                tl: quad.back.tl,
                tr: quad.front.tl)
        case "Right":
            return QuadFace(
                bl: quad.front.br,
                br: quad.back.br,
                tl: quad.front.tr,
                tr: quad.back.tr)
        case "Back":
            return quad.back
        default:
            return quad.front
        }
    }
    
    var body: some View {
        return GeometryReader { g in
            ZStack(content: {
                VStack() {
                    HStack() {
                        Button(action: {
                            if self.sidesIndex == 0 { self.sidesIndex = 3 }
                            else { self.sidesIndex -= 1 }
                        }, label: {
                            Image(systemName: "arrow.left")
                        })
                        Spacer()
                        Text(self.sides[self.sidesIndex])
                        Spacer()
                        Button(action: {
                            if self.sidesIndex == 3 { self.sidesIndex = 0 }
                            else { self.sidesIndex += 1 }
                        }, label: {
                            Image(systemName: "arrow.right")
                        })
                    }
                    .padding(.all)
                    .font(.title)
                    .background(/*@START_MENU_TOKEN@*/Color(hue: 1.0, saturation: 0.013, brightness: 0.84, opacity: 0.209)/*@END_MENU_TOKEN@*/)
//                    .zIndex(2.0)
                    Spacer()
                }
                DuctSideView(g: g, face: self.getQuadFace(), side: self.sides[self.sidesIndex])
//                    .zIndex(-1.0)
            })
        }
    }
}

struct TwoD_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppLogic())
    }
}
