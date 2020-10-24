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

    static func getQuadGeoFromFile(_ d: DimensionsData) -> [SCNNode] {
        let newD = Ductwork(d.length, d.width, d.depth, d.offsetX, d.offsetY, d.tWidth, d.tDepth, 0.5)

        return newD.getQuadGeometry(d.offsetX, d.offsetY, options: [.sideTextShown], tabs: d.tabs)
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
        var inner = [
            "ftl": outer["ftl"]! - V3(-s, z, s),
        ]
        inner["ftr"] = outer["ftr"]! - V3( s, z, s)
        inner["fbl"] = outer["fbl"]! - V3(-s, z, s)
        inner["fbr"] = outer["fbr"]! - V3( s, z, s)
        inner["btl"] = outer["btl"]! - V3(-s, z, -s)
        inner["btr"] = outer["btr"]! - V3( s, z, -s)
        inner["bbl"] = outer["bbl"]! - V3(-s, z, -s)
        inner["bbr"] = outer["bbr"]! - V3( s, z, -s)
            
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
            Quad(outer["fbr"]!, inner["fbr"]!, inner["bbr"]!, outer["bbr"]!) // right
        ]

        let geometry = GeometryBuilder(quads: quads).getGeometry()
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "metal-diffuse")
        material.normal.contents = UIImage(named: "metal-normal")
