//
//  AppView.swift
//  FieldFab
//
//  Created by Robert Sale on 12/19/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI
import SceneKit
import ARKit
import AppReview
#if DEBUG
@_exported import HotSwiftUI
#endif

struct AppView: View {
    enum AvailableModules: Int, CaseIterable, Hashable, Identifiable, Codable {
        case ductTransition,
             ductFittings,
             balancePoint,
             intakeCalc
        var id: Int {
            self.rawValue
        }
        var txt: String {
            switch self {
            case .ductTransition: return "Build Duct Transition"
            case .ductFittings: return "Duct Fittings"
            case .balancePoint: return "Balance Point Calculator"
            case .intakeCalc: return "Combustion Intake Calculator"
            }
        }
        var img: String {
            switch self {
            case .ductTransition: return "hammer"
            case .ductFittings: return "doc.text"
            case .balancePoint: return "chart.xyaxis.line"
            case .intakeCalc: return "flame"
            }
        }
    }

    @EnvironmentObject var state: AppState
    @State var splitViewMode: NavigationSplitViewVisibility = .detailOnly
    var modules = AvailableModules.allCases
    
    @ViewBuilder
    func navList() -> some View {
        List(modules, selection: $state.currentModule) { mod in
            NavigationLink(value: mod) {
                Label(mod.txt, systemImage: mod.img)
            }
        }
        .toolbar {
            Button(action: { state.aboutSheetShown = true }) {
                Text("About")
            }
            .sheet(isPresented: $state.aboutSheetShown) {
                AboutView(shown: $state.aboutSheetShown)
            }
        }
        .navigationTitle("FieldFab")
    }
    
    @ViewBuilder
    func navStack() -> some View {
        NavigationStack(path: $state.navPath) {
            if state.currentModule == nil {
                navList()
            } else {
                switch state.currentModule {
                case .ductFittings:
                    Text("Coming Soon!")
                case .ductTransition:
                    DuctTransition.ModuleView()
                case .balancePoint:
                    BalancePointCalcView()
                case .intakeCalc:
                    IntakeCalculatorModule()
                default:
                    EmptyView()
                }
            }
        }
    }
    
    @ViewBuilder
    func navSplitView() -> some View {
        NavigationSplitView(columnVisibility: $splitViewMode, sidebar: {
                navList()
        }, detail: {
            navStack()
        })
    }

    var body: some View {
        navSplitView()
            .onAppear {
                AppReview.requestIf(days: 5)
            }
                #if DEBUG
                .eraseToAnyView()
                #endif
    }
    #if DEBUG
    @ObservedObject var iO = injectionObserver
    #endif
}

//#if DEBUG
//class AppView_Preview: PreviewProvider {
//    static var previews: some View {
//        AppView()
//                .previewDisplayName("iPhone 14 Pro Max")
//                .previewDevice("iPhone 14 Pro Max")
//                .environmentObject(AppState())
////        AppView()
////            .previewDisplayName("iPad Pro (12.9-inch) (6th generation)")
////            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
////            .environmentObject(AppState())
//    }
//
//    @objc class func injected() {
//        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
//        windowScene?.windows.first?.rootViewController =
//                UIHostingController(rootView: AppView())
//    }
//}
//#endif
