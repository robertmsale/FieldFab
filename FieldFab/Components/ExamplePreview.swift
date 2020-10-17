//
//  ExamplePreview.swift
//  FieldFab
//
//  Created by Robert Sale on 10/16/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

//struct ExamplePreview: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}

#if DEBUG
struct ExamplePreview_Previews: PreviewProvider {
    static var previews: some View {
        let al = AppLogic()
        al.width = Fraction(16)
        al.depth = Fraction(20)
        al.isTransition = true
        al.offsetX = Fraction(0)
        al.offsetY = Fraction(-2)
        al.tWidth = Fraction(20)
        al.tDepth = Fraction(16)
        al.roundTo = 0.125
        return VStack(spacing: 0) {
            Text("Offset X")
            FStepper(val: Binding(get: { al.offsetX }, set: { v in al.offsetX = v }), fullStep: true, stepSize: .quarter, isMeasurement: true, big: true)
                .frame(height: 64)
                .padding()
            Text("Offset Y")
            FStepper(val: Binding(get: { al.offsetY }, set: { v in al.offsetY = v }), fullStep: true, stepSize: .quarter, isMeasurement: true, big: true)
                .frame(height: 64)
                .padding()
            Text("Front").font(.title)
            GeometryReader { g in
                DuctSideView(g: g, side: .front)
            }.frame(width: 300, height: 275)
            Text("Left").font(.title)
            GeometryReader { g in
                DuctSideView(g: g, side: .left)
            }.frame(width: 300, height: 270)
            Spacer()
        }.environmentObject(al)
    }
}
#endif
