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
    @State var roundToIndex = 1
    
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
                    HStack() {
                        Text("Round To")
                        Spacer()
                        HStack(alignment: .center) {
                            Button(action: {
                                if self.roundToIndex == 0 { self.roundToIndex = 4 }
                                else { self.roundToIndex -= 1}
                                self.aL.roundTo = MathUtils.INCREMENTS[self.roundToIndex]
                            }, label: {
                                Image(systemName: "minus")
                            })
                            Spacer()
                            Text(MathUtils.INCREMENTSTRINGS[self.roundToIndex])
                            Spacer()
                            Button(action: {
                                if self.roundToIndex == 4 { self.roundToIndex = 0 }
                                else { self.roundToIndex += 1}
                                self.aL.roundTo = MathUtils.INCREMENTS[self.roundToIndex]
                            }, label: {
                                Image(systemName: "plus")
                            })
                        }
                        .padding(.horizontal, 16.0)
                        .padding(.vertical, 8.0)
                        .background(/*@START_MENU_TOKEN@*/Color(hue: 1.0, saturation: 0.016, brightness: 0.51, opacity: 0.112)/*@END_MENU_TOKEN@*/)
                        .frame(width: 180)
                    }
                    .padding(.vertical, 8.0)
                    .padding(.horizontal, 16.0)
                    .onAppear() {
                        switch self.aL.roundTo {
                            case 0.03125:
                            self.roundToIndex = 0
                            case 0.0625:
                            self.roundToIndex = 1
                            case 0.125:
                            self.roundToIndex = 2
                            case 0.25:
                            self.roundToIndex = 3
                            case 0.5:
                            self.roundToIndex = 4
                            default:
                            self.roundToIndex = 0
                        }
                    }
                }
                switch self.sides[self.sidesIndex] {
                    case "Front": DuctSideView(g: g, side: .front)
                    case "Left": DuctSideView(g: g, side: .left)
                    case "Right": DuctSideView(g: g, side: .right)
                    default: DuctSideView(g: g, side: .back)
                }
//                    .zIndex(-1.0)
            })
        }
    }
}

//struct TwoDSKScene: UIViewRepresentable {
//    @EnvironmentObject var aL: AppLogic
//    var g: GeometryProxy
//    var side: DuctSides
//
//    func makeUIView(context: Context) -> SKView {
//        let skView = SKView(frame: CGRect(x: 0.0, y: 0.0, width: g.size.width, height: g.size.height))
//        let scene = SKScene(size: skView.bounds.size)
//        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        scene.backgroundColor = .darkGray
//        let boundsMax = min(skView.bounds.size.width, skView.bounds.size.height)
//        let d = self.aL.duct[self.side]
//        let b = self.aL.duct.bounding(side: self.side)
//        var ductPath = CGMutablePath()
//        ductPath.move(to: <#T##CGPoint#>)
//        return skView
//    }
//
//    func updateUIView(_ uiView: SKView, context: Context) {
//
//    }
//}

struct TwoD_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppLogic())
    }
}
