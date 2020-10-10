//
//  Duct.swift
//  FieldFab
//
//  Created by Robert Sale on 9/20/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit
import UIKit

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
    
    static func getQuadGeoFromFile(_ d: Dimensions) -> [SCNNode] {
        let newD = Ductwork(d.length, d.width, d.depth, d.offsetX, d.offsetY, d.tWidth, d.tDepth, 0.5)
        
        return newD.getQuadGeometry(d.offsetX, d.offsetY, options: [.sideTextShown], tabs: TabsData())
    }
    
    enum GetGeometryOptions {
        case isAR, sideTextShown
    }
    
    func getQuadGeometry(_ oX: CGFloat, _ oY: CGFloat, options opt: [GetGeometryOptions] = [], tabs: TabsData) -> [SCNNode] {
        let options = Set(opt)
        var outer = self.v3D
        for (k, v) in outer {
            outer[k] = v.translate(x: -(oX / 2))
            outer[k] = v.translate(z: -(oY / 2))
        }
        if options.contains(.isAR) {
            for (k, v) in outer {
                outer[k] = v.multiplyScalar(0.0254)
            }
        }
        
        let z: CGFloat = 0.0
        let s: CGFloat = 0.1 * (options.contains(.isAR) ? 0.0254 : 1.0)
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
        
        
        
        let geometry = GeometryBuilder(quads: quads).getGeometry()
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "metal-diffuse")
        material.normal.contents = UIImage(named: "metal-normal")
        material.ambientOcclusion.contents = UIImage(named: "metal-ao")
        material.metalness.contents = UIImage(named: "metal-metallic")
        material.roughness.contents = UIImage(named: "metal-roughness")
        material.lightingModel = .physicallyBased
        geometry.firstMaterial = material
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.name = "duct"
        
        
        let tr: CGFloat = options.contains(.isAR) ? 0.1 * 0.0254 : 0.1
        let fText = GeometryBuilder(quads: [
            Quad(
                outer["ftr"]!.translate(z: 1 * tr).set(x: 0).translate(x: min(outer["fbr"]!.x, outer["ftr"]!.x).cg),
                outer["ftl"]!.translate(z: 1 * tr).set(x: 0).translate(x: max(outer["ftl"]!.x, outer["fbl"]!.x).cg),
                outer["fbl"]!.translate(z: 1 * tr).set(x: 0).translate(x: max(outer["ftl"]!.x, outer["fbl"]!.x).cg),
                outer["fbr"]!.translate(z: 1 * tr).set(x: 0).translate(x: min(outer["fbr"]!.x, outer["ftr"]!.x).cg))
            ]).getGeometry()
        let bText = GeometryBuilder(quads: [
            Quad(
                outer["btl"]!.translate(z: -1 * tr).set(x: 0).translate(x: max(outer["btl"]!.x, outer["bbl"]!.x).cg),
                outer["btr"]!.translate(z: -1 * tr).set(x: 0).translate(x: min(outer["bbr"]!.x, outer["btr"]!.x).cg),
                outer["bbr"]!.translate(z: -1 * tr).set(x: 0).translate(x: min(outer["bbr"]!.x, outer["btr"]!.x).cg),
                outer["bbl"]!.translate(z: -1 * tr).set(x: 0).translate(x: max(outer["btl"]!.x, outer["bbl"]!.x).cg))
            ]).getGeometry()
        let lText = GeometryBuilder(quads: [
            Quad(
                outer["ftl"]!.translate(x: -1 * tr).set(z: 0).translate(z: min(outer["fbl"]!.z, outer["ftl"]!.z).cg),
                outer["btl"]!.translate(x: -1 * tr).set(z: 0).translate(z: max(outer["btl"]!.z, outer["bbl"]!.z).cg),
                outer["bbl"]!.translate(x: -1 * tr).set(z: 0).translate(z: max(outer["btl"]!.z, outer["bbl"]!.z).cg),
                outer["fbl"]!.translate(x: -1 * tr).set(z: 0).translate(z: min(outer["ftl"]!.z, outer["fbl"]!.z).cg))
            ]).getGeometry()
        let rText = GeometryBuilder(quads: [
            Quad(
                outer["btr"]!.translate(x: 1 * tr).set(z: 0).translate(z: max(outer["btr"]!.z, outer["bbr"]!.z).cg),
                outer["ftr"]!.translate(x: 1 * tr).set(z: 0).translate(z: min(outer["fbr"]!.z, outer["ftr"]!.z).cg),
                outer["fbr"]!.translate(x: 1 * tr).set(z: 0).translate(z: min(outer["fbr"]!.z, outer["ftr"]!.z).cg),
                outer["bbr"]!.translate(x: 1 * tr).set(z: 0).translate(z: max(outer["btr"]!.z, outer["bbr"]!.z).cg))
            ]).getGeometry()
        
        fText.firstMaterial?.diffuse.contents = UIColor.green
        bText.firstMaterial?.diffuse.contents = UIColor.yellow
        lText.firstMaterial?.diffuse.contents = UIColor.cyan
        rText.firstMaterial?.diffuse.contents = UIColor.red
        if options.contains(.sideTextShown) {
            fText.firstMaterial?.transparent.contents = UIImage(named: "F")
            bText.firstMaterial?.transparent.contents = UIImage(named: "B")
            lText.firstMaterial?.transparent.contents = UIImage(named: "L")
            rText.firstMaterial?.transparent.contents = UIImage(named: "R")
        } else {
            fText.firstMaterial?.transparent.contents = UIColor.white
            bText.firstMaterial?.transparent.contents = UIColor.white
            lText.firstMaterial?.transparent.contents = UIColor.white
            rText.firstMaterial?.transparent.contents = UIColor.white
        }
        fText.firstMaterial?.transparencyMode = .rgbZero
        bText.firstMaterial?.transparencyMode = .rgbZero
        lText.firstMaterial?.transparencyMode = .rgbZero
        rText.firstMaterial?.transparencyMode = .rgbZero
        
        let f = SCNNode(geometry: fText)
        let b = SCNNode(geometry: bText)
        let l = SCNNode(geometry: lText)
        let r = SCNNode(geometry: rText)
        f.name = "h-front"
        b.name = "h-back"
        l.name = "h-left"
        r.name = "h-right"
        
        
