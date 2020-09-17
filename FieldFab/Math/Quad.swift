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
    
    static func convertToBounding(_ q: inout Quad) {
        q.front.bl = Vector3(
            x: min(q.front.tl.x, q.front.bl.x),
            y: q.front.bl.y,
            z: max(q.front.bl.z, q.front.tl.z))
        q.front.br = Vector3(
            x: max(q.front.br.x, q.front.tr.x),
            y: q.front.br.y,
            z: max(q.front.tr.z, q.front.br.z))
        q.front.tl = Vector3(
            x: min(q.front.tl.x, q.front.bl.x),
            y: q.front.tl.y,
            z: max(q.front.bl.z, q.front.tl.z))
        q.front.tr = Vector3(
            x: max(q.front.br.x, q.front.tr.x),
            y: q.front.tr.y,
            z: max(q.front.tr.z, q.front.br.z))
        q.back.bl = Vector3(
            x: min(q.back.tl.x, q.back.bl.x),
            y: q.back.bl.y,
            z: min(q.back.bl.z, q.back.tl.z))
        q.back.br = Vector3(
            x: max(q.back.br.x, q.back.tr.x),
            y: q.back.br.y,
            z: min(q.back.tr.z, q.back.br.z))
        q.back.tl = Vector3(
            x: min(q.back.tl.x, q.back.bl.x),
            y: q.back.tl.y,
            z: min(q.back.bl.z, q.back.tl.z))
        q.back.tr = Vector3(
            x: max(q.back.br.x, q.back.tr.x),
            y: q.back.tr.y,
            z: min(q.back.tr.z, q.back.br.z))
    }
    
    static func convertToAR(_ q: inout Quad) {
        q.front.bl.multiplyScalar(scale: 0.0254)
        q.front.br.multiplyScalar(scale: 0.0254)
        q.front.tl.multiplyScalar(scale: 0.0254)
        q.front.tr.multiplyScalar(scale: 0.0254)
        q.back.bl.multiplyScalar(scale: 0.0254)
        q.back.br.multiplyScalar(scale: 0.0254)
        q.back.tl.multiplyScalar(scale: 0.0254)
        q.back.tr.multiplyScalar(scale: 0.0254)
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
