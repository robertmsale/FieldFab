//
//  Duct.swift
//  FieldFab
//
//  Created by Robert Sale on 9/20/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit

enum DuctSides {
    case front
    case left
    case back
    case right
}

struct Ductwork {
    typealias V3 = SCNVector3
    typealias V2 = CGPoint
    typealias F = CGFloat
    public var v2D: [String: V2] = [:]
    public var v3D: [String: V3] = [:]
    public var b2D: [String: V2] = [:]
    public var b3D: [String: V3] = [:]
    public var measurements: [String: Fraction] = [:]
    
    init (
        _ l: F,
        _ w: F,
        _ d: F,
        _ oX: F,
        _ oY: F,
        _ tW: F,
        _ tD: F,
        _ rT: F) {
        let v3 = Ductwork.getVertices3D(l, w, d, oX, oY, tW, tD)
        self.v3D = v3
        let v2 = Ductwork.getVertices2D(l, w, d, oX, oY, tW, tD)
        self.v2D = v2
        let b2 = Ductwork.getBounding2D(v2)
        self.b2D = b2
        let b3 = Ductwork.getBounding3D(v3)
        self.b3D = b3
        let m = Ductwork.getMeasurements(v3, rT)
        self.measurements = m
    }
    
    mutating func update (
        _ l: F,
        _ w: F,
        _ d: F,
        _ oX: F,
        _ oY: F,
        _ tW: F,
        _ tD: F,
        _ rT: F) {
        let v3 = Ductwork.getVertices3D(l, w, d, oX, oY, tW, tD)
        self.v3D = v3
        let v2 = Ductwork.getVertices2D(l, w, d, oX, oY, tW, tD)
        self.v2D = v2
        let b2 = Ductwork.getBounding2D(v2)
        self.b2D = b2
        let b3 = Ductwork.getBounding3D(v3)
        self.b3D = b3
        let m = Ductwork.getMeasurements(v3, rT)
        self.measurements = m
    }
    
    mutating func updateMeasurements(_ rT: F) {
        let m = Ductwork.getMeasurements(self.v3D, rT)
        self.measurements = m
    }
    
    func getQuadGeometry(_ oX: CGFloat, _ oY: CGFloat, _ isAR: Bool = false) -> SCNGeometry {
        var outer = self.v3D
        for (k, v) in outer {
            outer[k] = v.translate(x: -(oX / 2))
            outer[k] = v.translate(z: -(oY / 2))
        }
        if isAR {
            for (k, v) in outer {
                outer[k] = v.multiplyScalar(0.0254)
            }
        }
        
        let z: CGFloat = 0.0
        let s: CGFloat = 0.1 * (isAR ? 0.0254 : 1.0)
        let inner = [
            "ftl": outer["ftl"]! - V3(-s, z,  s),
            "ftr": outer["ftr"]! - V3( s, z,  s),
            "fbl": outer["fbl"]! - V3(-s, z,  s),
            "fbr": outer["fbr"]! - V3( s, z,  s),
            "btl": outer["btl"]! - V3(-s, z, -s),
            "btr": outer["btr"]! - V3( s, z, -s),
            "bbl": outer["bbl"]! - V3(-s, z, -s),
            "bbr": outer["bbr"]! - V3( s, z, -s)
        ]
        let quads: [Quad] = [
            // outer
            Quad(outer["ftr"]!, outer["ftl"]!, outer["fbl"]!, outer["fbr"]!), // front
            Quad(outer["btl"]!, outer["btr"]!, outer["bbr"]!, outer["bbl"]!), // back
            Quad(outer["ftl"]!, outer["btl"]!, outer["bbl"]!, outer["fbl"]!), // left
            Quad(outer["btr"]!, outer["ftr"]!, outer["fbr"]!, outer["bbr"]!), // right
            // inner
            Quad(inner["ftl"]!, inner["ftr"]!, inner["fbr"]!, inner["fbl"]!), // front
            Quad(inner["btr"]!, inner["btl"]!, inner["bbl"]!, inner["bbr"]!), // back
            Quad(inner["btl"]!, inner["ftl"]!, inner["fbl"]!, inner["bbl"]!), // left
            Quad(inner["ftr"]!, inner["btr"]!, inner["bbr"]!, inner["fbr"]!), // right
            // top edges
            Quad(inner["ftr"]!, inner["ftl"]!, outer["ftl"]!, outer["ftr"]!), // front
            Quad(outer["btr"]!, outer["btl"]!, inner["btl"]!, inner["btr"]!), // back
            Quad(inner["btl"]!, outer["btl"]!, outer["ftl"]!, inner["ftl"]!), // left
            Quad(outer["btr"]!, inner["btr"]!, inner["ftr"]!, outer["ftr"]!), // right
            // bottom edges
            Quad(outer["fbr"]!, outer["fbl"]!, inner["fbl"]!, inner["fbr"]!), // front
            Quad(inner["bbr"]!, inner["bbl"]!, outer["bbl"]!, outer["bbr"]!), // back
            Quad(inner["fbl"]!, outer["fbl"]!, outer["bbl"]!, inner["bbl"]!), // left
            Quad(outer["fbr"]!, inner["fbr"]!, inner["bbr"]!, outer["bbr"]!), // right
        ]
        
        return GeometryBuilder(quads: quads).getGeometry()
    }
    
