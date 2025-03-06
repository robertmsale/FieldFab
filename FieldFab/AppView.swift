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
import Disk

struct AppView: View {
    enum AvailableModules: Int, CaseIterable, Hashable, Identifiable, Codable {
        case ductTransition,
//             ductFittings,
             balancePoint,
             intakeCalc
        var id: Int {
            self.rawValue
        }
        var txt: String {
            switch self {
            case .ductTransition: return "Build Duct Transition"
//            case .ductFittings: return "Duct Fittings"
            case .balancePoint: return "Balance Point Calculator"
            case .intakeCalc: return "Combustion Intake Calculator"
            }
        }
        var img: String {
            switch self {
            case .ductTransition: return "hammer"
//            case .ductFittings: return "doc.text"
            case .balancePoint: return "chart.xyaxis.line"
            case .intakeCalc: return "flame"
            }
        }
    }

    @EnvironmentObject var state: AppState
    @State var splitViewMode: NavigationSplitViewVisibility = .detailOnly
    @State var changeLogShown: Bool = false
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
            Button(action: { changeLogShown = true}) {
                Text("Change Log")
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
//                case .ductFittings:
//                    FittingIndex.ModuleView()
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
            .onAppear {
                guard let data = try? Disk.retrieve("ductData.json", from: .applicationSupport, as: [DuctTransition.DuctData].self) else {
                    return
                }
                let manager = FileManager.default
                var rootDirPath = try! manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                rootDirPath = rootDirPath.appendingPathComponent("Duct Transitions").appendingPathComponent("Old Ducts")
                let i = 0
                for duct in data {
                    let newDuctPath = rootDirPath.appendingPathComponent(duct.name + "\(i)").appendingPathExtension("fieldfabdt")
                    guard let encoded = try? JSONEncoder().encode(duct) else { continue }
                    guard let _ = try? encoded.write(to: newDuctPath) else { continue }
                }
                try! Disk.clear(.applicationSupport)
            }
            .sheet(isPresented: $changeLogShown) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Spacer()
                        Text("Change Log").font(.title)
                        Spacer()
                    }
                    Spacer()
                    Text("• Migrated to hierarchical navigation and storage of duct transitions")
                    Text("• Added optional new UI for iPads")
                    Text("• Added particle physics for observing airflow through the duct transition")
                    Text("• Added pressure drop calculator based on airflow requirements")
                    Text("• With new hierarchical navigation, you can now copy duct transition files as needed.")
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {changeLogShown = false}) {
                            Text("Close")
                        }.tint(.red)
                        Spacer()
                    }
                }.padding()
            }
                #if DEBUG
                .eraseToAnyView()
                #endif
    }
    @ObserveInjection var redraw
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
