//
//  Line.swift
//  FieldFab
//
//  Created by Robert Sale on 9/19/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

struct Line2 {
    public var start: Vector2
    public var end: Vector2
    public var len: CGFloat {
        get { self.start.distance(to: self.end) }
    }
    public var center: Vector2 {
        get {
            var c = self.start + self.end
            c.addScalar(scale: 0.5)
            return c
        }
    }
}

struct Line3 {
    public var start: Vector3
    public var end: Vector3
    public var len: CGFloat {
        get { self.start.distance(to: self.end) }
    }
    public var center: Vector3 {
        get {
            var c = self.start + self.end
            c.addScalar(scale: 0.5)
            return c
        }
    }
}
