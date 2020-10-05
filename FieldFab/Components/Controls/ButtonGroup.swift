//
//  ButtonGroup.swift
//  FieldFab
//
//  Created by Robert Sale on 10/4/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct ButtonGroup<T>: View {
    var data: [T]
    var dataTitles: [String]
    @State var selected: Int = 0
    @Binding var wrappedValue: T
    @Environment(\.colorScheme) var colorScheme
    
    func renderClipShape(_ i: Int, _ g: GeometryProxy) -> Path {
        let path = Path { p in
            switch i {
                case 0:
                    p.move(to: CGPoint(x: g.size.width, y: 0))
                    p.addLine(to: CGPoint(x: g.size.width, y: g.size.height))
                    p.addLine(to: CGPoint(x: 15, y: g.size.height))
                    p.addQuadCurve(to: CGPoint(x: 0, y: g.size.height - 15), control: CGPoint(x: 0, y: g.size.height))
                    p.addLine(to: CGPoint(x: 0, y: 15))
                    p.addQuadCurve(to: CGPoint(x: 15, y: 0), control: CGPoint.zero)
                case data.count - 1:
                    p.move(to: CGPoint.zero)
                    p.addLine(to: CGPoint(x: g.size.width - 15, y: 0))
                    p.addQuadCurve(to: CGPoint(x: g.size.width, y: 15), control: CGPoint(x: g.size.width, y: 0))
                    p.addLine(to: CGPoint(x: g.size.width, y: g.size.height - 15))
                    p.addQuadCurve(to: CGPoint(x: g.size.width - 15, y: g.size.height), control: CGPoint(x: g.size.width, y: g.size.height))
                    p.addLine(to: CGPoint(x: 0, y: g.size.height))
                default:
                    p.move(to: CGPoint.zero)
                    p.addLine(to: CGPoint(x: 0, y: g.size.height))
                    p.addLine(to: CGPoint(x: g.size.width, y: g.size.height))
                    p.addLine(to: CGPoint(x: g.size.width, y: 0))
            }
        }
        return path
    }
    
    var body: some View {
        GeometryReader { g in
            HStack(alignment: .center, spacing: 0) {
                ForEach(Range(0...data.count - 1)) { i in
                    GeometryReader { bg in
                        Button(action: {
                            selected = i
                            wrappedValue = data[i]
                        }, label: {
                            Text(dataTitles[i]).font(.title)
                        })
                        .frame(width: bg.size.width, height: bg.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .background(VisualEffectView(effect: UIBlurEffect(style: colorScheme == .dark ? .dark : .light)))
                        .background(Color.black.opacity(selected == i ? 0.8 : 0))
                        .clipShape(renderClipShape(i, bg))
                    }
                }
            }
            .frame(width: g.size.width, height: g.size.height, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}

#if DEBUG
struct ButtonGroup_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(3) {
            ButtonGroup<Int>(data: [1, 2, 3], dataTitles: ["X", "Y", "Z"], wrappedValue: $0)
        }
    }
}
#endif
