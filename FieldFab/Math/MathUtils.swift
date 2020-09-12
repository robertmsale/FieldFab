//
//  MathUtils.swift
//  FieldFab
//
//  Created by Robert Sale on 9/7/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

class MathUtils {
    static var DEGRAD: CGFloat = CGFloat.pi / 180
    static var RADDEG: CGFloat = 180 / CGFloat.pi
    
    static func clamp( value v: CGFloat, min mi: CGFloat, max ma: CGFloat) -> CGFloat {
        return max( mi, min( ma, v ))
    }
    
    static func euclideanModulo(_ n: CGFloat, _ m: CGFloat) -> CGFloat {
        return ( (n.truncatingRemainder(dividingBy: m)) + m ).truncatingRemainder(dividingBy: m)
    }
    
    static func mapLinear(x: CGFloat, a1: CGFloat, a2: CGFloat, b1: CGFloat, b2: CGFloat ) -> CGFloat {
        return b1 + ( x - a1 ) * ( b2 - b1 ) / ( a2 - a1 )
    }
    
    static func lerp(x: CGFloat, y: CGFloat, t: CGFloat) -> CGFloat {
        return ( 1.0 - t ) * x + t * y
    }
    
    static func smoothstep(x: CGFloat, min mi: CGFloat, max ma: CGFloat) -> CGFloat {
        if x <= mi { return 0.0 }
        if x >= ma { return 1.0 }
        let dx = ( x - mi ) / ( ma - mi )
        return dx * dx * ( 3.0 - 2.0 * dx )
    }
    
    static func smootherstep(x: CGFloat, min mi: CGFloat, max ma: CGFloat) -> CGFloat {
        if x <= mi { return 0.0 }
        if x >= ma { return 1.0 }
        let dx = ( x - mi ) / ( ma - mi )
        return dx * dx * dx * ( dx * ( x * 6.0 - 15.0 ) + 10.0 )
    }
    
    static func floor(x: CGFloat) -> CGFloat {
        return x - x.truncatingRemainder(dividingBy: 1.0)
    }
    
    static func ceil(x: CGFloat) -> CGFloat {
        return x + (1.0 - x.truncatingRemainder(dividingBy: 1.0))
    }
    
    static func degToRad(degrees d: CGFloat) -> CGFloat {
        return d * MathUtils.DEGRAD
    }
    
    static func radToDeg(rads r: CGFloat) -> CGFloat {
        return r * MathUtils.RADDEG
    }
    
    static func reduce(data: [CGFloat], completionHandler: (_ a: CGFloat, _ b: CGFloat) -> CGFloat) -> CGFloat {
        var reduced: CGFloat = 0.0
        for i in 0...data.count - 1 {
            if i == data.count - 1 {
                break
            }
            reduced = completionHandler(data[i], data[i + 1])
        }
        return reduced
    }
    
    static func setQuaternionFromProperEuler() {
        
    }
}
