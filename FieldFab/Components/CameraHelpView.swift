//
//  Camera Help View.swift
//  FieldFab
//
//  Created by Robert Sale on 9/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct CameraHelpView: View {
    var g: GeometryProxy
    @Binding var visible: Bool
    @Environment(\.colorScheme) var colorScheme

    func rImage(_ i: String) -> Image {
        if colorScheme == .dark {
            return Image("\(i) Inverted")
        } else {
            return Image(i)
        }
    }

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 24.0) {
                Spacer()
                HStack(alignment: .center) {
                    rImage("Drag")
                    Spacer()
                    Text("Drag finger to rotate camera around the ductwork").multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24.0)
                .padding(.top, 24.0)
                Divider().background(Color.white)
                HStack(alignment: .center) {
                    rImage("Rotate")
                    Spacer()
                    Text("Rotate with two fingers to roll the camera").multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24.0)
                Divider().background(Color.white)
                HStack(alignment: .center) {
                    rImage("Drag")
                    Spacer()
                    Text("Pinch and spread fingers to zoom").multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24.0)
                Divider().background(Color.white)
                HStack(alignment: .center) {
                    VStack {
                        rImage("HScroll")
                        rImage("VScroll")
                    }
                    Spacer()
                    Text("Scroll with two fingers to adjust camera position").multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24.0)
                Spacer()
            }
            .frame(width: self.g.size.width, height: self.g.size.height, alignment: .center)
            //            .background(
            //                Rectangle()
            //                    .fill(Color.black)
            //                    .frame(width: self.g.size.width, height: self.g.size.height, alignment: .center)
            //            )
            .foregroundColor(colorScheme == .dark ? .white : .black)
            //            .opacity(0.8)
            .zIndex(2.0)
            Button(action: { self.visible = false }, label: {
                Image(systemName: "xmark")
                    .font(.title)
                    .frame(width: 25, height: 25)
                    .padding()
                    .background(VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light)))
                    .cornerRadius(45.0)
            })
            .zIndex(3.0)
            .position(CGPoint(x: self.g.size.width - 40, y: self.g.size.height - 40))
        }
    }
}

struct CameraHelpViewPreviews: PreviewProvider {
    static var previews: some View {
        var lol = true
        return GeometryReader { g in
            CameraHelpView(g: g, visible: Binding(get: { lol }, set: {v in lol = v}))
        }
    }
}
