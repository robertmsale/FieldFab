//
//  Line.swift
//  FieldFab
//
//  Created by Robert Sale on 9/19/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit

struct Line2 {
    public var start: CGPoint
    public var end: CGPoint
    public var len: CGFloat {
        get { self.start.distance(self.end) }
    }
    public var center: CGPoint {
        get {
            let c = self.start + self.end
            return c.addScalar(scale: 0.5)
        }
    }
}

struct Line3 {
    public var start: SCNVector3
    public var end: SCNVector3
    public var len: CGFloat {
        get { self.start.distance(self.end) }
    }
    public var center: SCNVector3 {
        get {
            let c = self.start + self.end
            return c.addScalar(scale: 0.5)
        }
    }
}
