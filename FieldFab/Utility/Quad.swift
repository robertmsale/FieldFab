//
//  Quad.swift
//  FieldFab
//
//  Created by Robert Sale on 9/26/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SceneKit

struct Quad {
    typealias V3 = SCNVector3
    let v0: V3
    let v1: V3
    let v2: V3
    let v3: V3

    init(_ v0: V3, _ v1: V3, _ v2: V3, _ v3: V3) {
        self.v0 = v0
        self.v1 = v1
        self.v2 = v2
        self.v3 = v3
    }
}
