//
//  DuctTransitionsModule.swift
//  FieldFab
//
//  Created by Robert Sale on 12/29/22.
//  Copyright © 2022 Robert Sale. All rights reserved.
//

import Foundation
import SwiftUI
import Disk
#if DEBUG
@_exported import HotSwiftUI
#endif

extension DuctTransition {
    struct ModuleToolbar: ViewModifier {
        @Binding var cameraHelpShown: Bool
        @Binding var arCameraHelpShown: Bool
        @Binding var generalHelpShown: Bool
        @Binding var settingsViewShown: Bool
        @State var menuShown = false
        func body(content: Content) -> some View {
            content
                .toolbar {
//                    Button(action: {Task { settingsViewShown = true }}) {
//                        Image(systemName: "gear")
//                    }
                    Button(action: {Task { menuShown = true }}) {
                        Image(systemName: "questionmark.circle")
                    }
                    .confirmationDialog("Help", isPresented: $menuShown, actions: {
                        Button("3D View Help", role: .none, action: {Task {cameraHelpShown = true}})
                        Button("AR View Help", role: .none, action: {Task {arCameraHelpShown = true}})
                        Button("General Help", role: .none, action: {Task {generalHelpShown = true}})
                    })
                }
        }
    }
}

extension DuctTransition {
    struct SessionPreset: Identifiable {
        let description: String
        var id: String { description }
        let duct: DuctTransition.DuctData
    }
    struct ModuleView: ModularView {
        static let loadMethod: ModuleLoadMethod = FieldFabApp.loadMethod
        struct InitArgs {
            var newSessionShown: Bool = false
            var newSessionName: String = ""
            var newSessionUnits: DuctTransition.MeasurementUnit = .inch
            var path: Binding<NavigationPath> = Binding.blank(NavigationPath())
            var createEnvironmentObject: Bool = false
        }
        @ViewBuilder
        static func loadModule(_ args: InitArgs) -> some View {
            switch loadMethod {
            case .development:
                let view = Self(
                    newSessionShown: args.newSessionShown,
                    newSessionName: args.newSessionName,
                    newSessionUnits: args.newSessionUnits
//                    path: args.path
                )
                if args.createEnvironmentObject {
                    view.environmentObject(DuctTransition.ModuleState())
                }
                view
            case .production:
                Self()
            }
        }
        
        @EnvironmentObject var state: DuctTransition.ModuleState
        @EnvironmentObject var appState: AppState
        @State var newSessionShown: Bool = false
        @State var newSessionName: String = ""
        @State var newSessionUnits: DuctTransition.MeasurementUnit = .inch
        
        @State var editShown: Bool = false
        @State var editID: UUID? = nil
        @State var editString: String = ""
        
        static var sessionPresets: [SessionPreset] {[
            .init(description: "17½x20 Box", duct: DuctData(measurements: [17.5, 20, 12, 0, 0, 17.5, 20], unit: .inch, name: "17½x20 Box")),
            .init(description: "20x20 Box", duct: DuctData(measurements: [20, 20, 12, 0, 0, 20, 20], unit: .inch, name: "20x20 Box")),
            .init(description: "20x25 Box", duct: DuctData(measurements: [20, 25, 12, 0, 0, 20, 25], unit: .inch, name: "20x25 Box")),
            .init(description: "17½x20 -> 20x20", duct: DuctData(measurements: [16, 20, 12, 0, 0, 16, 20], unit: .inch, name: "17½x20 -> 20x20")),
            .init(description: "20x20 -> 20x25", duct: DuctData(measurements: [20, 20, 12, 0, 0, 20, 20], unit: .inch, name: "20x20 -> 20x25")),
        ]}
        
        var body: some View {
            VStack {
                Form {
                    Section(content: {
                        ForEach($state.ductData) { d in
                            VStack {
                                NavigationLink(value: d.wrappedValue) {
                                    Text(d.name.wrappedValue)
                                }
                                Text("Created On \(d.date.wrappedValue.formatted(date: .numeric, time: .standard))")
                            }
                            .swipeActions(content: {
                                Button(action: {
                                    state.ductData.removeAll(where: { $0.id == d.id })
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                                Button(action: {
                                    editID = d.id
                                    editShown = true
                                }) {
                                    Label("Rename", systemImage: "pencil")
                                }
                                
                            })
                            .alert(
                                String("Rename Session"),
                                isPresented: $editShown,
                                actions: {
                                    TextField("New Name", text: $editString)
                                    Button(action: {
                                        if let idx = state.ductData.firstIndex(where: {$0.id == editID}) {
                                            state.ductData[idx].name = editString
                                        }
                                        editString = ""
                                        editID = nil
                                        editShown = false
                                    }) {
                                        Text("Save")
                                    }
                                })
                        }
                    }, header: {Text("Sessions")}, footer: {Text("Swipe left to edit name or delete")})
                    Section(content: {
                        ForEach(Self.sessionPresets) { p in
                            Button(action: {
                                Task {
                                    let nd = DuctData(measurements: p.duct.measurements, unit: p.duct.unit, name: p.duct.name)
                                    state.ductData.append(nd)
                                    appState.navPath.append(nd)
                                }
                            }) {
                                Text(p.description)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }, header: {Text("Presets")}, footer: {Text("Selecting a preset adds it to your list of sessions")})
                }
                Spacer()
                Button(action: {Task {newSessionShown = true}}) {
                    Text("Create New Session").font(.title2)
                }.padding(.vertical)
            }
            .navigationDestination(for: DuctTransition.DuctData.self) { data in
                DuctTransition.Workshop(ductwork: data)
                //                .modifier(DuctTransitionModuleToolbar(cameraHelpShown: $state.cameraHelpShown, arCameraHelpShown: $state.arCameraHelpShown, generalHelpShown: $state.generalHelpShown))
            }
            .sheet(isPresented: $state.cameraHelpShown, content: {DuctTransition.CameraHelpView()})
            .sheet(isPresented: $state.generalHelpShown, content: {DuctTransition.GeneralHelpView(shown: $state.generalHelpShown)})
            .sheet(isPresented: $state.arCameraHelpShown, content: {DuctTransition.ARCameraHelpView()})
            .sheet(isPresented: $state.settingsViewShown, content: {DuctTransition.SettingsView(shown: $state.settingsViewShown)})
            .sheet(isPresented: $newSessionShown) {
                Form {
                    VStack {
                        TextField("Session Name", text: $newSessionName)
                        if newSessionName == "" {
                            Text("Name cannot be empty").font(.footnote).foregroundColor(Color.red)
                        }
                    }
                    Picker("Units", selection: $newSessionUnits) {
                        ForEach(DuctTransition.MeasurementUnit.allCases) { m in
                            Text(m.localizedString).tag(m)
                        }
                    }
                    Button(action: {
                        Task {
                            state.ductData.append(DuctTransition.DuctData(unit: newSessionUnits, name: newSessionName))
                            newSessionShown = false
                        }
                    }) {
                        Text("Create")
                    }.disabled(newSessionName == "")
                }
            }
            .modifier(DuctTransition.ModuleToolbar(cameraHelpShown: $state.cameraHelpShown, arCameraHelpShown: $state.arCameraHelpShown, generalHelpShown: $state.generalHelpShown, settingsViewShown: $state.settingsViewShown))
            .navigationTitle("Sessions")
            #if DEBUG
            .eraseToAnyView()
            #endif
        }
        #if DEBUG
        @ObservedObject var iO = injectionObserver
        #endif
    }
}

