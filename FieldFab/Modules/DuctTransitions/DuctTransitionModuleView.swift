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
import StringFix

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
    struct ModalSessionEditView: View {
        enum EditMode {
            case createDirectory
            case renameDirectory(String)
            case createSession
            case renameSession(String)
        }
        @Binding var pathComponents: [String]
        var directories: [String]
        var ductFiles: [String]
        @Binding var editMode: EditMode?
        @State var newName: String = ""
        
        var modalTitle: String {
            switch editMode {
            case .createDirectory: return "Create Directory"
            case .renameDirectory: return "Rename Directory"
            case .createSession: return "Create Session"
            case .renameSession: return "Rename Session"
            default: return ""
            }
        }
        var nameAlreadyExists: Bool {
            switch editMode {
            case .createDirectory, .renameDirectory:
                return directories.firstIndex(of: newName) != nil
            case .createSession, .renameSession:
                return ductFiles.firstIndex(of: newName + ".fieldfabdt") != nil
            default: return false
            }
        }
        var body: some View {
            Form {
                Section(content: {
                    TextField("New Name", text: $newName)
                }, header: {
                    Text(modalTitle)
                }, footer: {
                    if nameAlreadyExists {
                        Text("Error: Name already exists")
                            .foregroundStyle(Color.red)
                    } else if newName.isEmpty {
                        Text("Error: Name cannot be empty")
                            .foregroundStyle(Color.red)
                    } else if !newName.isValidFileName {
                        Text("Error: Name contains invalid characters")
                            .foregroundStyle(Color.red)
                    }
                })
                Button(action: {
                    if !nameAlreadyExists && !newName.isEmpty {
                        let manager = FileManager.default
                        var rootDirPath = try! manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                        rootDirPath = rootDirPath.appendingPathComponent("Duct Transitions")
                        for path in pathComponents {
                            rootDirPath = rootDirPath.appendingPathComponent(path)
                        }
                        let newPath = rootDirPath.appendingPathComponent(newName)
                        switch editMode {
                        case .createDirectory:
                            try! manager.createDirectory(at: newPath, withIntermediateDirectories: true)
                        case .renameDirectory(let string): do {
                            let oldPath = rootDirPath.appendingPathComponent(string)
                            try! manager.moveItem(at: oldPath, to: newPath)
                        }
                        case .createSession:
                            let data = try! JSONEncoder().encode(DuctData())
                            try! data.write(to: newPath.appendingPathExtension("fieldfabdt"))
                        case .renameSession(let string): do {
                            let oldSesh = rootDirPath.appendingPathComponent(string).appendingPathExtension("fieldfabdt")
                            try! manager.moveItem(at: oldSesh, to: newPath)
                        }
                        case nil:
                            return
                        }
                        pathComponents = pathComponents
                        editMode = nil
                    }
                }, label: {
                    Text("Save")
                }).disabled(nameAlreadyExists || newName.isEmpty || !newName.isValidFileName)
                Button(action: {
                    editMode = nil
                }, label: {
                    Text("Cancel")
                }).foregroundStyle(Color.red)
            }
            .onAppear {
                switch editMode {
                case .renameDirectory(let existingName): newName = existingName
                case .renameSession(let existingName):
                    let ext = ".fieldfabdt"
                    newName = String(existingName.prefix(existingName.count - ext.count))
                default: return
                }
            }
            .enableInjection()
        }
        @ObserveInjection var redraw
    }
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
                Self()
        }
        
        @EnvironmentObject var state: DuctTransition.ModuleState
        @EnvironmentObject var appState: AppState
        @State var editMode: DuctTransition.ModalSessionEditView.EditMode? = nil
        var hasMigrated: Bool {
            state.ductData.isEmpty
        }
        @State var currentPathHierarchy: [String] = []
        @State var moveSessionHierarchy: [String]? = nil
        var inMoveMode: Bool { moveSessionHierarchy != nil }
        var moveSessionIsCurrentPath: Bool {
            inMoveMode && Array(moveSessionHierarchy![0..<moveSessionHierarchy!.count-1]) == currentPathHierarchy
        }
        var currentPath: URL {
            makePathURL(with: currentPathHierarchy)
        }
        var currentPathIsDuctFile: Bool { currentPath.pathExtension == "fieldfabdt" }
        var pathContents: ([String], [String]) {
            if currentPathIsDuctFile { return ([],[]) }
            let manager = FileManager.default
            let contents = try! manager.contentsOfDirectory(at: currentPath, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles)
            let pathStrings = contents.map { $0.path }
            let directories = pathStrings
                .filter { path in
                    let url = URL(fileURLWithPath: path)
                    return url.hasDirectoryPath
                }
                .sorted()
            let ductFiles = pathStrings
                .filter { path in
                    let url = URL(fileURLWithPath: path)
                    return url.pathExtension == "fieldfabdt"
                }
                .sorted()
            return (directories.map { $0.split(separator: "/").last!.string }, ductFiles.map { $0.split(separator: "/").last!.string})
        }
        var directories: [String] { pathContents.0 }
        var ductFiles: [String] { pathContents.1 }
        
        static var sessionPresets: [SessionPreset] {[
            .init(description: "17½x20 Box", duct: DuctData(measurements: [17.5, 20, 12, 0, 0, 17.5, 20], unit: .inch, name: "17½x20 Box")),
            .init(description: "20x20 Box", duct: DuctData(measurements: [20, 20, 12, 0, 0, 20, 20], unit: .inch, name: "20x20 Box")),
            .init(description: "20x25 Box", duct: DuctData(measurements: [20, 25, 12, 0, 0, 20, 25], unit: .inch, name: "20x25 Box")),
            .init(description: "17½x20 -> 20x20", duct: DuctData(measurements: [16, 20, 12, 0, 0, 16, 20], unit: .inch, name: "17½x20 -> 20x20")),
            .init(description: "20x20 -> 20x25", duct: DuctData(measurements: [20, 20, 12, 0, 0, 20, 20], unit: .inch, name: "20x20 -> 20x25")),
        ]}
        
        func makePathURL(with hierarchy: [String]) -> URL {
            let manager = FileManager.default
            var rootDirPath = try! manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            rootDirPath = rootDirPath.appendingPathComponent("Duct Transitions")
            for path in hierarchy {
                rootDirPath = rootDirPath.appendingPathComponent(path)
            }
            if rootDirPath.pathExtension != "fieldfabdt" && !manager.directoryExists(at: rootDirPath) {
                try! manager.createDirectory(at: rootDirPath, withIntermediateDirectories: true, attributes: nil)
            }
            return rootDirPath
        }
        
        enum TabSelection: Hashable, Identifiable {
            case sessions, jobs
            var id: Self { self }
        }
        
        var fileNavigator: some View {
            Form {
                Section(
                    content: {
                        List(directories, id: \.self) { dirName in
                            Button(action: {
                                currentPathHierarchy.append(dirName)
                            }, label: {
                                HStack {
                                    Label(dirName, systemImage: "folder")
                                    Spacer()
                                    Image(systemName: "chevron.forward")
                                }
                            })
                            .swipeActions {
                                Button("Delete", systemImage: "trash") {
                                    let manager = FileManager.default
                                    try! manager.removeItem(atPath: currentPath.path() + "/" + dirName)
                                    currentPathHierarchy = currentPathHierarchy
                                }.tint(Color.red)
                                Button("Rename", systemImage: "pencil") {
                                    editMode = .renameDirectory(dirName)
                                }.tint(Color.green)
                            }
                        }
                        Button("Create Directory", systemImage: "folder.badge.plus") {
                            editMode = .createDirectory
                        }.foregroundStyle(Color.green)
                    }, header: {
                        HStack {
                            Text("Directories")
                            Spacer()
                            Group {
                                if inMoveMode {
                                    if !moveSessionIsCurrentPath {
                                        Button(action: {
                                            let manager = FileManager.default
                                            try! manager.copyItem(at: makePathURL(with: moveSessionHierarchy!), to: makePathURL(with: currentPathHierarchy + [moveSessionHierarchy!.last!]))
                                            currentPathHierarchy = currentPathHierarchy
                                            moveSessionHierarchy = nil
                                        }) {
                                            Label("Paste", systemImage: "document.on.clipboard")
                                        }.foregroundStyle(Color.yellow)
                                    } else {
                                        Button(action: {
                                            moveSessionHierarchy = nil
                                        }) {
                                            Label("Cancel", systemImage: "document.on.clipboard")
                                        }.foregroundStyle(Color.red)
                                    }
                                } else {
                                    EmptyView()
                                }
                            }
                            Button(action: {
                                let _ = currentPathHierarchy.popLast()
                            }) {
                                Label("Back", systemImage: "chevron.backward")
                            }
                            .disabled(currentPathHierarchy.isEmpty)
                        }
                    }, footer: {
                        VStack(alignment: .leading) {
                            Text("Current Directory: /\(currentPathHierarchy.joined(separator: "/"))")
                            Text("Swipe left to rename or delete directory")
                        }
                    }
                )
                
                Section(
                    content: {
                        List(ductFiles, id: \.self) { file in
                            Button(action: {
                                currentPathHierarchy.append(file)
                            }, label: {
                                HStack {
                                    Label(file.prefix(file.count - ".fieldfabdt".count), systemImage: "compass.drawing")
                                    Spacer()
                                    Image(systemName: "chevron.forward")
                                }
                            })
                            .swipeActions {
                                Button("Delete", systemImage: "trash") {
                                    let manager = FileManager.default
                                    try! manager.removeItem(at: makePathURL(with: currentPathHierarchy + [file]))
                                    currentPathHierarchy.append(file)
                                    let _ = currentPathHierarchy.popLast()
                                }.tint(Color.red)
                                Button("Rename", systemImage: "pencil") {
                                    editMode = .renameSession(file)
                                }.tint(Color.green)
                                Button("Copy", systemImage: "document.on.document") {
                                    moveSessionHierarchy = currentPathHierarchy + [file]
                                }.tint(Color.yellow)
                            }
                        }
                        Button("Create Session", systemImage: "document.badge.plus") {
                            editMode = .createSession
                        }.foregroundStyle(Color.green)
                    }, header: {
                        Text("Sessions in current directory")
                    }, footer: {
                        Text("Swipe left to rename or delete session")
                    }
                )
                
            }
        }
        
        var body: some View {
            Group {
                if currentPathIsDuctFile {
                    let data = try! Data(contentsOf: currentPath)
                    let decoded = try! JSONDecoder().decode(DuctTransition.DuctData.self, from: data)
                    DuctTransition.Workshop(ductwork: decoded, url: currentPath)
                        .toolbar {
                            Button("Back", systemImage: "chevron.backward") {
                                let _ = currentPathHierarchy.popLast()
                            }
                            Menu {
                                Button("Airflow Data Help") { state.airflowDataHelpShown = true }
                                Button("AR Camera Help") { state.arCameraHelpShown = true }
                                Button("3D Camera Help") { state.cameraHelpShown = true }
                                Button("General Help") { state.generalHelpShown = true }
                            } label: {
                                Image(systemName: "questionmark.circle")
                            }
                        }
                } else {
                    fileNavigator
                }
            }
            .alert("FieldFab recently updated to a hierarchical session system. Would you like to migrate your sessions to the new system?", isPresented: Binding(get: { hasMigrated }, set: {
                if !$0 {
                    state.ductData = []
                }
            })) {
                Button(role: .destructive) {
                    state.ductData = []
                } label: {
                    Label("Clear Old Sessions", systemImage: "trash")
                }
                Button("Migrate") {
                    let manager = FileManager.default
                    let oldSessions = ["Old Sessions"]
                    try! manager.createDirectory(at: makePathURL(with: oldSessions), withIntermediateDirectories: true)
                    for (i, duct) in state.ductData.enumerated() {
                        let encode = try! JSONEncoder().encode(duct)
                        try? encode.write(to: makePathURL(with: oldSessions + [duct.name.camelize().capitalized + "\(i)"]).appendingPathExtension("fieldfabdt"))
                    }
                    currentPathHierarchy += oldSessions
                    state.ductData = []
                }
            }
            .sheet(isPresented: $state.airflowDataHelpShown) { AirflowDataHelpView() }
            .sheet(isPresented: $state.cameraHelpShown) { DuctTransition.CameraHelpView() }
            .sheet(isPresented: $state.generalHelpShown) { DuctTransition.GeneralHelpView(shown: $state.generalHelpShown) }
            .sheet(isPresented: $state.arCameraHelpShown) { DuctTransition.ARCameraHelpView() }
            .sheet(isPresented: $state.settingsViewShown) { DuctTransition.SettingsView(shown: $state.settingsViewShown) }
            .sheet(isPresented: Binding<Bool>(get: {editMode != nil}, set: { editMode = $0 ? editMode : nil })) {
                ModalSessionEditView(pathComponents: $currentPathHierarchy, directories: directories, ductFiles: ductFiles, editMode: $editMode)
            }
            .navigationTitle("Duct Transitions")
            .eraseToAnyView()
        }
        @ObserveInjection var redraw
    }
}

extension String {
    var isValidFileName: Bool {
        let regex = "^[a-zA-Z0-9._-][a-zA-Z0-9._ -]*$"
        return range(of: regex, options: .regularExpression) == startIndex..<endIndex
    }
}
