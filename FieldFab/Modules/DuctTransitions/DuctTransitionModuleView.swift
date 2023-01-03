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
                    Button(action: {Task { settingsViewShown = true }}) {
                        Image(systemName: "gear")
                    }
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
                var view = Self(
                    newSessionShown: args.newSessionShown,
                    newSessionName: args.newSessionName,
                    newSessionUnits: args.newSessionUnits,
                    path: args.path
                )
                if args.createEnvironmentObject {
                    view.environmentObject(DuctTransition.ModuleState())
                }
                view
            case .production:
                Self(path: args.path)
            }
        }
        
        @EnvironmentObject var state: DuctTransition.ModuleState
        @State var newSessionShown: Bool = false
        @State var newSessionName: String = ""
        @State var newSessionUnits: DuctTransition.MeasurementUnit = .inch
        
        @State var editShown: Bool = false
        @State var editID: UUID? = nil
        @State var editString: String = ""
        
        @Binding var path: NavigationPath
        
        var body: some View {
            VStack {
                List($state.ductData, editActions: .move) { d in
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
                Spacer()
                Button(action: {Task {newSessionShown = true}}) {
                    Text("Create New Session").font(.title2)
                }.padding(.top, 5)
            }
            .navigationDestination(for: DuctTransition.DuctData.self) { data in
                DuctTransition.Workshop(ductwork: data)
                //                .modifier(DuctTransitionModuleToolbar(cameraHelpShown: $state.cameraHelpShown, arCameraHelpShown: $state.arCameraHelpShown, generalHelpShown: $state.generalHelpShown))
            }
            .sheet(isPresented: $state.cameraHelpShown, content: {DuctTransition.CameraHelpView()})
            .sheet(isPresented: $state.generalHelpShown, content: {DuctTransition.GeneralHelpView(shown: $state.generalHelpShown)})
            .sheet(isPresented: $state.arCameraHelpShown, content: {DuctTransition.ARCameraHelpView()})
            .sheet(isPresented: $state.settingsViewShown, content: {DuctTransition.SettingsView()})
            .sheet(isPresented: $newSessionShown) {
                Form {
                    TextField("Session Name", text: $newSessionName)
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
                    }
                }
            }
            .modifier(DuctTransition.ModuleToolbar(cameraHelpShown: $state.cameraHelpShown, arCameraHelpShown: $state.arCameraHelpShown, generalHelpShown: $state.generalHelpShown, settingsViewShown: $state.settingsViewShown))
        }
    }
}

#if DEBUG
struct DuctTransitionsModule_Preview: PreviewProvider {
    struct Preview: View {
        @State var path = NavigationPath()
        var state = DuctTransition.ModuleState()
        var body: some View {
            NavigationStack(path: $path) {
                DuctTransition.ModuleView(path: $path)
                    .navigationTitle("Duct Transition Builder")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .environmentObject(state)
            .onAppear {
                state.ductData = Array(repeating: DuctTransition.DuctData(name: "Derp"), count: 16)
            }
        }
    }
    static var previews: some View {
        Preview()
    }
}
#endif