    static func getMeasurements(_ v: [String: V3], _ rT: F) -> [String: Fraction] {
        var lol: [String: Fraction] = [:]
        lol["front-bounding-l"] = v["fbl"]!.zero(.x).distance(v["ftl"]!.zero(.x)).toFraction(rT)
        lol["front-bounding-el"] = v["ftl"]!.zero(.y, .z).distance(v["fbl"]!.zero(.y, .z)).isLTZ()?.toFraction(rT)
        lol["front-bounding-er"] = v["ftr"]!.zero(.y, .z).distance(v["fbr"]!.zero(.y, .z)).isLTZ()?.toFraction(rT)
        lol["front-duct-t"] = v["ftl"]!.distance(v["ftr"]!).toFraction(rT)
        lol["front-duct-b"] = v["fbl"]!.distance(v["fbr"]!).toFraction(rT)
        lol["front-duct-l"] = v["fbl"]!.distance(v["ftl"]!).toFraction(rT)
        lol["front-duct-r"] = v["fbr"]!.distance(v["ftr"]!).toFraction(rT)
        lol["back-bounding-l"] = v["bbl"]!.zero(.x).distance(v["btl"]!.zero(.x)).isLTZ()?.toFraction(rT)
        lol["back-bounding-el"] = v["ftl"]!.zero(.y, .z).distance(v["fbl"]!.zero(.y, .z)).isLTZ()?.toFraction(rT)
        lol["back-bounding-er"] = v["ftr"]!.zero(.y, .z).distance(v["fbr"]!.zero(.y, .z)).isLTZ()?.toFraction(rT)
        lol["back-duct-t"] = v["ftr"]!.distance(v["ftl"]!).toFraction(rT)
        lol["back-duct-b"] = v["fbr"]!.distance(v["fbl"]!).toFraction(rT)
        lol["back-duct-l"] = v["fbl"]!.distance(v["ftl"]!).toFraction(rT)
        lol["back-duct-r"] = v["fbr"]!.distance(v["ftr"]!).toFraction(rT)
        lol["left-bounding-l"] = v["bbl"]!.zero(.z).distance(v["btl"]!.zero(.z)).isLTZ()?.toFraction(rT)
        lol["left-bounding-el"] = v["btl"]!.zero(.y, .x).distance(v["bbl"]!.zero(.y, .x)).isLTZ()?.toFraction(rT)
        lol["left-bounding-er"] = v["ftl"]!.zero(.y, .x).distance(v["fbl"]!.zero(.y, .x)).isLTZ()?.toFraction(rT)
        lol["left-duct-t"] = v["btl"]!.distance(v["ftl"]!).toFraction(rT)
        lol["left-duct-b"] = v["bbl"]!.distance(v["fbl"]!).toFraction(rT)
        lol["left-duct-l"] = v["bbl"]!.distance(v["btl"]!).toFraction(rT)
        lol["left-duct-r"] = v["fbl"]!.distance(v["ftl"]!).toFraction(rT)
        lol["right-bounding-l"] = v["bbr"]!.zero(.z).distance(v["btr"]!.zero(.z)).isLTZ()?.toFraction(rT)
        lol["right-bounding-el"] = v["fbr"]!.zero(.y, .x).distance(v["ftr"]!.zero(.y, .x)).isLTZ()?.toFraction(rT)
        lol["right-bounding-er"] = v["bbr"]!.zero(.y, .x).distance(v["btr"]!.zero(.y, .x)).isLTZ()?.toFraction(rT)
        lol["right-duct-t"] = v["btr"]!.distance(v["ftr"]!).toFraction(rT)
        lol["right-duct-b"] = v["bbr"]!.distance(v["fbr"]!).toFraction(rT)
        lol["right-duct-l"] = v["bbr"]!.distance(v["btr"]!).toFraction(rT)
        lol["right-duct-r"] = v["fbr"]!.distance(v["ftr"]!).toFraction(rT)
        return lol
    }
    