//        var rend: [DuctFace: [TabSide: TabData]] = [:]
//        for face in DuctFace.allCases {
//            for side in TabSide.allCases {
//
//            }
//        }
        var result = [geometryNode, f, b, l, r]
        result.append(contentsOf: generateTabs(outer: outer, inner: inner, tabs: tabs, material: material))
        return result
    }
    
    func generateTabs(outer: [String: V3], inner: [String: V3], tabs: TabsData, material: SCNMaterial) -> [SCNNode] {
        var quads: [Quad] = []
        print("Generating tabs")
        if tabs.front.top.getLength() != .none {
            let len = tabs.front.top.getLength().rawValue
            switch tabs.front.top.getType() {
                case .straight:
                    print("made to switch case")
                    quads.append(contentsOf: [
                        Quad(
                            outer["ftr"]!.translate(y: len),
                            outer["ftl"]!.translate(y: len),
                            outer["ftl"]!,
                            outer["ftr"]!),
                        Quad(
                            inner["ftl"]!.translate(y: len),
                            inner["ftr"]!.translate(y: len),
                            inner["ftr"]!,
                            inner["ftl"]!),
                        Quad(
                            outer["ftl"]!.translate(y: len),
                            inner["ftl"]!.translate(y: len),
                            inner["ftl"]!,
                            outer["ftl"]!)
                    ])
                default: return []
            }
        }
        if quads.count > 0 {
            let geo = GeometryBuilder(quads: quads).getGeometry()
            geo.firstMaterial = material
            let node = SCNNode(geometry: geo)
            node.name = "tabs"
            return [node]
        } else {
            return []
        }
    }
    
    enum TabFacing {
        case plusX, minusX, plusZ, minusZ
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
        lol["back-bounding-el"] = v["bbr"]!.zero(.y, .z).distance(v["btr"]!.zero(.y, .z)).isLTZ()?.toFraction(rT)
        lol["back-bounding-er"] = v["bbl"]!.zero(.y, .z).distance(v["btl"]!.zero(.y, .z)).isLTZ()?.toFraction(rT)
        lol["back-duct-t"] = v["btr"]!.distance(v["btl"]!).toFraction(rT)
        lol["back-duct-b"] = v["bbr"]!.distance(v["bbl"]!).toFraction(rT)
        lol["back-duct-l"] = v["bbr"]!.distance(v["btr"]!).toFraction(rT)
        lol["back-duct-r"] = v["bbl"]!.distance(v["btl"]!).toFraction(rT)
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
