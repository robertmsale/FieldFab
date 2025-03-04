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
        @Binding var airflowDataHelpShown: Bool
        @Binding var newSessionShown: Bool?
        @Binding var newJobShown: Bool?
        @Binding var newPresetShown: Bool?
        @State var menuShown = false
        @State var addMenuShown = false
        func body(content: Content) -> some View {
            content
                .toolbar {
                    Button(action: {Task { menuShown = true }}) {
                        Image(systemName: "questionmark.circle")
                    }
                    .confirmationDialog("Help", isPresented: $menuShown) {
                        Button("3D View Help", role: .none, action: {Task {cameraHelpShown = true}})
                        Button("AR View Help", role: .none, action: {Task {arCameraHelpShown = true}})
                        Button("General Help", role: .none, action: {Task {generalHelpShown = true}})
                        Button("Airflow Data Help", role: .none, action: {Task {airflowDataHelpShown = true}})
                    }
                    if newSessionShown != nil || newJobShown != nil {
                        Button(action: {addMenuShown = true}) {
                            Image(systemName: "plus")
                        }
                        .confirmationDialog("New", isPresented: $addMenuShown) {
                            Button("New Session", role: .none, action: {Task {newSessionShown = true}})
                            Button("New Job", role: .none, action: {Task {newJobShown = true}})
                            Button("New Session from Preset", role: .none, action: {Task {newPresetShown = true}})
                        }
                    }
                }
            .enableInjection()
        }

        #if DEBUG
        @ObserveInjection var forceRedraw
        #endif
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
//            switch loadMethod {
//            case .development:
//                let view = Self(
//                    newSessionShown: args.newSessionShown,
//                    newSessionName: args.newSessionName,
//                    newSessionUnits: args.newSessionUnits
//                    path: args.path
//                )
//                if args.createEnvironmentObject {
//                    view.environmentObject(DuctTransition.ModuleState())
//                }
//                view
//            case .production:
                Self()
