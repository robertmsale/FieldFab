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
    @State var roundToIndex = 1
    @ObservedObject var id: Indexer = Indexer(["Front", "Right", "Back", "Left"])
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        return GeometryReader { g in
            NextPrevHeaderView(self.id.current, action: self.id.mutate, opt: [.overlay, .fillTopEdge]) {
                ZStack(content: {
                    switch self.id.current {
                        case "Front": DuctSideView(g: g, side: .front).zIndex(-1)
                        case "Left": DuctSideView(g: g, side: .left).zIndex(-1)
                        case "Right": DuctSideView(g: g, side: .right).zIndex(-1)
                        default: DuctSideView(g: g, side: .back).zIndex(-1)
                    }
                    HStack() {
                        Text("Round To")
                        ZStack {
                            HStack(alignment: .center) {
                                
                                Rectangle()
                                    .fill(Color(.sRGB, white: 0, opacity: 0.01))
                                    .background(Image(systemName: "arrow.left"))
                                    .foregroundColor(.blue)
                                    .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                    .onTapGesture(count: 1, perform: {
                                        if self.roundToIndex == 0 { self.roundToIndex = 4 }
                                        else { self.roundToIndex -= 1}
                                        self.aL.roundTo = MathUtils.INCREMENTS[self.roundToIndex]
                                    })
                                Spacer()
                                Text(MathUtils.INCREMENTSTRINGS[self.roundToIndex])
                                Spacer()
                                
                                Rectangle()
                                    .fill(Color(.sRGB, white: 0, opacity: 0.01))
                                    .background(Image(systemName: "arrow.right"))
                                    .foregroundColor(.blue)
                                    .frame(width: 30, height: 30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                    .onTapGesture(count: 1, perform: {
                                        if self.roundToIndex == 4 { self.roundToIndex = 0 }
                                        else { self.roundToIndex += 1}
                                        self.aL.roundTo = MathUtils.INCREMENTS[self.roundToIndex]
                                    })
                            }
                            .padding(.horizontal, 16.0)
                            .padding(.vertical, 8.0)
                            .zIndex(20.0)
                            VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light))
                                .cornerRadius(15)
                        }
                        .frame(width: g.size.width / 2, height: 32)
                    }
                    .position(x: g.size.width / 2, y: g.size.height)
                })
                
            }
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
        ContentView().environmentObject(AppLogic()).environment(\.colorScheme, .dark)
    }
}
