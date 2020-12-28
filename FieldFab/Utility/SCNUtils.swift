//
//  SCNUtils.swift
//  FieldFab
//
//  Created by Robert Sale on 9/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SceneKit
import VectorExtensions

class SCNUtils {
    typealias V3 = SCNVector3
    static func getNodeFromDAE(name: String) -> SCNNode? {
        let rnode = SCNNode()
        let nscene = SCNScene(named: name)

        if let nodeArray = nscene?.rootNode.childNodes {
            for cn in nodeArray {
                rnode.addChildNode(cn)
            }
            return rnode
        }

        print("DAE File not found: \(name)!!")

        return nil
    }

    //    static func getStaticNodeFromDAE(name: String) -> SCNNode? {
    //        if let node = getNodeFromDAE(name: name) {
    //            node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: node, options: [
    //                SCNPhysicsShape
    //            ]))
    //        }
    //    }

    static func getMat(
        texFile: String,
        ureps: Float = 1.0,
        vreps: Float = 1.0,
        directory: String?,
        normalFilename: String?,
        specularFilename: String?) -> SCNMaterial {

        let mat = SCNMaterial()
        mat.diffuse.contents = UIImage(named: texFile)
        if normalFilename != nil { mat.normal.contents = UIImage(named: normalFilename!) }
        if specularFilename != nil { mat.specular.contents = UIImage(named: specularFilename!) }

        repeatMat(mat: mat, wRepeat: ureps, hRepeat: vreps)

        return mat
    }

    static func repeatMat(mat: SCNMaterial, wRepeat: Float, hRepeat: Float) {
        let scale: SCNMatrix4 = SCNMatrix4MakeScale(wRepeat, hRepeat, 1.0)
        mat.diffuse.contentsTransform = scale
        mat.diffuse.wrapS = .repeat
        mat.diffuse.wrapT = .repeat

        mat.normal.wrapS = .repeat
        mat.normal.wrapT = .repeat

        mat.specular.wrapS = .repeat
        mat.specular.wrapT = .repeat
    }

    static func getNormal(_ v0: V3, _ v1: V3, _ v2: V3) -> V3 {
        let edgev0v1 = v1.subbed(v0)
        let edgev1v2 = v2.subbed(v1)

        return edgev0v1.crossed(with: edgev1v2)
    }
}