    static func getBounding2D (_ v: [String: CGPoint]) -> [String: CGPoint] {
        var lol: [String: CGPoint] = [:]
        let iter: [String] = ["f", "b", "l", "r"]
        for i in iter {
            let minX: F = min(min(v["\(i)bl"]!.x, v["\(i)tl"]!.x), min(v["\(i)br"]!.x, v["\(i)tr"]!.x))
            let maxX: F = max(max(v["\(i)bl"]!.x, v["\(i)tl"]!.x), max(v["\(i)br"]!.x, v["\(i)tr"]!.x))
            lol["\(i)bl"] = CGPoint(x: minX, y: v["\(i)bl"]!.y)
            lol["\(i)br"] = CGPoint(x: maxX, y: v["\(i)br"]!.y)
            lol["\(i)tl"] = CGPoint(x: minX, y: v["\(i)tl"]!.y)
            lol["\(i)tr"] = CGPoint(x: maxX, y: v["\(i)tr"]!.y)
        }
        return lol
    }
    
    static func getBounding3D (_ v: [String: V3]) -> [String: V3] {
        var minX: Float = 0.0
        var minY: Float = 0.0
        var minZ: Float = 0.0
        var maxX: Float = 0.0
        var maxY: Float = 0.0
        var maxZ: Float = 0.0
        for (_, v) in v {
            if v.x < minX { minX = v.x }
            if v.x > maxX { maxX = v.x }
            if v.y < minY { minY = v.y }
            if v.y > maxY { maxY = v.y }
            if v.z < minZ { minZ = v.z }
            if v.z > maxZ { maxZ = v.z }
        }
        var lol: [String: V3] = [:]
        lol["fbl"] = V3(minX, minY, maxZ)
        lol["fbr"] = V3(maxX, minY, maxZ)
        lol["ftl"] = V3(minX, maxY, maxZ)
        lol["ftr"] = V3(maxX, maxY, maxZ)
        lol["bbl"] = V3(minX, minY, minZ)
        lol["bbr"] = V3(maxX, minY, minZ)
        lol["btl"] = V3(minX, maxY, minZ)
        lol["btr"] = V3(maxX, maxY, minZ)
        return lol
    }
    
    static func getVertices2D (/*_ v: [String: V3]*/
        _ l: F,
        _ w: F,
        _ d: F,
        _ oX: F,
        _ oY: F,
        _ tW: F,
        _ tD: F
    ) -> [String: CGPoint] {
        var lol: [String: CGPoint] = [:]
        
        lol["fbl"] = V2(x: -(w / 2), y: l / 2).translate(x: -(oX / 2))
        lol["fbr"] = V2(x: w / 2, y: l / 2).translate(x: -(oX / 2))
        lol["ftl"] = V2(x: -(tW / 2) + oX, y: -(l / 2)).translate(x: -(oX / 2))
        lol["ftr"] = V2(x: tW / 2 + oX, y: -(l / 2)).translate(x: -(oX / 2))
        
        lol["bbl"] = V2(x: -(w / 2), y: l / 2).translate(x: oX)
        lol["bbr"] = V2(x: w / 2, y: l / 2).translate(x: oX)
        lol["btl"] = V2(x: -(tW / 2) - oX, y: -(l / 2)).translate(x: oX)
        lol["btr"] = V2(x: tW / 2 - oX, y: -(l / 2)).translate(x: oX)
        
        lol["lbl"] = V2(x: -(d / 2), y: l / 2).translate(x: -(oY))
        lol["lbr"] = V2(x: d / 2, y: l / 2).translate(x: -(oY))
        lol["ltl"] = V2(x: -(tD / 2) + oY, y: -(l / 2)).translate(x: -(oY))
        lol["ltr"] = V2(x: tD / 2 + oY, y: -(l / 2)).translate(x: -(oY))
        
        lol["rbl"] = V2(x: -(d / 2), y: l / 2).translate(x: oY / 2)
        lol["rbr"] = V2(x: d / 2, y: l / 2).translate(x: oY / 2)
        lol["rtl"] = V2(x: -(tD / 2) - oY, y: -(l / 2)).translate(x: oY / 2)
        lol["rtr"] = V2(x: tD / 2 - oY, y: -(l / 2)).translate(x: oY / 2)
        return lol
    }
    
    static func getVertices3D (
        _ l: F,
        _ w: F,
        _ d: F,
        _ oX: F,
        _ oY: F,
        _ tW: F,
        _ tD: F) -> [String: V3] {
        var lol: [String: V3] = [ "fbl": V3(-(w / 2), -(l / 2), d / 2) ]
        lol["fbr"] = V3(w / 2, -(l / 2), d / 2)
        lol["ftl"] = V3(-(tW / 2) + oX, l / 2, tD / 2 + oY)
        lol["ftr"] = V3(tW / 2 + oX, l / 2, tD / 2 + oY)
        lol["bbl"] = V3(-(w / 2), -(l / 2), -(d / 2))
        lol["bbr"] = V3(w / 2, -(l / 2), -(d / 2))
        lol["btl"] = V3(-(tW / 2) + oX, l / 2, -(tD / 2 + oY) + (oY * 2))
        lol["btr"] = V3(tW / 2 + oX, l / 2, -(tD / 2 + oY) + (oY * 2))
        return lol
    }
}
