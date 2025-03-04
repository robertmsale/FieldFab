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
import RxSwift

extension DuctTransition {
    class ModuleViewModel {
        enum TranslationMode: Int, CaseIterable, Identifiable, CustomStringConvertible {
            case xz, y
            var id: Int { rawValue }
            
            var description: String {
                switch self {
                case .xz: return "xz"
                case .y: return "y"
                }
            }
        }
        enum FlowDirection: Int, CaseIterable, Identifiable, CustomStringConvertible {
            case up, down, left, right
            var id: Int { rawValue }
            
            var description: String {
                switch self {
                case .up: return "Up"
                case .down: return "Down"
                case .left: return "Left"
                case .right: return "Right"
                }
            }
        }
        var renderChanged = PublishSubject<Bool>()
        var textureChanged = PublishSubject<Bool>()
        var measurementsChanged = PublishSubject<Bool>()
        var tabsChanged = PublishSubject<Bool>()
        var energySaverChanged = PublishSubject<Bool>()
        var helpersChanged = PublishSubject<Bool>()
        var arViewReset = PublishSubject<Bool>()
        var drawerChanged = PublishSubject<Bool>()
        var bgChanged = PublishSubject<Bool>()
        var flowDirection = PublishSubject<FlowDirection>()
        var translationMode = PublishSubject<TranslationMode>()
        var cameraHelpShown = PublishSubject<Bool>()
        var generalHelpShown = PublishSubject<Bool>()
        var arCameraHelpShown = PublishSubject<Bool>()
        var settingsViewShown = PublishSubject<Bool>()
    }
    final class ModuleState: MockableStateObject {
        typealias FlowDirection = DuctTransition.ModuleViewModel.FlowDirection
        typealias TranslationMode = DuctTransition.ModuleViewModel.TranslationMode
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
        @Published var AirflowDataHelpShown = false
        @Published var arCameraHelpShown = false
        @Published var settingsViewShown = false
        @Published var airflowDataHelpShown = false
        @Published var newSessionShown = false
        @Published var newJobShown = false
        @Published var newPresetShown = false
        
        
        var TDViewNeedsReset: Bool {
            renderChanged || bgChanged || textureChanged || measurementsChanged || tabsChanged || energySaverChanged || helpersChanged || drawerChanged
        }
        var ARViewNeedsReset: Bool {
            renderChanged || textureChanged || measurementsChanged || tabsChanged || energySaverChanged || helpersChanged || arViewReset
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
        @Published var jobData: [JobData] = {
            guard let data = try? Disk.retrieve("jobData.json", from: .applicationSupport, as: [JobData].self) else {
                return []
            }
            return data
        }() {
            didSet {
                do {
                    try Disk.save(jobData, to: .applicationSupport, as: "jobData.json")
                } catch {}
            }
        }
        
        @Published var currentDuct: DuctData? = nil
    }
}