//        material.ambientOcclusion.contents = UIImage(named: "metal-ao")
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
        result.append(contentsOf: generateTabs(outer: outer, inner: inner, tabs: tabs, material: material, isAR: options.contains(.isAR)))
        return result
    }

    func genShape(len: Float, width: Float, type: TabType, thickness: Float, material: SCNMaterial, taper: Float = 1) -> SCNGeometry {
        
        switch type {
        case .straight:
            let path = CGMutablePath()
            path.move(to: V2.zero)
            path.addLine(to: V2(x: 0, y: len))
            path.addLine(to: V2(x: thickness, y: len))
            path.addLine(to: V2(x: thickness, y: 0))
            path.addLine(to: V2.zero)

            let shape = SCNShape(path: UIBezierPath(cgPath: path), extrusionDepth: width.cg)
            shape.firstMaterial = material
            return shape
        case .tapered:
            let path = CGMutablePath()
            path.move(to: V2.zero)
            path.addLine(to: V2(x: width, y: 0))
            path.addLine(to: V2(x: width - taper, y: len))
            path.addLine(to: V2(x: taper, y: len))
            path.addLine(to: V2.zero)
            let shape = SCNShape(path: UIBezierPath(cgPath: path), extrusionDepth: thickness.cg)
            shape.firstMaterial = material
            return shape
        case .drive:
            let path = CGMutablePath()
            let half = len / 2
            path.move(to: CGPoint.zero)
            path.addQuadCurve(to: CGPoint(x: (thickness * 3 / 2).cg, y: half.cg), control: CGPoint(x: 0, y: half.cg))
            path.addQuadCurve(to: CGPoint(x: (thickness * 3).cg, y: 0), control: CGPoint(x: (thickness * 3).cg, y: half.cg))
            path.addLine(to: CGPoint(x: (thickness * 3 - thickness).cg, y: 0))
            path.addQuadCurve(to:
                                CGPoint(x: (thickness * 3 / 2).cg, y: (half - thickness).cg),
                              control:
                                CGPoint(x: (thickness * 3 - thickness).cg, y: (half - thickness).cg)
            )
            path.addQuadCurve(to: CGPoint(x: thickness.cg, y: 0), control: CGPoint(x: (thickness * 3 / 2).cg, y: (half - thickness).cg))
            path.addLine(to: CGPoint(x: 0, y: 0))

            let shape = SCNShape(path: UIBezierPath(cgPath: path), extrusionDepth: (width).cg)
            shape.firstMaterial = material
            return shape
        case .slock:
            let path = CGPath(rect: CGRect(x: 0, y: 0, width: (thickness).cg * 3, height: len.cg), transform: nil)
            let shape = SCNShape(path: UIBezierPath(cgPath: path), extrusionDepth: width.cg)
            shape.firstMaterial = material
            return shape
        default: return SCNGeometry()
        }
    }

    func generateTabs(outer: [String: V3], inner: [String: V3], tabs: TabsData, material: SCNMaterial, isAR: Bool) -> [SCNNode] {
        var nodes: [SCNNode] = []
        let thickness = inner["ftl"]!.z.distance(to: outer["ftl"]!.z) * (isAR ? 0.0254 : 1)
        let taper: Float = isAR ? 0.0254 : 1
        print("Generating tabs")
        var len = (tabs.front.top.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.front.top.getType() {
        case .none: break
        case .straight:
            let shape = genShape(len: len, width: inner["ftl"]!.x.distance(to: inner["ftr"]!.x), type: .straight, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["ftl"]!.translate(x: inner["ftl"]!.x.distance(to: inner["ftr"]!.x) / 2))
            node.eulerAngles = V3(x: 0, y: Math.degToRad(degrees: -90), z: 0)
            node.name = "tab-ft"
            nodes.append(node)
        case .tapered:
            let shape = genShape(len: len, width: inner["ftl"]!.x.distance(to: inner["ftr"]!.x), type: .tapered, thickness: thickness, material: material, taper: taper)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: outer["ftl"]!)
            node.name = "tab-ft"
            nodes.append(node)
        case .drive:
            let shape = genShape(len: len, width: inner["ftl"]!.x.distance(to: inner["ftr"]!.x), type: .drive, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-ft"
            node.localTranslate(by: V3(inner["ftl"]!.x + (inner["ftl"]!.x.distance(to: inner["ftr"]!.x) / 2), inner["ftl"]!.y, inner["ftl"]!.z))
            node.eulerAngles = V3(x: 0, y: Math.degToRad(degrees: -90), z: 0)
            nodes.append(node)
        case .slock:
            let shape = genShape(len: taper, width: inner["ftl"]!.x.distance(to: inner["ftr"]!.x) - thickness, type: .slock, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-ft"
            node.localTranslate(by: V3(inner["ftl"]!.x + (inner["ftl"]!.x.distance(to: inner["ftr"]!.x) / 2), inner["ftl"]!.y, inner["ftl"]!.z))
            node.eulerAngles = V3(x: 0, y: Math.degToRad(degrees: -90), z: 0)
            nodes.append(node)
        case .foldIn:
            let shape = genShape(len: len, width: inner["ftl"]!.x.distance(to: inner["ftr"]!.x), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["ftl"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: -90), y: 0, z: 0)
            node.name = "tab-ft"
            nodes.append(node)
        case .foldOut:
            let shape = genShape(len: len, width: inner["ftl"]!.x.distance(to: inner["ftr"]!.x), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["ftl"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: 90), y: 0, z: 0)
            node.name = "tab-ft"
            nodes.append(node)
        }
        len = (tabs.front.bottom.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.front.bottom.getType() {
        case .none: break
        case .straight:
            let shape = genShape(len: len, width: inner["fbl"]!.x.distance(to: inner["fbr"]!.x), type: .straight, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["fbl"]!.translate(x: inner["fbl"]!.x.distance(to: inner["fbr"]!.x) / 2).translate(y: -len))
            node.eulerAngles = V3(x: 0, y: Math.degToRad(degrees: -90), z: 0)
            node.name = "tab-fb"
            nodes.append(node)
        case .tapered:
            let shape = genShape(len: len, width: inner["fbl"]!.x.distance(to: inner["fbr"]!.x), type: .tapered, thickness: thickness, material: material, taper: taper)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: outer["fbl"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: 180), y: 0, z: 0)
            node.name = "tab-fb"
            nodes.append(node)
        case .drive:
            let shape = genShape(len: len, width: inner["fbl"]!.x.distance(to: inner["fbr"]!.x), type: .drive, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-fb"
            node.localTranslate(by: V3(inner["fbl"]!.x + (inner["fbl"]!.x.distance(to: inner["fbr"]!.x) / 2), inner["fbl"]!.y, inner["fbl"]!.z))
            node.eulerAngles = V3(x: 0, y: Math.degToRad(degrees: -90), z: Math.degToRad(degrees: 180))
            nodes.append(node)
        case .slock:
            let shape = genShape(len: taper, width: inner["fbl"]!.x.distance(to: inner["fbr"]!.x) - thickness, type: .slock, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-fb"
            node.localTranslate(by: V3(inner["fbl"]!.x + (inner["fbl"]!.x.distance(to: inner["fbr"]!.x) / 2), inner["fbl"]!.y - len, inner["fbl"]!.z))
            node.eulerAngles = V3(x: 0, y: Math.degToRad(degrees: -90), z: 0)
            nodes.append(node)
        case .foldIn:
            let shape = genShape(len: len, width: inner["fbl"]!.x.distance(to: inner["fbr"]!.x), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["fbl"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: -90), y: 0, z: 0)
            node.name = "tab-fb"
            nodes.append(node)
        case .foldOut:
            let shape = genShape(len: len, width: inner["fbl"]!.x.distance(to: inner["fbr"]!.x), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["fbl"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: 90), y: 0, z: 0)
            node.name = "tab-fb"
            nodes.append(node)
        }
        len = (tabs.front.left.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.front.left.getType() {
            case .slock, .foldIn:
                var v = [
                    outer["ftl"]!,
                    outer["ftl"]!.translate(z: -taper),
                    outer["fbl"]!.translate(z: -taper),
                    outer["fbl"]!,
                ]
                v.append(contentsOf: [
                    v[0].translate(x: -thickness),
                    v[1].translate(x: -thickness),
                    v[2].translate(x: -thickness),
                    v[3].translate(x: -thickness),
                ])
                let quads = [
                    Quad(v[4], v[5], v[6], v[7]),
                    Quad(v[0], v[4], v[7], v[3]),
                    Quad(v[1], v[5], v[4], v[0]),
                    Quad(v[5], v[1], v[2], v[6]),
                    Quad(v[3], v[7], v[6], v[2])
                ]
                let geo = GeometryBuilder(quads: quads).getGeometry()
                geo.firstMaterial = material
                let node = SCNNode(geometry: geo)
                node.name = "tab-fl"
                nodes.append(node)
            default: break
        }
        len = (tabs.front.right.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.front.right.getType() {
            case .slock, .foldIn:
                var v = [
                    outer["ftr"]!.translate(z: -taper),
                    outer["ftr"]!,
                    outer["fbr"]!,
                    outer["fbr"]!.translate(z: -taper),
                ]
                v.append(contentsOf: [
                    v[0].translate(x: thickness),
                    v[1].translate(x: thickness),
                    v[2].translate(x: thickness),
                    v[3].translate(x: thickness),
                ])
                let quads = [
                    Quad(v[4], v[5], v[6], v[7]),
                    Quad(v[0], v[4], v[7], v[3]),
                    Quad(v[1], v[5], v[4], v[0]),
                    Quad(v[5], v[1], v[2], v[6]),
                    Quad(v[3], v[7], v[6], v[2])
                ]
                let geo = GeometryBuilder(quads: quads).getGeometry()
                geo.firstMaterial = material
                let node = SCNNode(geometry: geo)
                node.name = "tab-fr"
                nodes.append(node)
            default: break
        }
        
        // Back //////////////////////////////////////////
        len = (tabs.back.top.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.back.top.getType() {
        case .none: break
        case .straight:
            let shape = genShape(len: len, width: inner["ftl"]!.x.distance(to: inner["ftr"]!.x), type: .straight, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: outer["btl"]!.translate(x: outer["btl"]!.x.distance(to: outer["btr"]!.x) / 2))
            node.eulerAngles = V3(x: 0, y: Math.degToRad(degrees: -90), z: 0)
            node.name = "tab-bt"
            nodes.append(node)
        case .tapered:
            let shape = genShape(len: len, width: inner["btl"]!.x.distance(to: inner["btr"]!.x), type: .tapered, thickness: thickness, material: material, taper: taper)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: outer["btl"]!)
            node.name = "tab-bt"
            nodes.append(node)
        case .drive:
            let shape = genShape(len: len, width: inner["btl"]!.x.distance(to: inner["btr"]!.x), type: .drive, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-bt"
            node.localTranslate(by: V3(inner["btl"]!.x + (inner["btl"]!.x.distance(to: inner["btr"]!.x) / 2), outer["btl"]!.y, outer["btl"]!.z).translate(z: -thickness * 3))
            node.eulerAngles = V3(x: 0, y: Math.degToRad(degrees: -90), z: 0)
            nodes.append(node)
        case .slock:
            let shape = genShape(len: taper, width: inner["btl"]!.x.distance(to: inner["btr"]!.x) - thickness, type: .slock, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-bt"
            node.localTranslate(by: V3(inner["btl"]!.x + (inner["btl"]!.x.distance(to: inner["btr"]!.x) / 2), inner["btl"]!.y, inner["btl"]!.z))
            node.eulerAngles = V3(x: 0, y: Math.degToRad(degrees: -90), z: 0)
            nodes.append(node)
        case .foldIn:
            let shape = genShape(len: len, width: inner["btl"]!.x.distance(to: inner["btr"]!.x), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["btl"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: 90), y: 0, z: 0)
            node.name = "tab-bt"
            nodes.append(node)
        case .foldOut:
            let shape = genShape(len: len, width: inner["btl"]!.x.distance(to: inner["btr"]!.x), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["btl"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: -90), y: 0, z: 0)
            node.name = "tab-bt"
            nodes.append(node)
        }
        len = (tabs.back.bottom.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.back.bottom.getType() {
        case .none: break
        case .straight:
            let shape = genShape(len: len, width: inner["bbl"]!.x.distance(to: inner["bbr"]!.x), type: .straight, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["bbl"]!.translate(x: inner["bbl"]!.x.distance(to: inner["bbr"]!.x) / 2).translate(y: -len).translate(x: thickness / 2).translate(z: -thickness))
            node.eulerAngles = V3(x: 0, y: Math.degToRad(degrees: -90), z: 0)
            node.name = "tab-bb"
            nodes.append(node)
        case .tapered:
            let shape = genShape(len: len, width: inner["bbl"]!.x.distance(to: inner["bbr"]!.x), type: .tapered, thickness: thickness, material: material, taper: taper)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: outer["bbl"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: 180), y: 0, z: 0)
            node.name = "tab-bb"
            nodes.append(node)
        case .drive:
            let shape = genShape(len: len, width: inner["bbl"]!.x.distance(to: inner["bbr"]!.x), type: .drive, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-bb"
            node.localTranslate(by: V3(inner["bbl"]!.x + (inner["bbl"]!.x.distance(to: inner["bbr"]!.x) / 2), outer["bbl"]!.y, outer["bbl"]!.z).translate(z: -thickness * 3))
            node.eulerAngles = V3(x: 0, y: Math.degToRad(degrees: -90), z: Math.degToRad(degrees: 180))
            nodes.append(node)
        case .slock:
            let shape = genShape(len: taper, width: inner["bbl"]!.x.distance(to: inner["bbr"]!.x) - thickness, type: .slock, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-bb"
            node.localTranslate(by: V3(inner["bbl"]!.x + (inner["bbl"]!.x.distance(to: inner["bbr"]!.x) / 2), inner["bbl"]!.y - len, inner["bbl"]!.z).translate(z: -thickness * 2))
            node.eulerAngles = V3(x: 0, y: Math.degToRad(degrees: -90), z: 0)
            nodes.append(node)
        case .foldIn:
            let shape = genShape(len: len, width: inner["bbl"]!.x.distance(to: inner["bbr"]!.x), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["bbl"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: 90), y: 0, z: 0)
            node.name = "tab-bb"
            nodes.append(node)
        case .foldOut:
            let shape = genShape(len: len, width: inner["bbl"]!.x.distance(to: inner["bbr"]!.x), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["bbl"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: -90), y: 0, z: 0)
            node.name = "tab-bb"
            nodes.append(node)
        }
        len = (tabs.back.left.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.back.left.getType() {
            case .slock, .foldIn:
                var v = [
                    outer["btr"]!.translate(z: taper),
                    outer["btr"]!,
                    outer["bbr"]!,
                    outer["bbr"]!.translate(z: taper),
                ]
                v.append(contentsOf: [
                    v[0].translate(x: thickness),
                    v[1].translate(x: thickness),
                    v[2].translate(x: thickness),
                    v[3].translate(x: thickness),
                ])
                let quads = [
                    Quad(v[4], v[5], v[6], v[7]),
                    Quad(v[0], v[4], v[7], v[3]),
                    Quad(v[1], v[5], v[4], v[0]),
                    Quad(v[5], v[1], v[2], v[6]),
                    Quad(v[3], v[7], v[6], v[2])
                ]
                let geo = GeometryBuilder(quads: quads).getGeometry()
                geo.firstMaterial = material
                let node = SCNNode(geometry: geo)
                node.name = "tab-bl"
                nodes.append(node)
            default: break
        }
        len = (tabs.back.right.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.back.right.getType() {
            case .slock, .foldIn:
                var v = [
                    outer["btl"]!.translate(z: taper),
                    outer["btl"]!,
                    outer["bbl"]!,
                    outer["bbl"]!.translate(z: taper),
                ]
                v.append(contentsOf: [
                    v[0].translate(x: -thickness),
                    v[1].translate(x: -thickness),
                    v[2].translate(x: -thickness),
                    v[3].translate(x: -thickness),
                ])
                let quads = [
                    Quad(v[4], v[5], v[6], v[7]),
                    Quad(v[0], v[4], v[7], v[3]),
                    Quad(v[1], v[5], v[4], v[0]),
                    Quad(v[5], v[1], v[2], v[6]),
                    Quad(v[3], v[7], v[6], v[2])
                ]
                let geo = GeometryBuilder(quads: quads).getGeometry()
                geo.firstMaterial = material
                let node = SCNNode(geometry: geo)
                node.name = "tab-br"
                nodes.append(node)
            default: break
        }
        
        // Left //////////////////////////////////////////
        len = (tabs.left.top.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.left.top.getType() {
        case .none: break
        case .straight:
            let shape = genShape(len: len, width: inner["btl"]!.z.distance(to: inner["ftl"]!.z), type: .straight, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["btl"]!.translate(z: inner["btl"]!.distance(inner["ftl"]!) / 2).translate(x: -thickness * 2))
            node.eulerAngles = V3(x: 0, y: 0, z: 0)
            node.name = "tab-lt"
            nodes.append(node)
        case .tapered:
            let shape = genShape(len: len, width: inner["btl"]!.z.distance(to: inner["ftl"]!.z), type: .tapered, thickness: thickness, material: material, taper: taper)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["ftl"]!.translate(x: -thickness))
            node.eulerAngles = V3(x: 0, y: Math.degToRad(degrees: 90), z: 0)
            node.name = "tab-lt"
            nodes.append(node)
        case .drive:
            let shape = genShape(len: len, width: inner["btl"]!.z.distance(to: inner["ftl"]!.z), type: .drive, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-lt"
            node.localTranslate(by: inner["btl"]!.translate(x: -thickness * 3).translate(z: inner["btl"]!.z.distance(to: inner["ftl"]!.z) / 2))
            node.eulerAngles = V3(x: 0, y: 0, z: 0)
            nodes.append(node)
        case .slock:
            let shape = genShape(len: taper, width: inner["btl"]!.z.distance(to: inner["ftl"]!.z) - thickness, type: .slock, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-lt"
            node.localTranslate(by: inner["btl"]!.translate(z: inner["btl"]!.z.distance(to: inner["ftl"]!.z) / 2).translate(x: -thickness * 2))
            node.eulerAngles = V3(x: 0, y: 0, z: 0)
            nodes.append(node)
        case .foldIn:
            let shape = genShape(len: len, width: inner["btl"]!.z.distance(to: inner["ftl"]!.z), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["btl"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: -90), y: Math.degToRad(degrees: -90), z: 0)
            node.name = "tab-lt"
            nodes.append(node)
        case .foldOut:
            let shape = genShape(len: len, width: inner["btl"]!.x.distance(to: inner["btr"]!.x), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["btl"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: 90), y: Math.degToRad(degrees: -90), z: 0)
            node.name = "tab-lt"
            nodes.append(node)
        }
        len = (tabs.left.bottom.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.left.bottom.getType() {
        case .none: break
        case .straight:
            let shape = genShape(len: len, width: inner["bbl"]!.z.distance(to: inner["fbl"]!.z), type: .straight, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["bbl"]!.translate(z: inner["bbl"]!.z.distance(to: inner["fbl"]!.z) / 2).translate(y: -len).translate(x: -thickness * 2))
            node.eulerAngles = V3(x: 0, y: 0, z: 0)
            node.name = "tab-lb"
            nodes.append(node)
        case .tapered:
            let shape = genShape(len: len, width: inner["bbl"]!.z.distance(to: inner["fbl"]!.z), type: .tapered, thickness: thickness, material: material, taper: taper)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["fbl"]!.translate(x: -thickness))
            node.eulerAngles = V3(x: Math.degToRad(degrees: 180), y: Math.degToRad(degrees: 90), z: 0)
            node.name = "tab-lb"
            nodes.append(node)
        case .drive:
            let shape = genShape(len: len, width: inner["bbl"]!.z.distance(to: inner["fbl"]!.z), type: .drive, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-lb"
            node.localTranslate(by: inner["bbl"]!.translate(z: inner["bbl"]!.z.distance(to: inner["fbl"]!.z) / 2))
            node.eulerAngles = V3(x: 0, y: 0, z: Math.degToRad(degrees: 180))
            nodes.append(node)
        case .slock:
            let shape = genShape(len: taper, width: inner["bbl"]!.z.distance(to: inner["fbl"]!.z) - thickness, type: .slock, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-lb"
            node.localTranslate(by: inner["bbl"]!.translate(z: inner["bbl"]!.z.distance(to: inner["fbl"]!.z) / 2).translate(y: -taper).translate(x: -thickness * 2))
            node.eulerAngles = V3(x: 0, y: 0, z: 0)
            nodes.append(node)
        case .foldIn:
            let shape = genShape(len: len, width: inner["bbl"]!.z.distance(to: inner["fbl"]!.z), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["bbl"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: -90), y: Math.degToRad(degrees: -90), z: 0)
            node.name = "tab-lb"
            nodes.append(node)
        case .foldOut:
            let shape = genShape(len: len, width: inner["bbl"]!.z.distance(to: inner["fbl"]!.z), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["bbl"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: 90), y: Math.degToRad(degrees: -90), z: 0)
            node.name = "tab-lb"
            nodes.append(node)
        }
        len = (tabs.left.left.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.left.left.getType() {
            case .slock, .foldIn:
                var v = [
                    outer["btl"]!,
                    outer["btl"]!.translate(x: taper),
                    outer["bbl"]!.translate(x: taper),
                    outer["bbl"]!,
                ]
                v.append(contentsOf: [
                    v[0].translate(z: -thickness),
                    v[1].translate(z: -thickness),
                    v[2].translate(z: -thickness),
                    v[3].translate(z: -thickness),
                ])
                let quads = [
                    Quad(v[4], v[5], v[6], v[7]),
                    Quad(v[0], v[4], v[7], v[3]),
                    Quad(v[1], v[5], v[4], v[0]),
                    Quad(v[5], v[1], v[2], v[6]),
                    Quad(v[3], v[7], v[6], v[2])
                ]
                let geo = GeometryBuilder(quads: quads).getGeometry()
                geo.firstMaterial = material
                let node = SCNNode(geometry: geo)
                node.name = "tab-ll"
                nodes.append(node)
            default: break
        }
        len = (tabs.left.right.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.left.right.getType() {
            case .slock, .foldIn:
                var v = [
                    outer["ftl"]!.translate(x: taper),
                    outer["ftl"]!,
                    outer["fbl"]!,
                    outer["fbl"]!.translate(x: taper),
                ]
                v.append(contentsOf: [
                    v[0].translate(z: thickness),
                    v[1].translate(z: thickness),
                    v[2].translate(z: thickness),
                    v[3].translate(z: thickness),
                ])
                let quads = [
                    Quad(v[4], v[5], v[6], v[7]),
                    Quad(v[0], v[4], v[7], v[3]),
                    Quad(v[1], v[5], v[4], v[0]),
                    Quad(v[5], v[1], v[2], v[6]),
                    Quad(v[3], v[7], v[6], v[2])
                ]
                let geo = GeometryBuilder(quads: quads).getGeometry()
                geo.firstMaterial = material
                let node = SCNNode(geometry: geo)
                node.name = "tab-lr"
                nodes.append(node)
            default: break
        }
        
        // Right //////////////////////////////////////////////////
        len = (tabs.right.top.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.right.top.getType() {
        case .none: break
        case .straight:
            let shape = genShape(len: len, width: inner["btl"]!.z.distance(to: inner["ftl"]!.z), type: .straight, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["btr"]!.translate(z: inner["btl"]!.distance(inner["ftl"]!) / 2))
            node.eulerAngles = V3(x: 0, y: 0, z: 0)
            node.name = "tab-rt"
            nodes.append(node)
        case .tapered:
            let shape = genShape(len: len, width: inner["btl"]!.z.distance(to: inner["ftl"]!.z), type: .tapered, thickness: thickness, material: material, taper: taper)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["ftr"]!)
            node.eulerAngles = V3(x: 0, y: Math.degToRad(degrees: 90), z: 0)
            node.name = "tab-rt"
            nodes.append(node)
        case .drive:
            let shape = genShape(len: len, width: inner["btl"]!.z.distance(to: inner["ftl"]!.z), type: .drive, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-rt"
            node.localTranslate(by: inner["btr"]!.translate(z: inner["btl"]!.z.distance(to: inner["ftl"]!.z) / 2))
            node.eulerAngles = V3(x: 0, y: 0, z: 0)
            nodes.append(node)
        case .slock:
            let shape = genShape(len: taper, width: inner["btl"]!.z.distance(to: inner["ftl"]!.z) - thickness, type: .slock, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-rt"
            node.localTranslate(by: inner["btr"]!.translate(z: inner["btl"]!.z.distance(to: inner["ftl"]!.z) / 2).translate(x: -thickness))
            node.eulerAngles = V3(x: 0, y: 0, z: 0)
            nodes.append(node)
        case .foldIn:
            let shape = genShape(len: len, width: inner["btl"]!.z.distance(to: inner["ftl"]!.z), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["btr"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: 90), y: Math.degToRad(degrees: -90), z: 0)
            node.name = "tab-rt"
            nodes.append(node)
        case .foldOut:
            let shape = genShape(len: len, width: inner["btr"]!.z.distance(to: inner["ftr"]!.z), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["btr"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: -90), y: Math.degToRad(degrees: -90), z: 0)
            node.name = "tab-rt"
            nodes.append(node)
        }
        len = (tabs.right.bottom.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.right.bottom.getType() {
        case .none: break
        case .straight:
            let shape = genShape(len: len, width: inner["bbl"]!.z.distance(to: inner["fbl"]!.z), type: .straight, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["bbr"]!.translate(z: inner["bbl"]!.z.distance(to: inner["fbl"]!.z) / 2).translate(y: -len))
            node.eulerAngles = V3(x: 0, y: 0, z: 0)
            node.name = "tab-rb"
            nodes.append(node)
        case .tapered:
            let shape = genShape(len: len, width: inner["bbl"]!.z.distance(to: inner["fbl"]!.z), type: .tapered, thickness: thickness, material: material, taper: taper)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["fbr"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: 180), y: Math.degToRad(degrees: 90), z: 0)
            node.name = "tab-rb"
            nodes.append(node)
        case .drive:
            let shape = genShape(len: len, width: inner["bbl"]!.z.distance(to: inner["fbl"]!.z), type: .drive, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-rb"
            node.localTranslate(by: inner["bbr"]!.translate(z: inner["bbl"]!.z.distance(to: inner["fbl"]!.z) / 2).translate(x: thickness * 3))
            node.eulerAngles = V3(x: 0, y: 0, z: Math.degToRad(degrees: 180))
            nodes.append(node)
        case .slock:
            let shape = genShape(len: taper, width: inner["bbl"]!.z.distance(to: inner["fbl"]!.z) - thickness, type: .slock, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.name = "tab-rb"
            node.localTranslate(by: inner["bbr"]!.translate(z: inner["bbl"]!.z.distance(to: inner["fbl"]!.z) / 2).translate(y: -taper).translate(x: -thickness))
            node.eulerAngles = V3(x: 0, y: 0, z: 0)
            nodes.append(node)
        case .foldIn:
            let shape = genShape(len: len, width: inner["bbl"]!.z.distance(to: inner["fbl"]!.z), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["bbr"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: 90), y: Math.degToRad(degrees: -90), z: 0)
            node.name = "tab-rb"
            nodes.append(node)
        case .foldOut:
            let shape = genShape(len: len, width: inner["bbl"]!.z.distance(to: inner["fbr"]!.z), type: .tapered, thickness: thickness, material: material)
            let node = SCNNode(geometry: shape)
            node.localTranslate(by: inner["bbr"]!)
            node.eulerAngles = V3(x: Math.degToRad(degrees: -90), y: Math.degToRad(degrees: -90), z: 0)
            node.name = "tab-rb"
            nodes.append(node)
        }
        len = (tabs.right.left.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.right.left.getType() {
            case .slock, .foldIn:
                var v = [
                    outer["ftr"]!,
                    outer["ftr"]!.translate(x: -taper),
                    outer["fbr"]!.translate(x: -taper),
                    outer["fbr"]!,
                ]
                v.append(contentsOf: [
                    v[0].translate(z: thickness),
                    v[1].translate(z: thickness),
                    v[2].translate(z: thickness),
                    v[3].translate(z: thickness),
                ])
                let quads = [
                    Quad(v[4], v[5], v[6], v[7]),
                    Quad(v[0], v[4], v[7], v[3]),
                    Quad(v[1], v[5], v[4], v[0]),
                    Quad(v[5], v[1], v[2], v[6]),
                    Quad(v[3], v[7], v[6], v[2])
                ]
                let geo = GeometryBuilder(quads: quads).getGeometry()
                geo.firstMaterial = material
                let node = SCNNode(geometry: geo)
                node.name = "tab-rl"
                nodes.append(node)
            default: break
        }
        len = (tabs.right.right.getLength().rawValue * (isAR ? 0.0254 : 1)).f
        switch tabs.right.right.getType() {
            case .slock, .foldIn:
                var v = [
                    outer["btr"]!.translate(x: -taper),
                    outer["btr"]!,
                    outer["bbr"]!,
                    outer["bbr"]!.translate(x: -taper),
                ]
                v.append(contentsOf: [
                    v[0].translate(z: -thickness),
                    v[1].translate(z: -thickness),
                    v[2].translate(z: -thickness),
                    v[3].translate(z: -thickness),
                ])
                let quads = [
                    Quad(v[4], v[5], v[6], v[7]),
                    Quad(v[0], v[4], v[7], v[3]),
                    Quad(v[1], v[5], v[4], v[0]),
                    Quad(v[5], v[1], v[2], v[6]),
                    Quad(v[3], v[7], v[6], v[2])
                ]
                let geo = GeometryBuilder(quads: quads).getGeometry()
                geo.firstMaterial = material
                let node = SCNNode(geometry: geo)
                node.name = "tab-rr"
                nodes.append(node)
            default: break
        }
        return nodes
    }

    enum TabFacing {
        case plusX, minusX, plusZ, minusZ
    }

    static func getMeasurements(_ v: [String: V3], _ rT: F) -> [String: Fraction] {
        var lol: [String: Fraction] = [:]
        lol["front-bounding-l"] = v["fbl"]!.zero(.x).distance(v["ftl"]!.zero(.x)).toFraction(rT)
        lol["front-tabs-t"] = Fraction(min(v["fbl"]!.x, v["ftl"]!.x).distance(to: max(v["fbr"]!.x, v["ftr"]!.x)))
        lol["front-bounding-el"] = v["ftl"]!.zero(.y, .z).distance(v["fbl"]!.zero(.y, .z)).isLTZ()?.toFraction(rT)
        lol["front-bounding-er"] = v["ftr"]!.zero(.y, .z).distance(v["fbr"]!.zero(.y, .z)).isLTZ()?.toFraction(rT)
        lol["front-duct-t"] = v["ftl"]!.distance(v["ftr"]!).toFraction(rT)
        lol["front-duct-b"] = v["fbl"]!.distance(v["fbr"]!).toFraction(rT)
        lol["front-duct-l"] = v["fbl"]!.distance(v["ftl"]!).toFraction(rT)
        lol["front-duct-r"] = v["fbr"]!.distance(v["ftr"]!).toFraction(rT)
        lol["back-bounding-l"] = v["bbl"]!.zero(.x).distance(v["btl"]!.zero(.x)).isLTZ()?.toFraction(rT)
        lol["back-tabs-t"] = lol["front-tabs-t"]!
        lol["back-bounding-el"] = v["bbr"]!.zero(.y, .z).distance(v["btr"]!.zero(.y, .z)).isLTZ()?.toFraction(rT)
        lol["back-bounding-er"] = v["bbl"]!.zero(.y, .z).distance(v["btl"]!.zero(.y, .z)).isLTZ()?.toFraction(rT)
        lol["back-duct-t"] = v["btr"]!.distance(v["btl"]!).toFraction(rT)
        lol["back-duct-b"] = v["bbr"]!.distance(v["bbl"]!).toFraction(rT)
        lol["back-duct-l"] = v["bbr"]!.distance(v["btr"]!).toFraction(rT)
        lol["back-duct-r"] = v["bbl"]!.distance(v["btl"]!).toFraction(rT)
        lol["left-bounding-l"] = v["bbl"]!.zero(.z).distance(v["btl"]!.zero(.z)).isLTZ()?.toFraction(rT)
        lol["left-tabs-t"] = Fraction(min(v["bbl"]!.z, v["btl"]!.z).distance(to: max(v["fbr"]!.z, v["ftr"]!.z)))
        lol["left-bounding-el"] = v["btl"]!.zero(.y, .x).distance(v["bbl"]!.zero(.y, .x)).isLTZ()?.toFraction(rT)
        lol["left-bounding-er"] = v["ftl"]!.zero(.y, .x).distance(v["fbl"]!.zero(.y, .x)).isLTZ()?.toFraction(rT)
        lol["left-duct-t"] = v["btl"]!.distance(v["ftl"]!).toFraction(rT)
        lol["left-duct-b"] = v["bbl"]!.distance(v["fbl"]!).toFraction(rT)
        lol["left-duct-l"] = v["bbl"]!.distance(v["btl"]!).toFraction(rT)
        lol["left-duct-r"] = v["fbl"]!.distance(v["ftl"]!).toFraction(rT)
        lol["right-bounding-l"] = v["bbr"]!.zero(.z).distance(v["btr"]!.zero(.z)).isLTZ()?.toFraction(rT)
        lol["right-tabs-t"] = lol["left-tabs-t"]!
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

#if DEBUG
struct Duct_Previews: PreviewProvider {
    static var previews: some View {
        let al = AppLogic()
        al.tabs.right.top.type = TabType.foldOut.rawValue
        al.tabs.right.top.length = TabLength.inch.rawValue
        al.tabs.right.bottom.type = TabType.foldOut.rawValue
        al.tabs.right.bottom.length = TabLength.inch.rawValue
        al.tabs.right.left.type = TabType.foldIn.rawValue
        al.tabs.right.left.length = TabLength.inch.rawValue
        al.tabs.right.right.type = TabType.foldIn.rawValue
        al.tabs.right.right.length = TabLength.inch.rawValue
        al.threeDViewHelpersShown = true
        return ContentView().environmentObject(al)
    }
}
#endif
