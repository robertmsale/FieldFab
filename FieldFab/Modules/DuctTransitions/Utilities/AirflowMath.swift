//
//  Math.swift
//  FieldFab
//
//  Created by Robert Sale on 3/1/25.
//  Copyright © 2025 Robert Sale. All rights reserved.
//

import Foundation
import SwiftUI

/// Calculates the pressure drop across a duct transition in inches of water column (inWC).
/// - Parameters:
///   - W1: Inlet width in inches
///   - H1: Inlet height in inches
///   - W2: Outlet width in inches
///   - H2: Outlet height in inches
///   - X: Horizontal offset in inches
///   - Y: Vertical offset in inches
///   - L: Transition length in inches
///   - Q: Airflow rate in cubic feet per minute (CFM)
/// - Returns: Pressure drop in inches of water column (inWC)
func pressureDrop(W1: Double, H1: Double, W2: Double, H2: Double, X: Double, Y: Double, L: Double, Q: Double) -> Double {
    // Calculate areas in square feet
    let A1 = (W1 * H1) / 144.0  // Inlet area (ft²)
    let A2 = (W2 * H2) / 144.0  // Outlet area (ft²)
    
    // Calculate velocities in ft/min
    let V1 = Q / A1  // Inlet velocity
    let V2 = Q / A2  // Outlet velocity
    
    // Calculate velocity pressures in inWC
    let PV1 = pow(V1 / 4005.0, 2)  // Inlet velocity pressure
    let PV2 = pow(V2 / 4005.0, 2)  // Outlet velocity pressure
    
    // Size change pressure drop
    let deltaP_size: Double
    if A2 > A1 {
        // Expansion: K_size = 0.5 * (1 - A1/A2)^2, applied to PV1
        let K_size = 0.5 * pow(1 - A1 / A2, 2)
        deltaP_size = K_size * PV1
    } else if A2 < A1 {
        // Contraction: K_size = 0.2 (typical for gradual), applied to PV2
        let K_size = 0.2
        deltaP_size = K_size * PV2
    } else {
        deltaP_size = 0.0  // No size change
    }
    
    // Offset pressure drop
    let theta_X = atan(X / L) * (180.0 / Double.pi)  // Horizontal angle (degrees)
    let theta_Y = atan(Y / L) * (180.0 / Double.pi)  // Vertical angle (degrees)
    let theta = sqrt(theta_X * theta_X + theta_Y * theta_Y)  // Effective angle
    let K_offset: Double
    if theta < 45.0 { // Standard K Offset
        K_offset = 0.3 * (theta / 90.0)
    } else { // Extreme K Offsets approaching 90 degrees
        let lerp = 1.2 * (theta / 90.0)
        K_offset = lerp
    }
    let deltaP_offset = K_offset * PV1  // Based on inlet velocity pressure
    
    // Total pressure drop
    return deltaP_size + deltaP_offset
}

#Preview {
    Text(pressureDrop(W1: 12.0, H1: 12.0, W2: 12.0, H2: 12.0, X: 48, Y: 0.0, L: 6.0, Q: 2000.0).string)
}
