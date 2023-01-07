//
//  DuctTransitionModuleState.swift
//  FieldFab
//
//  Created by Robert Sale on 12/29/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import StringFix
import SceneKit
import Disk

extension DuctTransition {
    final class ModuleState: MockableStateObject {
        enum TranslationMode: Int, CaseIterable, Identifiable {
            case xz, y
            var id: Int { rawValue }
            var localizedString: String {
                switch self {
                case .xz: return "xz"
                case .y: return "y"
                }
            }
        }
        enum MockCases {
            case development, production
        }
        static func loadWith(mockState: MockCases) -> ModuleState {
            switch mockState {
            case .development: return ModuleState()
            case .production: return ModuleState()
            }
        }
        
        // Scene Events
        @Published var renderChanged = false
        @Published var textureChanged = false
        @Published var measurementsChanged = false
        @Published var tabsChanged = false
        @Published var energySaverChanged = false
        @Published var helpersChanged = false
        @Published var arViewReset = false
        @Published var drawerChanged = false
        @Published var bgChanged = false
        
        @Published var flowDirection: FlowDirection = .up
        @Published var translationMode: TranslationMode = .xz
        
        @Published var cameraHelpShown = false
        @Published var generalHelpShown = false
        @Published var arCameraHelpShown = false
        @Published var settingsViewShown = false
        
        
        var TDViewneedsReset: Bool {
            renderChanged || bgChanged || textureChanged || measurementsChanged || tabsChanged || energySaverChanged || helpersChanged || drawerChanged
        }
        var ARViewNeedsReset: Bool {
            renderChanged || textureChanged || measurementsChanged || tabsChanged || energySaverChanged || helpersChanged || arViewReset
        }
        enum FlowDirection: Int, CaseIterable, Identifiable {
            case up, down, left, right
            var id: Int { rawValue }
            var localizedString: String {
                switch self {
                case .up: return "Up"
                case .down: return "Down"
                case .left: return "Left"
                case .right: return "Right"
                }
            }
        }
        
        @Published var ductData: [DuctData] = {
            guard let data = try? Disk.retrieve("ductData.json", from: .applicationSupport, as: [DuctData].self) else {
                return []
            }
            return data
        }() {
            didSet {
                do {
                    try Disk.save(ductData, to: .applicationSupport, as: "ductData.json")
                } catch {
                    
                }
            }
        }
        
        @Published var currentDuct: DuctData? = nil
    }
}
