//
//  GridView.swift
//  FieldFab
//
//  Created by Robert Sale on 9/25/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct GridView: View {
    typealias P = CGPoint
    typealias F = CGFloat
    @Binding var scale: CGFloat
    @Binding var offset: CGPoint
    let minScale: CGFloat = 0.1

    func makeV(g: GeometryProxy) -> Path {
        let p = CGMutablePath()
        p.move(to: P(x: g.size.width / 2, y: 0.0))
        p.addLine(to: P(x: g.size.width / 2, y: g.size.height))
        return Path(p)
    }

    func makeH(g: GeometryProxy) -> Path {
        let p = CGMutablePath()
        p.move(to: P(x: 0.0, y: g.size.height / 2))
        p.addLine(to: P(x: g.size.width, y: g.size.height / 2))
        return Path(p)
    }

    func makeLinePoints(g: GeometryProxy) -> [CGMutablePath] {
        let vLines = (g.size.width / 10 * max(self.minScale, self.scale)).ceil()
        let hLines = (g.size.height / 10 * max(self.minScale, self.scale)).ceil()
        var lines: [(P, P)] = []
        for i in 1...Int(vLines / 2) {
            lines.append((
                P(x: g.size.width / 2, y: 0.0).translate(x: 10 * F(i) * max(self.minScale, self.scale)),
                P(x: g.size.width / 2, y: g.size.height).translate(x: 10 * F(i) * max(self.minScale, self.scale))
            ))
            lines.append((
                P(x: g.size.width / 2, y: 0.0).translate(x: -( 10 * F(i) * max(self.minScale, self.scale) )),
                P(x: g.size.width / 2, y: g.size.height).translate(x: -( 10 * F(i) * max(self.minScale, self.scale) ))
            ))
        }
        for i in 1...Int(hLines / 2) {
            lines.append((
                P(x: 0.0, y: g.size.height / 2).translate(y: 10 * F(i) * max(self.minScale, self.scale)),
                P(x: g.size.width, y: g.size.height / 2).translate(y: 10 * F(i) * max(self.minScale, self.scale))
            ))
            lines.append((
                P(x: 0.0, y: g.size.height / 2).translate(y: -( 10 * F(i) * max(self.minScale, self.scale) )),
                P(x: g.size.width, y: g.size.height / 2).translate(y: -( 10 * F(i) * max(self.minScale, self.scale) ))
            ))
        }
        var paths: [CGMutablePath] = []
        for (from, to) in lines {
            let p = CGMutablePath()
            p.move(to: from)
            p.addLine(to: to)
            paths.append(p)
        }
        return paths
    }

    var body: some View {
        GeometryReader { g in
            ForEach(self.makeLinePoints(g: g), id: \.self) { p in
                Path(p).stroke(lineWidth: 1.0).foregroundColor(Color(hue: 0.0, saturation: 0.0, brightness: 0.9))
            }
            makeV(g: g).stroke(lineWidth: 2.0).foregroundColor(Color(hue: 0.0, saturation: 0.0, brightness: 0.7))
            makeH(g: g).stroke(lineWidth: 2.0).foregroundColor(Color(hue: 0.0, saturation: 0.0, brightness: 0.7))
        }
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(scale: Binding.constant(1.0), offset: Binding.constant(CGPoint(x: 1.0, y: 1.0)))
    }
}