//            }
        }
        
        @EnvironmentObject var state: DuctTransition.ModuleState
        @EnvironmentObject var appState: AppState
        @State var newSessionName: String = ""
        @State var newSessionUnits: DuctTransition.MeasurementUnit = .inch
        @State var newJobName: String = ""
        @State var newJobLinkedSessions: Set<UUID> = Set()
        
        @State var editShown: Bool = false
        @State var editID: UUID? = nil
        @State var editString: String = ""
        
        @State var currentRootTab: TabSelection = .sessions
        
        static var sessionPresets: [SessionPreset] {[
            .init(description: "17½x20 Box", duct: DuctData(measurements: [17.5, 20, 12, 0, 0, 17.5, 20], unit: .inch, name: "17½x20 Box")),
            .init(description: "20x20 Box", duct: DuctData(measurements: [20, 20, 12, 0, 0, 20, 20], unit: .inch, name: "20x20 Box")),
            .init(description: "20x25 Box", duct: DuctData(measurements: [20, 25, 12, 0, 0, 20, 25], unit: .inch, name: "20x25 Box")),
            .init(description: "17½x20 -> 20x20", duct: DuctData(measurements: [16, 20, 12, 0, 0, 16, 20], unit: .inch, name: "17½x20 -> 20x20")),
            .init(description: "20x20 -> 20x25", duct: DuctData(measurements: [20, 20, 12, 0, 0, 20, 20], unit: .inch, name: "20x20 -> 20x25")),
        ]}
        
        var sessionsView: some View {
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
                                    editString = d.name.wrappedValue
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
                                    Button("Save", action: {
                                        if let idx = state.ductData.firstIndex(where: {$0.id == editID}) {
                                            state.ductData[idx].name = editString
                                        }
                                        editString = ""
                                        editID = nil
                                        editShown = false
                                    })
                                    Button("Cancel", action: {
                                        editString = ""
                                        editID = nil
                                        editShown = false
                                    }).tint(.red)
                                })
                        }
                    }, header: {Text("Sessions")}, footer: {Text("Swipe left to edit name or delete")})
                }
            }
        }
        
        var jobsView: some View {
            Form {
                Section(content: {
                    List($state.jobData) { d in
                        NavigationLink(d.name.wrappedValue) {
                            Form {
                                Section(content: {
                                    ForEach(state.ductData.filter({ d.wrappedValue.ducts.contains($0.id) })) { dd in
                                        NavigationLink(value: dd) {
                                            Text(dd.name)
                                        }
                                    }
                                }, header: {Text("Transitions for \(d.name.wrappedValue)")}, footer: {Text("Ayoo")})
                            }
                            .navigationDestination(for: DuctTransition.DuctData.self) { data in
                                DuctTransition.Workshop(ductwork: data)
                            }
                        }
                    }
                }, header: {Text("Jobs")}, footer: {Text("Swipe left to edit or delete")})
            }
            
        }
        
        enum TabSelection: Hashable, Identifiable {
            case sessions, jobs
            var id: Self { self }
        }
        
        var body: some View {
            TabView(selection: $currentRootTab) {
                sessionsView
                    .tabItem {Image(systemName: "compass.drawing")}
                    .tag(TabSelection.sessions)
                jobsView
                    .tabItem {Image(systemName: "folder.fill")}
                    .tag(TabSelection.jobs)
            }
            .navigationDestination(for: DuctTransition.DuctData.self) { data in
                DuctTransition.Workshop(ductwork: data)
            }
            .sheet(isPresented: $state.airflowDataHelpShown) { AirflowDataHelpView() }
            .sheet(isPresented: $state.cameraHelpShown) { DuctTransition.CameraHelpView() }
            .sheet(isPresented: $state.generalHelpShown) { DuctTransition.GeneralHelpView(shown: $state.generalHelpShown) }
            .sheet(isPresented: $state.arCameraHelpShown) { DuctTransition.ARCameraHelpView() }
            .sheet(isPresented: $state.settingsViewShown) { DuctTransition.SettingsView(shown: $state.settingsViewShown) }
            .sheet(isPresented: $state.newSessionShown) {
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
                            state.newSessionShown = false
                        }
                    }) {
                        Text("Create")
                    }.disabled(newSessionName == "")
                }
            }
            .sheet(isPresented: $state.newJobShown) {
                Form {
                    VStack {
                        TextField("Job Name", text: $newJobName)
                        if newJobName == "" {
                            Text("Name cannot be empty").font(.footnote).foregroundColor(Color.red)
                        }
                    }
                    Section("Linked sessions") {
                        List(state.ductData) { dd in
                            Toggle("\(dd.name)", isOn: Binding(get: { newJobLinkedSessions.contains(where: { $0 == dd.id }) }, set: {
                                if $0 { newJobLinkedSessions.insert(dd.id) } else { newJobLinkedSessions.remove(dd.id) }
                            }))
                        }
                    }
                    Button(action: { Task {
                        state.jobData.append(DuctTransition.JobData(name: newJobName, ducts: newJobLinkedSessions.map { $0 }))
                        state.newJobShown = false
                    }}) {
                        Text("Create")
                    }.disabled(newJobName == "")
                }
            }
            .sheet(isPresented: $state.newPresetShown) {
                Form {
                    Section(content: {
                        ForEach(Self.sessionPresets) { p in
                            Button(action: {
                                Task {
                                    let nd = DuctData(measurements: p.duct.measurements, unit: p.duct.unit, name: p.duct.name)
                                    state.ductData.append(nd)
                                    appState.navPath.append(nd)
                                    state.newPresetShown = false
                                }
                            }) {
                                Text(p.description)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }, header: {Text("Presets")}, footer: {Text("Selecting a preset adds it to your list of sessions")})
                }
            }
            .modifier(DuctTransition.ModuleToolbar(
                cameraHelpShown: $state.cameraHelpShown,
                arCameraHelpShown: $state.arCameraHelpShown,
                generalHelpShown: $state.generalHelpShown,
                settingsViewShown: $state.settingsViewShown,
                airflowDataHelpShown: $state.airflowDataHelpShown,
                newSessionShown: Binding(get: { state.newSessionShown }, set: { state.newSessionShown = $0 ?? false }),
                newJobShown: Binding(get: { state.newJobShown }, set: { state.newJobShown = $0 ?? false }),
                newPresetShown: Binding(get: { state.newPresetShown }, set: { state.newPresetShown = $0 ?? false })
            ))
            .navigationTitle("Duct Transitions")
            .eraseToAnyView()
        }
        @ObserveInjection var redraw
    }
}

