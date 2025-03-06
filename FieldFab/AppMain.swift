//
//  AppMain.swift
//  FieldFab
//
//  Created by Robert Sale on 12/10/20.
//  Copyright © 2020 Robert Sale. All rights reserved.
//

import SwiftUI

@main
struct FieldFabApp: App {
    /// This property is deprecated now that my app uses InjectionIII
    static let loadMethod: ModuleLoadMethod = .development
    static let appState = AppState()
    static let ductTransitionModuleState = DuctTransition.ModuleState()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(Self.appState)
                .environmentObject(Self.ductTransitionModuleState)
                .onOpenURL(perform: { url in
                    if url.scheme == "fieldfab" {
                        Self.appState.currentModule = AppView.AvailableModules.ductTransition
                        var params: [String: String] = [:]
                        URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {params[$0.name] = $0.value}
                        let urle = params["encoded"]
                        let b64 = urle?.removingPercentEncoding ?? ""
                        guard let data = Data(base64Encoded: b64) else { return }
                        let decoder = JSONDecoder()
                        if let decoded = try? decoder.decode(DuctTransition.DuctData.self, from: data) {
                            let manager = FileManager.default
                            var rootDirPath = try! manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                            rootDirPath = rootDirPath.appendingPathComponent("Duct Transitions")
                            let hierarchy = ["Imported", decoded.name]
                            for path in hierarchy {
                                rootDirPath = rootDirPath.appendingPathComponent(path)
                            }
                            rootDirPath = rootDirPath.appendingPathExtension("fieldfabdt")
                            let encoded = try! JSONEncoder().encode(decoded)
                            guard ((try? encoded.write(to: rootDirPath)) != nil) else { return }
                        }
                    }
                })
            #if DEBUG
                .eraseToAnyView()
            #endif
        }
    }
}

//#if canImport(HotSwiftUI)
//@_exported import HotSwiftUI
//#elseif canImport(Inject)
//@_exported import Inject
//#else
//// This code can be found in the Swift package:
//// https://github.com/johnno1962/HotSwiftUI or
//// https://github.com/krzysztofzablocki/Inject

#if DEBUG
import Combine

public class InjectionObserver: ObservableObject {
    public static let shared = InjectionObserver()
    @Published var injectionNumber = 0
    var cancellable: AnyCancellable? = nil
    let publisher = PassthroughSubject<Void, Never>()
    init() {
        cancellable = NotificationCenter.default.publisher(for:
            Notification.Name("INJECTION_BUNDLE_NOTIFICATION"))
            .sink { [weak self] change in
            self?.injectionNumber += 1
            self?.publisher.send()
        }
    }
}

extension SwiftUI.View {
    public func eraseToAnyView() -> some SwiftUI.View {
        return AnyView(self)
    }
    public func enableInjection() -> some SwiftUI.View {
        return self.eraseToAnyView()
    }
    public func onInjection(bumpState: @escaping () -> ()) -> some SwiftUI.View {
        return self
            .onReceive(InjectionObserver.shared.publisher, perform: bumpState)
            .eraseToAnyView()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
public struct ObserveInjection: DynamicProperty {
    @ObservedObject private var iO = InjectionObserver.shared
    public init() {}
    public private(set) var wrappedValue: Int {
        get {0} set {}
    }
}
#else
public extension SwiftUI.View {
    @inline(__always)
    public func eraseToAnyView() -> some SwiftUI.View { return self }
    @inline(__always)
    public func enableInjection() -> some SwiftUI.View { return self }
    @inline(__always)
    public func onInjection(bumpState: @escaping () -> ()) -> some SwiftUI.View {
        return self
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
public struct ObserveInjection {
    public init() {}
    public private(set) var wrappedValue: Int {
        get {0} set {}
    }
}
#endif
//#endif
