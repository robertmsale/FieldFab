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

struct AppView: View {
    enum AvailableModules: Int, CaseIterable, Hashable, Identifiable, Codable {
        case ductTransition, ductFittings
        var id: Int { self.rawValue }
        var txt: String {
            switch self {
            case .ductTransition: return "Build Duct Transition"
            case .ductFittings: return "Duct Fittings"
            }
        }
        var img: String {
            switch self {
            case .ductTransition: return "hammer"
            case .ductFittings: return "doc.text"
            }
        }
    }
    @EnvironmentObject var state: AppState
    @State var splitViewMode: NavigationSplitViewVisibility = .detailOnly
    @State var currentModule: AvailableModules? = nil
    @State var path = NavigationPath()
    var modules = AvailableModules.allCases
    
    var body: some View {
        NavigationSplitView(columnVisibility: $splitViewMode, sidebar: {
            List(modules, selection: $currentModule) { mod in
                NavigationLink(value: mod) {
                    Label(mod.txt, systemImage: mod.img)
                }
            }
            .toolbar {
                Button(action: {state.aboutSheetShown = true}) {
                    Text("About")
                }.sheet(isPresented: $state.aboutSheetShown) {
                    AboutView(shown: $state.aboutSheetShown)
                }
            }
            .navigationTitle("FieldFab")
        }, detail: {
            NavigationStack(path: $path) {
                if currentModule == nil {
                    Text("Select an activity")
                } else {
                    switch currentModule {
                    case .ductFittings:
                        Text("Duct Fittings")
                    case .ductTransition:
                        DuctTransition.ModuleView.loadModule(.init(path: $path))
                    default:
                        EmptyView()
                    }
                }
            }
        })
    }
}

#if DEBUG
struct AppView_Preview: PreviewProvider {
    static var previews: some View {
        AppView()
            .previewDisplayName("iPhone 14 Pro Max")
            .previewDevice("iPhone 14 Pro Max")
            .environmentObject(AppState())
        AppView()
            .previewDisplayName("iPad Pro (12.9-inch) (6th generation)")
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
            .environmentObject(AppState())
    }
}
#endif
