//
//  Quad.swift
//  FieldFab
//
//  Created by Robert Sale on 9/7/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct QuadFace {
    var bl: Vector3
    var br: Vector3
    var tl: Vector3
    var tr: Vector3
    var lenTop: CGFloat { get { self.tl.distance(to: self.tr) } }
    var lenBottom: CGFloat { get { self.bl.distance(to: self.br) } }
    var lenLeft: CGFloat { get { self.tl.distance(to: self.bl) } }
    var lenRight: CGFloat { get { self.tr.distance(to: self.br) } }
    
    enum QuadXOrZ {
        case tlx
        case tlz
        case trx
        case trz
        case blx
        case blz
        case brx
        case brz
    }
    
    subscript (_ v: QuadXOrZ) -> CGPoint {
        get {
            switch v {
            case .tlx:
                return CGPoint(x: self.tl.x, y: self.tl.y)
            case .tlz:
                return CGPoint(x: self.tl.z, y: self.tl.y)
            case .trx:
                return CGPoint(x: self.tr.x, y: self.tl.y)
            case .trz:
                return CGPoint(x: self.tr.z, y: self.tr.y)
            case .blx:
                return CGPoint(x: self.bl.x, y: self.bl.y)
            case .blz:
                return CGPoint(x: self.bl.z, y: self.bl.y)
            case .brx:
                return CGPoint(x: self.br.x, y: self.br.y)
            default:
                return CGPoint(x: self.br.z, y: self.br.y)
            }
        }
    }
    
    mutating func reverseY () {
        self.bl.y = -self.bl.y
        self.br.y = -self.br.y
        self.tl.y = -self.tl.y
        self.tr.y = -self.tr.y
    }
}

struct Quad {
    var front: QuadFace
    var back: QuadFace
    
    
    static func genQuadFromDimensions(
        length l: CGFloat,
        width w: CGFloat,
        depth d: CGFloat,
        offsetX oX: CGFloat,
        offsetY oY: CGFloat,
        tWidth tW: CGFloat,
        tDepth tD: CGFloat) -> Quad {
        
        let fbl = Vector3(-(w / 2), -(l / 2), d / 2)
        let fbr = Vector3(w / 2, -(l / 2), d / 2)
        let ftl = Vector3(-(tW / 2 - oX), l / 2, tD / 2 + oY)
        let ftr = Vector3(tW / 2 + oX, l / 2, tD / 2 + oY)
        let bbl = Vector3(fbl.x, fbl.y, -fbl.z)
        let bbr = Vector3(fbr.x, fbr.y, -fbr.z)
        let btl = Vector3(ftl.x, ftl.y, -ftl.z + (oY * 2))
        let btr = Vector3(ftr.x, ftr.y, -ftl.z + (oY * 2))
        let f = QuadFace( bl: fbl, br: fbr, tl: ftl, tr: ftr )
        let b = QuadFace( bl: bbl, br: bbr, tl: btl, tr: btr )
        return Quad( front: f, back: b )
    }
    
    static func adjustAxisFor2D (_ q: inout Quad) {
        q.front.tl.x = -q.front.tl.x
        q.front.tr.x = -q.front.tr.x
        q.back.tr.x = -q.back.tr.x
        q.back.tr.x = -q.back.tr.x
    }
}

struct Quad_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppLogic())
    }
}
